module GitHub.Data.RateLimit where

import GitHub.Internal.Prelude
import Prelude ()

import Data.Time.Clock.System (SystemTime (..))

import qualified Data.ByteString.Char8 as BS8
import qualified Network.HTTP.Client as HTTP

data Limits = Limits
    { limitsMax       :: !Int
    , limitsRemaining :: !Int
    , limitsReset     :: !SystemTime
    }
  deriving (Show, {- Data, -} Typeable, Eq, Ord, Generic)

instance NFData Limits
instance Binary Limits

instance FromJSON Limits where
    parseJSON = withObject "Limits" $ \obj -> Limits
        <$> obj .: "limit"
        <*> obj .: "remaining"
        <*> fmap (\t -> MkSystemTime t 0) (obj .: "reset")

data RateLimit = RateLimit
    { rateLimitCore    :: Limits
    , rateLimitSearch  :: Limits
    , rateLimitGraphQL :: Limits
    }
  deriving (Show, {- Data, -} Typeable, Eq, Ord, Generic)

instance NFData RateLimit
instance Binary RateLimit

instance FromJSON RateLimit where
    parseJSON = withObject "RateLimit" $ \obj -> do
        resources <- obj .: "resources"
        RateLimit
            <$> resources .: "core"
            <*> resources .: "search"
            <*> resources .: "graphql"

-------------------------------------------------------------------------------
-- Extras
-------------------------------------------------------------------------------

-- | @since 0.24
limitsFromHttpResponse :: HTTP.Response a -> Maybe Limits
limitsFromHttpResponse res = do
    let hdrs = HTTP.responseHeaders res
    m <- lookup "X-RateLimit-Limit"     hdrs >>= readIntegral
    r <- lookup "X-RateLimit-Remaining" hdrs >>= readIntegral
    t <- lookup "X-RateLimit-Reset"     hdrs >>= readIntegral
    return (Limits m r (MkSystemTime t 0))
  where
    readIntegral :: Num a => BS8.ByteString -> Maybe a
    readIntegral bs = case BS8.readInt bs of
        Just (n, bs') | BS8.null bs' -> Just (fromIntegral n)
        _                            -> Nothing
