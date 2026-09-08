#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$PullRequest,

    [switch]$Help
)

$ErrorActionPreference = 'Stop'
$env:GH_PAGER = 'cat'

function Show-Usage {
    @'
Usage: pr-check.ps1 [PR_SELECTOR]

Emit pull request checks and check-run annotations as JSON. PR_SELECTOR may be
a PR number, URL, branch name, or OWNER/REPO#NUMBER. With no selector, GitHub
CLI selects the PR for the current branch.
'@
}

if ($Help) {
    Show-Usage
    exit 0
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'Required command not found: gh'
}

function Invoke-GhJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "gh exited with status $LASTEXITCODE"
    }

    return ($output | Out-String | ConvertFrom-Json)
}

function Get-CheckCategory {
    param($CheckRun)

    if ($CheckRun.status -ne 'completed') {
        return 'running'
    }
    if ($CheckRun.conclusion -in @('success', 'neutral', 'skipped')) {
        return 'passed'
    }
    return 'failed'
}

function Get-StatusCategory {
    param($Status)

    if ($Status.state -eq 'pending') {
        return 'running'
    }
    if ($Status.state -eq 'success') {
        return 'passed'
    }
    return 'failed'
}

$prArguments = @('pr', 'view')
if ($PullRequest) {
    if ($PullRequest -match '^([^/]+)/([^#]+)#([0-9]+)$') {
        $PullRequest = "https://github.com/$($Matches[1])/$($Matches[2])/pull/$($Matches[3])"
    }
    $prArguments += $PullRequest
}
$prArguments += @('--json', 'number,url,title,headRefName,baseRefName,headRefOid')
$pr = Invoke-GhJson -Arguments $prArguments

if ($pr.url -notmatch '^https://github\.com/([^/]+)/([^/]+)/pull/([0-9]+)(?:/.*)?$') {
    throw "Could not determine repository from PR URL: $($pr.url)"
}
$owner = $Matches[1]
$repo = $Matches[2]

$checkPages = Invoke-GhJson -Arguments @(
    'api', '--paginate', '--slurp',
    '-H', 'Accept: application/vnd.github+json',
    "repos/$owner/$repo/commits/$($pr.headRefOid)/check-runs?per_page=100"
)
$statusPages = Invoke-GhJson -Arguments @(
    'api', '--paginate', '--slurp',
    '-H', 'Accept: application/vnd.github+json',
    "repos/$owner/$repo/commits/$($pr.headRefOid)/status?per_page=100"
)

$checkRuns = @($checkPages | ForEach-Object { @($_.check_runs) })
$statuses = @($statusPages | ForEach-Object { @($_.statuses) })
$checks = @()

foreach ($run in $checkRuns) {
    $checks += [ordered]@{
        kind = 'check-run'
        id = $run.id
        name = $run.name
        category = Get-CheckCategory -CheckRun $run
        status = $run.status
        conclusion = $run.conclusion
        startedAt = $run.started_at
        completedAt = $run.completed_at
        detailsUrl = $run.details_url
        annotationsCount = $run.output.annotations_count
        output = [ordered]@{
            title = $run.output.title
            summary = $run.output.summary
            text = $run.output.text
        }
    }
}

foreach ($status in $statuses) {
    $checks += [ordered]@{
        kind = 'commit-status'
        id = $status.id
        name = $status.context
        category = Get-StatusCategory -Status $status
        status = $status.state
        conclusion = $status.state
        startedAt = $status.created_at
        completedAt = $status.updated_at
        detailsUrl = $status.target_url
        annotationsCount = 0
        description = $status.description
    }
}

$annotations = @()
foreach ($run in $checkRuns) {
    if ($run.output.annotations_count -le 0) {
        continue
    }

    $annotationPages = Invoke-GhJson -Arguments @(
        'api', '--paginate', '--slurp',
        '-H', 'Accept: application/vnd.github+json',
        "repos/$owner/$repo/check-runs/$($run.id)/annotations?per_page=100"
    )

    foreach ($page in $annotationPages) {
        foreach ($annotation in @($page)) {
            $annotations += [ordered]@{
                checkRunId = $run.id
                checkName = $run.name
                level = $annotation.annotation_level
                path = $annotation.path
                startLine = $annotation.start_line
                endLine = $annotation.end_line
                startColumn = $annotation.start_column
                endColumn = $annotation.end_column
                title = $annotation.title
                message = $annotation.message
                rawDetails = $annotation.raw_details
                blobUrl = $annotation.blob_href
                detailsUrl = $run.details_url
            }
        }
    }
}

$result = [ordered]@{
    pullRequest = [ordered]@{
        repository = "$owner/$repo"
        number = $pr.number
        url = $pr.url
        title = $pr.title
        headBranch = $pr.headRefName
        baseBranch = $pr.baseRefName
        headSha = $pr.headRefOid
    }
    summary = [ordered]@{
        all = @($checks).Count
        passed = @($checks | Where-Object category -eq 'passed').Count
        running = @($checks | Where-Object category -eq 'running').Count
        failed = @($checks | Where-Object category -eq 'failed').Count
        annotations = @($annotations).Count
    }
    checks = $checks
    annotations = $annotations
}

$result | ConvertTo-Json -Depth 20
