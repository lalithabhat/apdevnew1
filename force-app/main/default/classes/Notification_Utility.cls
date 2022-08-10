public class Notification_Utility {
	 public static void notifyUsers(Set<String> recipientsIds, String targetId,String title, String body) {
        
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Generic'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(body);
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}