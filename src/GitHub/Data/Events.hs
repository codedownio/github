module GitHub.Data.Events where

import GitHub.Data.Definitions
import GitHub.Internal.Prelude
import Prelude ()

-- | Events.
--
-- /TODO:/
--
-- * missing repo, org, payload, id
--
data Event = Event
    -- { eventId        :: !(Id Event) -- id can be encoded as string.
    { eventActor     :: !SimpleUser
    , eventCreatedAt :: !UTCTime
    , eventPublic    :: !Bool
    }
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData Event
instance Binary Event

instance FromJSON Event where
    parseJSON = withObject "Event" $ \obj -> Event
        -- <$> obj .: "id"
        <$> obj .: "actor"
        <*> obj .: "created_at"
        <*> obj .: "public"
