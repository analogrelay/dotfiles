#!/usr/bin/env bash

set -euo pipefail

export GH_PAGER=cat

usage() {
    cat <<'EOF'
Usage: pr-check.sh [PR_SELECTOR]

Emit pull request checks and check-run annotations as JSON. PR_SELECTOR may be
a PR number, URL, branch name, or OWNER/REPO#NUMBER. With no selector, GitHub
CLI selects the PR for the current branch.
EOF
}

if (( $# > 1 )); then
    usage >&2
    exit 2
fi

if (( $# == 1 )) && [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

for command in gh jq; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'error: required command not found: %s\n' "$command" >&2
        exit 127
    fi
done

pr_args=()
if (( $# == 1 )); then
    selector=$1
    if [[ "$selector" =~ ^([^/]+)/([^#]+)#([0-9]+)$ ]]; then
        selector="https://github.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/pull/${BASH_REMATCH[3]}"
    fi
    pr_args=("$selector")
fi

pr=$(
    gh pr view "${pr_args[@]}" \
        --json number,url,title,headRefName,baseRefName,headRefOid
)

readarray -t identity < <(
    jq -er '
      .url
      | capture("^https://github\\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/pull/(?<number>[0-9]+)(?:/.*)?$")
      | .owner, .repo
    ' <<<"$pr"
)
owner=${identity[0]}
repo=${identity[1]}
head_sha=$(jq -er '.headRefOid' <<<"$pr")

check_pages=$(
    gh api --paginate --slurp \
        -H 'Accept: application/vnd.github+json' \
        "repos/$owner/$repo/commits/$head_sha/check-runs?per_page=100"
)
status_pages=$(
    gh api --paginate --slurp \
        -H 'Accept: application/vnd.github+json' \
        "repos/$owner/$repo/commits/$head_sha/status?per_page=100"
)

check_runs=$(jq -c '[.[] | .check_runs[]]' <<<"$check_pages")
legacy_statuses=$(jq -c '[.[] | .statuses[]]' <<<"$status_pages")

annotations_file=$(mktemp "${TMPDIR:-/tmp}/pr-check.XXXXXX")
trap 'rm -f "$annotations_file"' EXIT
: >"$annotations_file"

while IFS= read -r check_run_id; do
    [[ -n "$check_run_id" ]] || continue
    check_run=$(jq -c --argjson id "$check_run_id" '.[] | select(.id == $id)' <<<"$check_runs")
    annotation_pages=$(
        gh api --paginate --slurp \
            -H 'Accept: application/vnd.github+json' \
            "repos/$owner/$repo/check-runs/$check_run_id/annotations?per_page=100"
    )
    jq -cn \
        --argjson run "$check_run" \
        --argjson pages "$annotation_pages" '
      {
        checkRunId: $run.id,
        checkName: $run.name,
        detailsUrl: $run.details_url,
        annotations: [$pages[][]]
      }
    ' >>"$annotations_file"
done < <(
    jq -r '.[] | select(.output.annotations_count > 0) | .id' <<<"$check_runs"
)

jq -n \
    --argjson pr "$pr" \
    --arg owner "$owner" \
    --arg repo "$repo" \
    --argjson checkRuns "$check_runs" \
    --argjson statuses "$legacy_statuses" \
    --slurpfile annotationPages "$annotations_file" '
  def check_category:
    if .status != "completed" then "running"
    elif (.conclusion == "success" or .conclusion == "neutral" or .conclusion == "skipped") then "passed"
    else "failed"
    end;

  def status_category:
    if .state == "pending" then "running"
    elif .state == "success" then "passed"
    else "failed"
    end;

  [
    $checkRuns[]
    | {
        kind: "check-run",
        id,
        name,
        category: check_category,
        status,
        conclusion,
        startedAt: .started_at,
        completedAt: .completed_at,
        detailsUrl: .details_url,
        annotationsCount: .output.annotations_count,
        output: {
          title: .output.title,
          summary: .output.summary,
          text: .output.text
        }
      }
  ]
  +
  [
    $statuses[]
    | {
        kind: "commit-status",
        id,
        name: .context,
        category: status_category,
        status: .state,
        conclusion: .state,
        startedAt: .created_at,
        completedAt: .updated_at,
        detailsUrl: .target_url,
        annotationsCount: 0,
        description
      }
  ] as $checks
  |
  [
    $annotationPages[]
    | . as $page
    | $page.annotations[]
    | {
        checkRunId: $page.checkRunId,
        checkName: $page.checkName,
        level: .annotation_level,
        path,
        startLine: .start_line,
        endLine: .end_line,
        startColumn: .start_column,
        endColumn: .end_column,
        title,
        message,
        rawDetails: .raw_details,
        blobUrl: .blob_href,
        detailsUrl: $page.detailsUrl
      }
  ] as $annotations
  |
  {
    pullRequest: {
      repository: "\($owner)/\($repo)",
      number: $pr.number,
      url: $pr.url,
      title: $pr.title,
      headBranch: $pr.headRefName,
      baseBranch: $pr.baseRefName,
      headSha: $pr.headRefOid
    },
    summary: {
      all: ($checks | length),
      passed: ([$checks[] | select(.category == "passed")] | length),
      running: ([$checks[] | select(.category == "running")] | length),
      failed: ([$checks[] | select(.category == "failed")] | length),
      annotations: ($annotations | length)
    },
    checks: $checks,
    annotations: $annotations
  }
'
