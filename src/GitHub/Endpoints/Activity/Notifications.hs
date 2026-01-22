-- |
-- The repo watching API as described on
-- <https://developer.github.com/v3/activity/notifications/>.

module GitHub.Endpoints.Activity.Notifications (
    getNotificationsR,
    markNotificationAsReadR,
    markNotificationAsDoneR,
    markAllNotificationsAsReadR,
    ) where

import GitHub.Data
import GitHub.Internal.Prelude
import Prelude ()

-- | List your notifications.
-- See <https://developer.github.com/v3/activity/notifications/#list-your-notifications>
getNotificationsR :: NotificationMod -> FetchCount -> Request 'RA (Vector Notification)
getNotificationsR opts = pagedQuery ["notifications"] (notificationModToQueryString opts)

-- | Mark a thread as read.
-- See <https://developer.github.com/v3/activity/notifications/#mark-a-thread-as-read>
markNotificationAsReadR :: Id Notification -> GenRequest 'MtUnit 'RW ()
markNotificationAsReadR nid = Command
    Patch
    ["notifications", "threads", toPathPart nid]
    mempty

-- | Mark a thread as done (removes it from the notification inbox).
-- See <https://docs.github.com/en/rest/activity/notifications#delete-a-thread-subscription>
markNotificationAsDoneR :: Id Notification -> GenRequest 'MtUnit 'RW ()
markNotificationAsDoneR nid = Command
    Delete
    ["notifications", "threads", toPathPart nid]
    mempty

-- | Mark as read.
-- See <https://developer.github.com/v3/activity/notifications/#mark-as-read>
markAllNotificationsAsReadR :: GenRequest 'MtUnit 'RW ()
markAllNotificationsAsReadR =
    Command Put ["notifications"] $ encode emptyObject
