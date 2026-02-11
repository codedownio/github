-- |
-- The repo check runs API as described on
-- <https://docs.github.com/en/rest/checks/runs>

module GitHub.Endpoints.Repos.CheckRuns (
    checkRunsForR,
    module GitHub.Data
    ) where

import GitHub.Data
import GitHub.Internal.Prelude
import Prelude ()

-- | List check runs for a specific ref (branch, tag, or commit SHA)
-- See <https://docs.github.com/en/rest/checks/runs#list-check-runs-for-a-git-reference>
checkRunsForR :: Name Owner -> Name Repo -> Name Commit -> Request 'RW CheckRunsResponse
checkRunsForR owner repo ref =
    query ["repos", toPathPart owner, toPathPart repo, "commits", toPathPart ref, "check-runs"] []
