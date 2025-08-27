module GitHub.Data.Email where

import GitHub.Internal.Prelude
import Prelude ()

import qualified Data.Text as T

data EmailVisibility
    = EmailVisibilityPrivate
    | EmailVisibilityPublic
    deriving (Show, Data, Enum, Bounded, Typeable, Eq, Ord, Generic)

instance NFData EmailVisibility
instance Binary EmailVisibility

instance FromJSON EmailVisibility where
    parseJSON = withText "EmailVisibility" $ \t -> case T.toLower t of
        "private" -> pure EmailVisibilityPrivate
        "public"  -> pure EmailVisibilityPublic
        _         -> fail $ "Unknown EmailVisibility: " <> T.unpack t

data Email = Email
    { emailAddress    :: !Text
    , emailVerified   :: !Bool
    , emailPrimary    :: !Bool
    , emailVisibility :: !(Maybe EmailVisibility)
    } deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData Email
instance Binary Email

instance FromJSON Email where
    parseJSON = withObject "Email" $ \o -> Email
        <$> o .:  "email"
        <*> o .:  "verified"
        <*> o .:  "primary"
        <*> o .:? "visibility"
