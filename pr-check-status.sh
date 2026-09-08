#!/usr/bin/env bash

set -euo pipefail

# Never invoke gh's interactive pager. This script emits its complete report at
# the end, allowing callers to choose their own pager or consume it directly.
export GH_PAGER=cat

pr_args=()
if (( $# > 0 )); then
    pr_args=("$1")
fi

repository=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
pr_number=$(gh pr view "${pr_args[@]}" --json number --jq '.number')
IFS=/ read -r owner name <<< "$repository"

check_run_ids=$(
    gh api graphql \
        --paginate \
        -F owner="$owner" \
        -F name="$name" \
        -F number="$pr_number" \
        -f query='
query(
  $owner: String!
  $name: String!
  $number: Int!
  $endCursor: String
) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      commits(last: 1) {
        nodes {
          commit {
            statusCheckRollup {
              contexts(first: 100, after: $endCursor) {
                nodes {
                  __typename
                  ... on CheckRun {
                    id
                    name
                    annotations(first: 1) {
                      totalCount
                    }
                  }
                }
                pageInfo {
                  hasNextPage
                  endCursor
                }
              }
            }
          }
        }
      }
    }
  }
}' \
        --jq '
.data.repository.pullRequest.commits.nodes[0]
.commit.statusCheckRollup.contexts.nodes[]
| select(.__typename == "CheckRun" and .annotations.totalCount > 0)
| .id'
)

annotations_file=$(mktemp "${TMPDIR:-/tmp}/pr-check-status.XXXXXX")
trap 'rm -f "$annotations_file"' EXIT

while IFS= read -r check_run_id; do
    if [[ -z "$check_run_id" ]]; then
        continue
    fi

    gh api graphql \
        --paginate \
        --slurp \
        -F id="$check_run_id" \
        -f query='
query($id: ID!, $endCursor: String) {
  node(id: $id) {
    ... on CheckRun {
      name
      detailsUrl
      annotations(first: 100, after: $endCursor) {
        nodes {
          annotationLevel
          path
          title
          message
          rawDetails
          blobUrl
          location {
            start {
              line
              column
            }
            end {
              line
              column
            }
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
}' >> "$annotations_file"
done <<< "$check_run_ids"

jq -rs '
.[]
| .[]
| .data.node as $run
| $run.annotations.nodes[]
| (.title // "") as $title
| (.message | gsub("\r"; "")) as $message
| [
    "check: \($run.name)",
    "level: \(.annotationLevel)",
    "location: \(.path):\(.location.start.line):\(.location.start.column // 1)",
    "title: \($title)",
    "message:\n\($message)",
    "details: \($run.detailsUrl)",
    ""
  ]
| join("\n")
' "$annotations_file"
