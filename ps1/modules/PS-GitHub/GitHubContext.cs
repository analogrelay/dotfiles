using System;

namespace PsGitHub
{
    public class GitHubEndpoints
    {
        public string GraphQl { get; }
        public string Rest { get; }

        public GitHubEndpoints(string graphQl, string rest)
        {
            GraphQl = graphQl;
            Rest = rest;
        }
    }

    public class RateLimit
    {
        public int Limit { get; set; }
        public int Remaining { get; set; }
        public DateTimeOffset ResetAt { get; set; }

        public void Update(int limit, int remaining, DateTimeOffset resetAt)
        {
            Limit = limit;
            Remaining = remaining;
            ResetAt = resetAt;
        }
    }

    public class GitHubContext
    {
        public string Login { get; set; }
        public string AccessToken { get; }
        public GitHubEndpoints Endpoints { get; }
        public RateLimit RateLimit { get; }

        public GitHubContext(string accessToken, string graphQlEndpoint, string restRoot)
        {
            AccessToken = accessToken;
            Endpoints = new GitHubEndpoints(graphQlEndpoint, restRoot);
            RateLimit = new RateLimit();
        }
    }
}