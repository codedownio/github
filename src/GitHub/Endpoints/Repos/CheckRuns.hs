-- |
-- The repo check runs API as described on
-- <https://docs.github.com/en/rest/checks/runs>

module GitHub.Endpoints.Repos.CheckRuns (
    checkRunsForR,
    checkRunsPageForR,
    module GitHub.Data
    ) where

import GitHub.Data
import GitHub.Internal.Prelude
import Prelude ()

import qualified Data.ByteString.Char8 as BS8

-- | List check runs for a specific ref (branch, tag, or commit SHA)
-- See <https://docs.github.com/en/rest/checks/runs#list-check-runs-for-a-git-reference>
checkRunsForR :: Name Owner -> Name Repo -> Name Commit -> Request 'RW CheckRunsResponse
checkRunsForR owner repo ref =
    query ["repos", toPathPart owner, toPathPart repo, "commits", toPathPart ref, "check-runs"] []

-- | Like 'checkRunsForR', but requesting a specific page of results (the API caps
-- per_page at 100 and defaults to 30). Compare 'checkRunsTotalCount' against the
-- accumulated runs to know when all pages have been fetched.
checkRunsPageForR :: Name Owner -> Name Repo -> Name Commit -> Int -> Int -> Request 'RW CheckRunsResponse
checkRunsPageForR owner repo ref perPage page =
    query ["repos", toPathPart owner, toPathPart repo, "commits", toPathPart ref, "check-runs"]
          [ ("per_page", [QE (BS8.pack (show perPage))])
          , ("page", [QE (BS8.pack (show page))])
          ]
