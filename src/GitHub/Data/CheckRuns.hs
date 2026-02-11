{-# LANGUAGE NoImplicitPrelude  #-}

module GitHub.Data.CheckRuns where

import GitHub.Data.Id          (Id)
import GitHub.Data.Name        (Name)
import GitHub.Data.URL         (URL)
import GitHub.Internal.Prelude
import Prelude ()

import qualified Data.Text as T

-------------------------------------------------------------------------------
-- Check run status and conclusion
-------------------------------------------------------------------------------

data CheckRunStatus
    = CheckRunQueued
    | CheckRunInProgress
    | CheckRunCompleted
  deriving (Show, Data, Enum, Bounded, Eq, Ord, Generic)

instance NFData CheckRunStatus
instance Binary CheckRunStatus

instance FromJSON CheckRunStatus where
    parseJSON = withText "CheckRunStatus" $ \t -> case T.toLower t of
        "queued"      -> pure CheckRunQueued
        "in_progress" -> pure CheckRunInProgress
        "completed"   -> pure CheckRunCompleted
        _             -> fail $ "Unknown CheckRunStatus: " <> T.unpack t

data CheckRunConclusion
    = CheckRunSuccess
    | CheckRunFailure
    | CheckRunNeutral
    | CheckRunCancelled
    | CheckRunSkipped
    | CheckRunTimedOut
    | CheckRunActionRequired
    | CheckRunStartupFailure
    | CheckRunStale
  deriving (Show, Data, Enum, Bounded, Eq, Ord, Generic)

instance NFData CheckRunConclusion
instance Binary CheckRunConclusion

instance FromJSON CheckRunConclusion where
    parseJSON = withText "CheckRunConclusion" $ \t -> case T.toLower t of
        "success"          -> pure CheckRunSuccess
        "failure"          -> pure CheckRunFailure
        "neutral"          -> pure CheckRunNeutral
        "cancelled"        -> pure CheckRunCancelled
        "skipped"          -> pure CheckRunSkipped
        "timed_out"        -> pure CheckRunTimedOut
        "action_required"  -> pure CheckRunActionRequired
        "startup_failure"  -> pure CheckRunStartupFailure
        "stale"            -> pure CheckRunStale
        _                  -> fail $ "Unknown CheckRunConclusion: " <> T.unpack t

-------------------------------------------------------------------------------
-- Check run
-------------------------------------------------------------------------------

data CheckRun = CheckRun
    { checkRunId          :: !(Id CheckRun)
    , checkRunHeadSha     :: !Text
    , checkRunStatus      :: !CheckRunStatus
    , checkRunConclusion  :: !(Maybe CheckRunConclusion)
    , checkRunName        :: !(Name CheckRun)
    , checkRunUrl         :: !URL
    , checkRunHtmlUrl     :: !(Maybe URL)
    , checkRunDetailsUrl  :: !(Maybe URL)
    , checkRunStartedAt   :: !(Maybe UTCTime)
    , checkRunCompletedAt :: !(Maybe UTCTime)
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance FromJSON CheckRun where
    parseJSON = withObject "CheckRun" $ \o -> CheckRun
        <$> o .: "id"
        <*> o .: "head_sha"
        <*> o .: "status"
        <*> o .:? "conclusion"
        <*> o .: "name"
        <*> o .: "url"
        <*> o .:? "html_url"
        <*> o .:? "details_url"
        <*> o .:? "started_at"
        <*> o .:? "completed_at"

-------------------------------------------------------------------------------
-- Check runs list response
-------------------------------------------------------------------------------

data CheckRunsResponse = CheckRunsResponse
    { checkRunsTotalCount :: !Int
    , checkRunsCheckRuns  :: !(Vector CheckRun)
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance FromJSON CheckRunsResponse where
    parseJSON = withObject "CheckRunsResponse" $ \o -> CheckRunsResponse
        <$> o .: "total_count"
        <*> o .: "check_runs"
