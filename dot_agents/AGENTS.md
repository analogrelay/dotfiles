# General Agent Instructions

Be aware that I almost always use Jujutsu for version control instead of Git.
Use the `jujutsu` skill when version control operations are required.

## Git Hosting Workflows

Before pushing a branch or creating a pull request, inspect the configured remotes
and use the matching workflow:

- **Standard workflow:** The repository has a single `origin` remote and no
  `upstream` remote. Create and push work branches to `origin`, and create pull
  requests in the repository designated by `origin`.
- **Fork workflow:** The repository has separate `origin` and `upstream`
  remotes. `origin` is my personal fork. Create and push work branches to
  `origin`, but create pull requests in the repository designated by `upstream`
  with the branch from `origin` as the head.

Do not assume that `origin` is the pull request target when an `upstream` remote
exists.
