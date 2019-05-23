param(
    [Parameter(Mandatory = $true, Position = 0)][string]$SearchQuery
)
$query = @'
query($queryText: String!) {
	search(type: ISSUE, query: $queryText, first: 1) {
    issueCount
  }
}
'@

if(!(Get-Module PS-GitHub -ErrorAction SilentlyContinue)) {
    throw "Requires PS-GitHub module"
}

$result = Get-GitHubGraphQlObject $query -Parameters @{ "queryText" = $SearchQuery }
$result.data.search.issueCount