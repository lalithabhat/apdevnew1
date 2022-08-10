global class UserDetailsRetrival{

webService static String getUserDetails() {
    system.debug('here:');
   List<User> users = new List<User>();
   Id loggedInUserId = UserInfo.getUserId();
   for (User u : Database.query('Select Id, Name, Email, MobilePhone from User where Id =:loggedInUserId' )){
       users.add(u);
   }
       String JSONString = JSON.serialize(users);
       return JSONString;
   }
}