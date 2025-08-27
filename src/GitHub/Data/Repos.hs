{-# LANGUAGE FlexibleInstances #-}

-- |
-- This module also exports
-- @'FromJSON' a => 'FromJSON' ('HM.HashMap' 'Language' a)@
-- orphan-ish instance for @aeson < 1@

module GitHub.Data.Repos where

import GitHub.Data.Definitions
import GitHub.Data.Id          (Id)
import GitHub.Data.Name        (Name)
import GitHub.Data.Request     (IsPathPart (..))
import GitHub.Data.URL         (URL)
import GitHub.Internal.Prelude
import Prelude ()

import qualified Data.HashMap.Strict as HM
import qualified Data.Text as T
import Data.Aeson.Types (FromJSONKey (..), fromJSONKeyCoerce)

data Repo = Repo
    { repoId              :: !(Id Repo)
    , repoName            :: !(Name Repo)
    , repoOwner           :: !SimpleOwner
    , repoPrivate         :: !Bool
    , repoHtmlUrl         :: !URL
    , repoDescription     :: !(Maybe Text)
    , repoFork            :: !(Maybe Bool)
    , repoUrl             :: !URL
    , repoGitUrl          :: !(Maybe URL)
    , repoSshUrl          :: !(Maybe URL)
    , repoCloneUrl        :: !(Maybe URL)
    , repoHooksUrl        :: !URL
    , repoSvnUrl          :: !(Maybe URL)
    , repoHomepage        :: !(Maybe Text)
    , repoLanguage        :: !(Maybe Language)
    , repoForksCount      :: !Int
    , repoStargazersCount :: !Int
    , repoWatchersCount   :: !Int
    , repoSize            :: !(Maybe Int)
    , repoDefaultBranch   :: !(Maybe Text)
    , repoOpenIssuesCount :: !Int
    , repoHasIssues       :: !(Maybe Bool)
    , repoHasProjects     :: !(Maybe Bool)
    , repoHasWiki         :: !(Maybe Bool)
    , repoHasPages        :: !(Maybe Bool)
    , repoHasDownloads    :: !(Maybe Bool)
    , repoArchived        :: !Bool
    , repoDisabled        :: !Bool
    , repoPushedAt        :: !(Maybe UTCTime)   -- ^ this is Nothing for new repositories
    , repoCreatedAt       :: !(Maybe UTCTime)
    , repoUpdatedAt       :: !(Maybe UTCTime)
    , repoPermissions     :: !(Maybe RepoPermissions) -- ^ Repository permissions as they relate to the authenticated user.
    }
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData Repo
instance Binary Repo

data CodeSearchRepo = CodeSearchRepo
    { codeSearchRepoId              :: !(Id Repo)
    , codeSearchRepoName            :: !(Name Repo)
    , codeSearchRepoOwner           :: !SimpleOwner
    , codeSearchRepoPrivate         :: !Bool
    , codeSearchRepoHtmlUrl         :: !URL
    , codeSearchRepoDescription     :: !(Maybe Text)
    , codeSearchRepoFork            :: !(Maybe Bool)
    , codeSearchRepoUrl             :: !URL
    , codeSearchRepoGitUrl          :: !(Maybe URL)
    , codeSearchRepoSshUrl          :: !(Maybe URL)
    , codeSearchRepoCloneUrl        :: !(Maybe URL)
    , codeSearchRepoHooksUrl        :: !URL
    , codeSearchRepoSvnUrl          :: !(Maybe URL)
    , codeSearchRepoHomepage        :: !(Maybe Text)
    , codeSearchRepoLanguage        :: !(Maybe Language)
    , codeSearchRepoSize            :: !(Maybe Int)
    , codeSearchRepoDefaultBranch   :: !(Maybe Text)
    , codeSearchRepoHasIssues       :: !(Maybe Bool)
    , codeSearchRepoHasProjects     :: !(Maybe Bool)
    , codeSearchRepoHasWiki         :: !(Maybe Bool)
    , codeSearchRepoHasPages        :: !(Maybe Bool)
    , codeSearchRepoHasDownloads    :: !(Maybe Bool)
    , codeSearchRepoArchived        :: !Bool
    , codeSearchRepoDisabled        :: !Bool
    , codeSearchRepoPushedAt        :: !(Maybe UTCTime)   -- ^ this is Nothing for new repositories
    , codeSearchRepoCreatedAt       :: !(Maybe UTCTime)
    , codeSearchRepoUpdatedAt       :: !(Maybe UTCTime)
    , codeSearchRepoPermissions     :: !(Maybe RepoPermissions) -- ^ Repository permissions as they relate to the authenticated user.
    }
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData CodeSearchRepo
instance Binary CodeSearchRepo

-- | Repository permissions, as they relate to the authenticated user.
--
-- Returned by for example 'GitHub.Endpoints.Repos.currentUserReposR'
data RepoPermissions = RepoPermissions
    { repoPermissionAdmin :: !Bool
    , repoPermissionPush :: !Bool
    , repoPermissionPull :: !Bool
    }
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData RepoPermissions
instance Binary RepoPermissions

data RepoRef = RepoRef
    { repoRefOwner :: !SimpleOwner
    , repoRefRepo  :: !(Name Repo)
    }
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData RepoRef
instance Binary RepoRef

data NewRepo = NewRepo
    { newRepoName              :: !(Name Repo)
    , newRepoDescription       :: !(Maybe Text)
    , newRepoHomepage          :: !(Maybe Text)
    , newRepoPrivate           :: !(Maybe Bool)
    , newRepoHasIssues         :: !(Maybe Bool)
    , newRepoHasProjects       :: !(Maybe Bool)
    , newRepoHasWiki           :: !(Maybe Bool)
    , newRepoAutoInit          :: !(Maybe Bool)
    , newRepoGitignoreTemplate :: !(Maybe Text)
    , newRepoLicenseTemplate   :: !(Maybe Text)
    , newRepoAllowSquashMerge  :: !(Maybe Bool)
    , newRepoAllowMergeCommit  :: !(Maybe Bool)
    , newRepoAllowRebaseMerge  :: !(Maybe Bool)
    } deriving (Eq, Ord, Show, Data, Generic)

instance NFData NewRepo
instance Binary NewRepo

newRepo :: Name Repo -> NewRepo
newRepo name = NewRepo name Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing

data EditRepo = EditRepo
    { editName             :: !(Maybe (Name Repo))
    , editDescription      :: !(Maybe Text)
    , editHomepage         :: !(Maybe Text)
    , editPrivate          :: !(Maybe Bool)
    , editHasIssues        :: !(Maybe Bool)
    , editHasProjects      :: !(Maybe Bool)
    , editHasWiki          :: !(Maybe Bool)
    , editDefaultBranch    :: !(Maybe Text)
    , editAllowSquashMerge :: !(Maybe Bool)
    , editAllowMergeCommit :: !(Maybe Bool)
    , editAllowRebaseMerge :: !(Maybe Bool)
    , editArchived         :: !(Maybe Bool)
    }
    deriving (Eq, Ord, Show, Data, Generic)

instance NFData EditRepo
instance Binary EditRepo

-- | Filter the list of the user's repos using any of these constructors.
data RepoPublicity
    = RepoPublicityAll     -- ^ All repos accessible to the user.
    | RepoPublicityOwner   -- ^ Only repos owned by the user.
    | RepoPublicityPublic  -- ^ Only public repos.
    | RepoPublicityPrivate -- ^ Only private repos.
    | RepoPublicityMember  -- ^ Only repos to which the user is a member but not an owner.
    deriving (Show, Eq, Ord, Enum, Bounded, Data, Generic)

-- | The value is the number of bytes of code written in that language.
type Languages = HM.HashMap Language Int

-- | A programming language.
newtype Language = Language Text
   deriving (Show, Data, Eq, Ord, Generic)

getLanguage :: Language -> Text
getLanguage (Language l) = l

instance NFData Language
instance Binary Language
instance Hashable Language where
    hashWithSalt salt (Language l) = hashWithSalt salt l
instance IsString Language where
    fromString = Language . fromString

data Contributor
    -- | An existing Github user, with their number of contributions, avatar
    -- URL, login, URL, ID, and Gravatar ID.
    = KnownContributor !Int !URL !(Name User) !URL !(Id User) !Text
    -- | An unknown Github user with their number of contributions and recorded name.
    | AnonymousContributor !Int !Text
   deriving (Show, Data, Eq, Ord, Generic)

instance NFData Contributor
instance Binary Contributor

contributorToSimpleUser :: Contributor -> Maybe SimpleUser
contributorToSimpleUser (AnonymousContributor _ _) = Nothing
contributorToSimpleUser (KnownContributor _contributions avatarUrl name url uid _gravatarid) =
    Just $ SimpleUser uid name avatarUrl url

-- | The permission of a collaborator on a repository.
-- See <https://developer.github.com/v3/repos/collaborators/#review-a-users-permission-level>
data CollaboratorPermission
    = CollaboratorPermissionAdmin
    | CollaboratorPermissionWrite
    | CollaboratorPermissionRead
    | CollaboratorPermissionNone
    deriving (Show, Data, Enum, Bounded, Eq, Ord, Generic)

instance NFData CollaboratorPermission
instance Binary CollaboratorPermission

-- | A collaborator and its permission on a repository.
-- See <https://developer.github.com/v3/repos/collaborators/#review-a-users-permission-level>
data CollaboratorWithPermission
    = CollaboratorWithPermission SimpleUser CollaboratorPermission
    deriving (Show, Data, Eq, Ord, Generic)

instance NFData CollaboratorWithPermission
instance Binary CollaboratorWithPermission

-- JSON instances

instance FromJSON Repo where
    parseJSON = withObject "Repo" $ \o -> Repo <$> o .: "id"
        <*> o .: "name"
        <*> o .: "owner"
        <*> o .: "private"
        <*> o .: "html_url"
        <*> o .:? "description"
        <*> o .: "fork"
        <*> o .: "url"
        <*> o .:? "git_url"
        <*> o .:? "ssh_url"
        <*> o .:? "clone_url"
        <*> o .: "hooks_url"
        <*> o .:? "svn_url"
        <*> o .:? "homepage"
        <*> o .:? "language"
        <*> o .: "forks_count"
        <*> o .: "stargazers_count"
        <*> o .: "watchers_count"
        <*> o .:? "size"
        <*> o .:? "default_branch"
        <*> o .: "open_issues_count"
        <*> o .:? "has_issues"
        <*> o .:? "has_projects"
        <*> o .:? "has_wiki"
        <*> o .:? "has_pages"
        <*> o .:? "has_downloads"
        <*> o .:? "archived" .!= False
        <*> o .:? "disabled" .!= False
        <*> o .:? "pushed_at"
        <*> o .:? "created_at"
        <*> o .:? "updated_at"
        <*> o .:? "permissions"

instance FromJSON CodeSearchRepo where
    parseJSON = withObject "Repo" $ \o -> CodeSearchRepo <$> o .: "id"
        <*> o .: "name"
        <*> o .: "owner"
        <*> o .: "private"
        <*> o .: "html_url"
        <*> o .:? "description"
        <*> o .: "fork"
        <*> o .: "url"
        <*> o .:? "git_url"
        <*> o .:? "ssh_url"
        <*> o .:? "clone_url"
        <*> o .: "hooks_url"
        <*> o .:? "svn_url"
        <*> o .:? "homepage"
        <*> o .:? "language"
        <*> o .:? "size"
        <*> o .:? "default_branch"
        <*> o .:? "has_issues"
        <*> o .:? "has_projects"
        <*> o .:? "has_wiki"
        <*> o .:? "has_pages"
        <*> o .:? "has_downloads"
        <*> o .:? "archived" .!= False
        <*> o .:? "disabled" .!= False
        <*> o .:? "pushed_at"
        <*> o .:? "created_at"
        <*> o .:? "updated_at"
        <*> o .:? "permissions"

instance ToJSON NewRepo where
  toJSON (NewRepo { newRepoName              = name
                  , newRepoDescription       = description
                  , newRepoHomepage          = homepage
                  , newRepoPrivate           = private
                  , newRepoHasIssues         = hasIssues
                  , newRepoHasProjects       = hasProjects
                  , newRepoHasWiki           = hasWiki
                  , newRepoAutoInit          = autoInit
                  , newRepoGitignoreTemplate = gitignoreTemplate
                  , newRepoLicenseTemplate   = licenseTemplate
                  , newRepoAllowSquashMerge  = allowSquashMerge
                  , newRepoAllowMergeCommit  = allowMergeCommit
                  , newRepoAllowRebaseMerge  = allowRebaseMerge
                  }) = object
                  [ "name"                .= name
                  , "description"         .= description
                  , "homepage"            .= homepage
                  , "private"             .= private
                  , "has_issues"          .= hasIssues
                  , "has_projects"        .= hasProjects
                  , "has_wiki"            .= hasWiki
                  , "auto_init"           .= autoInit
                  , "gitignore_template"  .= gitignoreTemplate
                  , "license_template"    .= licenseTemplate
                  , "allow_squash_merge"  .= allowSquashMerge
                  , "allow_merge_commit"  .= allowMergeCommit
                  , "allow_rebase_merge"  .= allowRebaseMerge
                  ]

instance ToJSON EditRepo where
  toJSON (EditRepo { editName             = name
                   , editDescription      = description
                   , editHomepage         = homepage
                   , editPrivate          = private
                   , editHasIssues        = hasIssues
                   , editHasProjects      = hasProjects
                   , editHasWiki          = hasWiki
                   , editDefaultBranch    = defaultBranch
                   , editAllowSquashMerge = allowSquashMerge
                   , editAllowMergeCommit = allowMergeCommit
                   , editAllowRebaseMerge = allowRebaseMerge
                   , editArchived         = archived
                   }) = object
                   [ "name"               .= name
                   , "description"        .= description
                   , "homepage"           .= homepage
                   , "private"            .= private
                   , "has_issues"         .= hasIssues
                   , "has_projects"       .= hasProjects
                   , "has_wiki"           .= hasWiki
                   , "default_branch"     .= defaultBranch
                   , "allow_squash_merge" .= allowSquashMerge
                   , "allow_merge_commit" .= allowMergeCommit
                   , "allow_rebase_merge" .= allowRebaseMerge
                   , "archived"           .= archived
                   ]

instance FromJSON RepoPermissions where
  parseJSON = withObject "RepoPermissions" $ \o -> RepoPermissions
        <$> o .: "admin"
        <*> o .: "push"
        <*> o .: "pull"

instance FromJSON RepoRef where
    parseJSON = withObject "RepoRef" $ \o -> RepoRef
        <$> o .: "owner"
        <*> o .: "name"

instance FromJSON Contributor where
    parseJSON = withObject "Contributor" $ \o -> do
        t <- o .: "type"
        case (t :: Text) of
            "Anonymous" -> AnonymousContributor
                <$> o .: "contributions"
                <*> o .: "name"
            _  -> KnownContributor
                <$> o .: "contributions"
                <*> o .: "avatar_url"
                <*> o .: "login"
                <*> o .: "url"
                <*> o .: "id"
                <*> o .: "gravatar_id"

instance FromJSON Language where
    parseJSON = withText "Language" (pure . Language)

instance ToJSON Language where
    toJSON = toJSON . getLanguage

instance FromJSONKey Language where
    fromJSONKey = fromJSONKeyCoerce

data ArchiveFormat
    = ArchiveFormatTarball -- ^ ".tar.gz" format
    | ArchiveFormatZipball -- ^ ".zip" format
    deriving (Show, Eq, Ord, Enum, Bounded, Data, Generic)

instance IsPathPart ArchiveFormat where
    toPathPart af = case af of
        ArchiveFormatTarball -> "tarball"
        ArchiveFormatZipball -> "zipball"

instance FromJSON CollaboratorPermission where
    parseJSON = withText "CollaboratorPermission" $ \t -> case T.toLower t of
        "admin" -> pure CollaboratorPermissionAdmin
        "write" -> pure CollaboratorPermissionWrite
        "read"  -> pure CollaboratorPermissionRead
        "none"  -> pure CollaboratorPermissionNone
        _       -> fail $ "Unknown CollaboratorPermission: " <> T.unpack t

instance ToJSON CollaboratorPermission where
    toJSON CollaboratorPermissionAdmin = "admin"
    toJSON CollaboratorPermissionWrite = "write"
    toJSON CollaboratorPermissionRead  = "read"
    toJSON CollaboratorPermissionNone  = "none"

instance FromJSON CollaboratorWithPermission where
    parseJSON = withObject "CollaboratorWithPermission" $ \o -> CollaboratorWithPermission
        <$> o .: "user"
        <*> o .: "permission"
