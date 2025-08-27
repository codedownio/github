module GitHub.Data.Comments where

import GitHub.Data.Definitions
import GitHub.Data.Id          (Id)
import GitHub.Data.URL         (URL)
import GitHub.Internal.Prelude
import Prelude ()

data Comment = Comment
    { commentPosition  :: !(Maybe Int)
    , commentLine      :: !(Maybe Int)
    , commentBody      :: !Text
    , commentCommitId  :: !(Maybe Text)
    , commentUpdatedAt :: !UTCTime
    , commentHtmlUrl   :: !(Maybe URL)
    , commentUrl       :: !URL
    , commentCreatedAt :: !(Maybe UTCTime)
    , commentPath      :: !(Maybe Text)
    , commentUser      :: !SimpleUser
    , commentId        :: !(Id Comment)
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance NFData Comment
instance Binary Comment

instance FromJSON Comment where
    parseJSON = withObject "Comment" $ \o -> Comment
        <$> o .:? "position"
        <*> o .:? "line"
        <*> o .: "body"
        <*> o .:? "commit_id"
        <*> o .: "updated_at"
        <*> o .:? "html_url"
        <*> o .: "url"
        <*> o .: "created_at"
        <*> o .:? "path"
        <*> o .: "user"
        <*> o .: "id"

data NewComment = NewComment
    { newCommentBody :: !Text
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance NFData NewComment
instance Binary NewComment

instance ToJSON NewComment where
    toJSON (NewComment b) = object [ "body" .= b ]

data EditComment = EditComment
    { editCommentBody :: !Text
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance NFData EditComment
instance Binary EditComment

instance ToJSON EditComment where
    toJSON (EditComment b) = object [ "body" .= b ]

data NewPullComment = NewPullComment
    { newPullCommentCommit   :: !Text
    , newPullCommentPath     :: !Text
    , newPullCommentPosition :: !Int
    , newPullCommentBody     :: !Text
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance NFData NewPullComment
instance Binary NewPullComment

instance ToJSON NewPullComment where
    toJSON (NewPullComment c path pos b) =
        object [ "body" .= b
               , "commit_id" .= c
               , "path" .= path
               , "position" .= pos
               ]

data PullCommentReply = PullCommentReply
    { pullCommentReplyBody     :: Text
    }
  deriving (Show, Data, Eq, Ord, Generic)

instance NFData PullCommentReply

instance ToJSON PullCommentReply where
    toJSON (PullCommentReply b) =
        object [ "body" .= b
               ]
