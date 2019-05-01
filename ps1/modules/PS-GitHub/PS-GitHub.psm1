$contextClass = Get-Content -Raw (Join-Path $PSScriptRoot "GitHubContext.cs")
Add-Type -TypeDefinition $contextClass

$DefaultGitHubEndpoint = "https://api.github.com/graphql"

[PsGitHub.GitHubContext]$ActiveGitHubContext = $null

$UnixEpoch = [DateTimeOffset]"01-01-1970Z"

function _InvokeGql([PsGitHub.GitHubContext]$context, [Parameter(ValueFromPipeline = $true)]$query) {
    $headers = @{
        "Authorization" = "Bearer $($context.AccessToken)";
    }
    $request = @{
        "query" = $query;
    } | ConvertTo-Json

    $response = Invoke-WebRequest "$($context.Endpoints.GraphQl)" -Headers $headers -Body $request -Method POST

    # Update Rate Limit information
    $limit = [int]$response.Headers["X-RateLimit-Limit"][0]
    $remaining = [int]$response.Headers["X-RateLimit-Remaining"][0]
    $resetSecs = [int]$response.Headers["X-RateLimit-Reset"][0]
    $reset = $UnixEpoch.AddSeconds($resetSecs)
    $context.RateLimit.Update($limit, $remaining, $reset)

    $response.Content | ConvertFrom-Json
}

function _EnsureContext([PsGitHub.GitHubContext]$context) {
    if ($context) {
        $context
    }
    elseif ($ActiveGitHubContext) {
        $ActiveGitHubContext
    }
    else {
        throw "This command requires an active GitHub context. Use 'Connect-GitHub' to establish one, or pass a context created with 'New-GitHubContext' in as the '-Context' parameter."
    }
}

<#
.SYNOPSIS
    Creates a new GitHub context and sets it as the active context, or sets an existing context as the active context
.PARAMETER Context
    An existing GitHub context object to set as the active context
.PARAMETER AccessToken
    A GitHub Personal Access Token to use for authentication
.PARAMETER GitHubEnterpriseBase
    An optional base URL for a GitHub Enterprise Server. If not specified, uses GitHub.com.
#>
function Connect-GitHub() {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SetExisting")][PsGitHub.GitHubContext]$Context,
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "CreateNew")][string]$AccessToken,
        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew")][string]$GitHubEnterpriseBase
    )

    if (!$AccessToken) {
        if (Get-Command Get-Token -ErrorAction SilentlyContinue) {
            $AccessToken = Get-Token GitHub -ExpandValue
            if (!$AccessToken) {
                throw "Could not find a 'GitHub' token in the token store. Use 'Get-Token' to list tokens or '-AccessToken' to specify a token manually"
            }
        }
        else {
            throw "Could not find 'Get-Token' command. The 'PS-Tokens' module must be installed to use ambient tokens"
        }
    }

    if (!$Context) {
        $Context = New-GitHubContext -AccessToken:$AccessToken -GitHubEnterpriseBase:$GitHubEnterpriseBase
    }

    if ($ActiveGitHubContext) {
        Write-Host "Replacing existing GitHub context!"
    }

    $script:ActiveGitHubContext = $Context
}


<#
.SYNOPSIS
    Creates a new GitHub context WITHOUT setting it as the active context
.PARAMETER AccessToken
    A GitHub Personal Access Token to use for authentication
.PARAMETER GitHubEnterpriseBase
    An optional base URL for a GitHub Enterprise Server. If not specified, uses GitHub.com.
#>
function New-GitHubContext() {
    param(
        [Parameter(Mandatory = $true)][string]$AccessToken,
        [Parameter(Mandatory = $false)][string]$GitHubEnterpriseBase
    )

    if ($GitHubEnterpriseRoot) {
        $gqlEndpoint = "$GitHubEnterpriseBase/api/graphql"
        $restRoot = "$GitHubEnterpriseBase/api/v3"
    }
    else {
        $gqlEndpoint = "https://api.github.com/graphql"
        $restRoot = "https://api.github.com"
    }

    # Create the context
    $context = New-Object PsGithub.GitHubContext @($accessToken, $gqlEndpoint, $restRoot)

    # Fetch the current user name
    $query = "query { viewer { login } }"
    $result = $query | _InvokeGql $context
    $context.Login = $result.data.viewer.login

    $context
}

<#
.SYNOPSIS
    Gets the active GitHub Context
#>
function Get-GitHubContext() {
    $ActiveGitHubContext
}

<#
.SYNOPSIS
    Executes a GraphQL query or mutation against the provided GitHub context.
.PARAMETER Query
    The GraphQL query or mutation to perform.
.PARAMETER Context
    The GitHub context to use to invoke the query. Defaults to the active context, as returned by 'Get-GitHubContext'
#>
function Get-GitHubGraphQlObject() {
    param(
        [Parameter(Mandatory = $true)][string]$Query,
        [Parameter(Mandatory = $false)][GitHubContext]$Context
    )

    $Context = _EnsureContext $Context
    _InvokeGql $Context $Query
}