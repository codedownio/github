{-# LANGUAGE TemplateHaskell #-}

module GitHub.Data.Issues where

import Data.Aeson.TH (deriveFromJSON, deriveToJSON, defaultOptions, Options(..))
import qualified Data.Text as T
import GitHub.Data.Definitions
import GitHub.Data.Id           (Id)
import GitHub.Data.Milestone    (Milestone)
import GitHub.Data.Name         (Name)
import GitHub.Data.Options      (IssueState, IssueStateReason)
import GitHub.Data.PullRequests
import GitHub.Data.URL          (URL(..))
import GitHub.Internal.Prelude
import Prelude                  ()


-- * Types in topological order (leaves first)

data GitAuthor = GitAuthor
    { gitAuthorName  :: !Text
    , gitAuthorEmail :: !Text
    , gitAuthorDate  :: !UTCTime
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData GitAuthor
instance Binary GitAuthor
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("gitAuthor" :: String)) } ''GitAuthor)

data Issue = Issue
    { issueClosedAt    :: !(Maybe UTCTime)
    , issueUpdatedAt   :: !UTCTime
    , issueEventsUrl   :: !URL
    , issueHtmlUrl     :: !(Maybe URL)
    , issueClosedBy    :: !(Maybe SimpleUser)
    , issueLabels      :: !(Vector IssueLabel)
    , issueNumber      :: !IssueNumber
    , issueAssignees   :: !(Vector SimpleUser)
    , issueUser        :: !SimpleUser
    , issueTitle       :: !Text
    , issuePullRequest :: !(Maybe PullRequestReference)
    , issueUrl         :: !URL
    , issueCreatedAt   :: !UTCTime
    , issueBody        :: !(Maybe Text)
    , issueState       :: !IssueState
    , issueId          :: !(Id Issue)
    , issueComments    :: !Int
    , issueMilestone   :: !(Maybe Milestone)
    , issueStateReason :: !(Maybe IssueStateReason)
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData Issue
instance Binary Issue
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("issue" :: String)) } ''Issue)

data NewIssue = NewIssue
    { newIssueTitle     :: !Text
    , newIssueBody      :: !(Maybe Text)
    , newIssueAssignees :: !(Vector (Name User))
    , newIssueMilestone :: !(Maybe (Id Milestone))
    , newIssueLabels    :: !(Maybe (Vector (Name IssueLabel)))
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData NewIssue
instance Binary NewIssue
$(deriveToJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("newIssue" :: String)), omitNothingFields = True } ''NewIssue)

data EditIssue = EditIssue
    { editIssueTitle     :: !(Maybe Text)
    , editIssueBody      :: !(Maybe Text)
    , editIssueAssignees :: !(Maybe (Vector (Name User)))
    , editIssueState     :: !(Maybe IssueState)
    , editIssueMilestone :: !(Maybe (Id Milestone))
    , editIssueLabels    :: !(Maybe (Vector (Name IssueLabel)))
    }
  deriving  (Show, Data, Eq, Ord, Generic)
instance NFData EditIssue
instance Binary EditIssue
$(deriveToJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("editIssue" :: String)), omitNothingFields = True } ''EditIssue)

data IssueComment = IssueComment
    { issueCommentUpdatedAt :: !UTCTime
    , issueCommentUser      :: !SimpleUser
    , issueCommentUrl       :: !URL
    , issueCommentHtmlUrl   :: !URL
    , issueCommentCreatedAt :: !UTCTime
    , issueCommentBody      :: !Text
    , issueCommentId        :: !Int
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData IssueComment
instance Binary IssueComment
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("issueComment" :: String)) } ''IssueComment)

data CrossReferenceSource = CrossReferenceSource
    { crossReferenceSourceIssue :: !(Maybe Issue)
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData CrossReferenceSource
instance Binary CrossReferenceSource
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("crossReferenceSource" :: String)), omitNothingFields = True } ''CrossReferenceSource)

data TimelineCommitEvent = TimelineCommitEvent
    { timelineCommitEventSha       :: !Text
    , timelineCommitEventMessage   :: !Text
    , timelineCommitEventAuthor    :: !GitAuthor
    , timelineCommitEventCommitter :: !GitAuthor
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData TimelineCommitEvent
instance Binary TimelineCommitEvent
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("timelineCommitEvent" :: String)) } ''TimelineCommitEvent)

data TimelineReviewEvent = TimelineReviewEvent
    { timelineReviewEventUser        :: !SimpleUser
    , timelineReviewEventBody        :: !(Maybe Text)
    , timelineReviewEventState       :: !Text
    , timelineReviewEventSubmittedAt :: !UTCTime
    , timelineReviewEventId          :: !Int
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData TimelineReviewEvent
instance Binary TimelineReviewEvent
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("timelineReviewEvent" :: String)) } ''TimelineReviewEvent)

-- | See <https://developer.github.com/v3/issues/events/#events-1>
data EventType
    = Mentioned                 -- ^ The actor was @mentioned in an issue body.
    | Subscribed                -- ^ The actor subscribed to receive notifications for an issue.
    | Unsubscribed              -- ^ The issue was unsubscribed from by the actor.
    | Referenced                -- ^ The issue was referenced from a commit message. The commit_id attribute is the commit SHA1 of where that happened.
    | Merged                    -- ^ The issue was merged by the actor. The commit_id attribute is the SHA1 of the HEAD commit that was merged.
    | Assigned                  -- ^ The issue was assigned to the actor.
    | Closed                    -- ^ The issue was closed by the actor. When the commit_id is present, it identifies the commit that closed the issue using "closes / fixes #NN" syntax.
    | Reopened                  -- ^ The issue was reopened by the actor.
    | ActorUnassigned           -- ^ The issue was unassigned to the actor
    | Labeled                   -- ^ A label was added to the issue.
    | Unlabeled                 -- ^ A label was removed from the issue.
    | Milestoned                -- ^ The issue was added to a milestone.
    | Demilestoned              -- ^ The issue was removed from a milestone.
    | Renamed                   -- ^ The issue title was changed.
    | Locked                    -- ^ The issue was locked by the actor.
    | Unlocked                  -- ^ The issue was unlocked by the actor.
    | HeadRefDeleted            -- ^ The pull request's branch was deleted.
    | HeadRefForcePushed        -- ^ The pull request's branch was force pushed.
    | HeadRefRestored           -- ^ The pull request's branch was restored.
    | ReviewRequested           -- ^ The actor requested review from the subject on this pull request.
    | ReviewDismissed           -- ^ The actor dismissed a review from the pull request.
    | ReviewRequestRemoved      -- ^ The actor removed the review request for the subject on this pull request.
    | MarkedAsDuplicate         -- ^ A user with write permissions marked an issue as a duplicate of another issue or a pull request as a duplicate of another pull request.
    | UnmarkedAsDuplicate       -- ^ An issue that a user had previously marked as a duplicate of another issue is no longer considered a duplicate, or a pull request that a user had previously marked as a duplicate of another pull request is no longer considered a duplicate.
    | AddedToProject            -- ^ The issue was added to a project board.
    | AddedToProjectV2          -- ^ The issue was added to a project board.
    | MovedColumnsInProject     -- ^ The issue was moved between columns in a project board.
    | ProjectItemStatusChanged  -- ^ The issue's status in a project was changed.
    | RemovedFromProject        -- ^ The issue was removed from a project board.
    | ConvertedNoteToIssue      -- ^ The issue was created by converting a note in a project board to an issue.
    | AddedToMergeQueue         -- ^ The pull request was added to a merge queue.
    | RemovedFromMergeQueue     -- ^ The pull request was removed from a merge queue.
    | CrossReferenced           -- ^ The issue was referenced from another issue or pull request.
    | Unknown Text              -- ^ An unknown event type.
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData EventType
instance Binary EventType
instance FromJSON EventType where
    parseJSON = withText "EventType" $ \t -> case T.toLower t of
        "closed"                         -> pure Closed
        "reopened"                       -> pure Reopened
        "subscribed"                     -> pure Subscribed
        "merged"                         -> pure Merged
        "referenced"                     -> pure Referenced
        "mentioned"                      -> pure Mentioned
        "assigned"                       -> pure Assigned
        "unassigned"                     -> pure ActorUnassigned
        "labeled"                        -> pure Labeled
        "unlabeled"                      -> pure Unlabeled
        "milestoned"                     -> pure Milestoned
        "demilestoned"                   -> pure Demilestoned
        "renamed"                        -> pure Renamed
        "locked"                         -> pure Locked
        "unlocked"                       -> pure Unlocked
        "head_ref_deleted"               -> pure HeadRefDeleted
        "head_ref_force_pushed"          -> pure HeadRefForcePushed
        "head_ref_restored"              -> pure HeadRefRestored
        "review_requested"               -> pure ReviewRequested
        "review_dismissed"               -> pure ReviewDismissed
        "review_request_removed"         -> pure ReviewRequestRemoved
        "marked_as_duplicate"            -> pure MarkedAsDuplicate
        "unmarked_as_duplicate"          -> pure UnmarkedAsDuplicate
        "added_to_project"               -> pure AddedToProject
        "added_to_project_v2"            -> pure AddedToProjectV2
        "moved_columns_in_project"       -> pure MovedColumnsInProject
        "project_v2_item_status_changed" -> pure ProjectItemStatusChanged
        "removed_from_project"           -> pure RemovedFromProject
        "converted_note_to_issue"        -> pure ConvertedNoteToIssue
        "added_to_merge_queue"           -> pure AddedToMergeQueue
        "removed_from_merge_queue"       -> pure RemovedFromMergeQueue
        "unsubscribed"                   -> pure Unsubscribed -- not in api docs list
        "cross-referenced"               -> pure CrossReferenced
        _                                -> pure $ Unknown t

data IssueEvent = IssueEvent
    { issueEventActor             :: !(Maybe SimpleUser)
    , issueEventEvent             :: !EventType
    , issueEventCommitId          :: !(Maybe Text)
    , issueEventUrl               :: !(Maybe URL)
    , issueEventCreatedAt         :: !UTCTime
    , issueEventId                :: !(Maybe Int)
    , issueEventIssue             :: !(Maybe Issue)
    , issueEventLabel             :: !(Maybe IssueLabel)
    , issueEventRequestedReviewer :: !(Maybe SimpleUser)
    , issueEventSource            :: !(Maybe CrossReferenceSource)
    }
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData IssueEvent
instance Binary IssueEvent
$(deriveFromJSON defaultOptions { fieldLabelModifier = camelToSnake . drop (length ("issueEvent" :: String)) } ''IssueEvent)

-- | A timeline event from the issue timeline API.
data TimelineEvent
    = TimelineIssueEvent !IssueEvent
    | TimelineComment !IssueComment
    | TimelineCommit !TimelineCommitEvent
    | TimelineReview !TimelineReviewEvent
  deriving (Show, Data, Eq, Ord, Generic)
instance NFData TimelineEvent
instance Binary TimelineEvent
instance FromJSON TimelineEvent where
    parseJSON v = withObject "TimelineEvent" (\o -> do
        event <- o .: "event"
        case (event :: Text) of
            "commented"  -> TimelineComment <$> parseJSON v
            "committed"  -> TimelineCommit <$> parseJSON v
            "reviewed"   -> TimelineReview <$> parseJSON v
            _            -> TimelineIssueEvent <$> parseJSON v
      ) v
