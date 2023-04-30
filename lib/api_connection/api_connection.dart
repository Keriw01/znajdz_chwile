class API {
  static const hostConnect =
      "https://znajdzchwile.000webhostapp.com/api_znajdz_chwile";
  static const hostConnectUser = "$hostConnect/user";

  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnect/user/signup.php";
  static const login = "$hostConnect/user/login.php";
  static const eventsList = "$hostConnect/event/list_events.php";
  static const eventsListWithRangeDate =
      "$hostConnect/event/list_event_with_range_date.php";
  static const eventCheck = "$hostConnect/event/check_event.php";
  static const eventDelete = "$hostConnect/event/delete_event.php";
  static const eventUpdate = "$hostConnect/event/update_event.php";
  static const eventAdd = "$hostConnect/event/add_event.php";
  static const readLastEventId = "$hostConnect/event/read_last_event_id.php";
  static const addNotification =
      "$hostConnect/notification/add_notification.php";
  static const readNotification =
      "$hostConnect/notification/read_notification.php";
  static const loginWithGoogle = "$hostConnect/user/login_with_google.php";
  static const signUpWithGoogle = "$hostConnect/user/signup_with_google.php";
  static const getIdUserGoogle = "$hostConnect/user/get_id_user_google.php";
  static const tagsList = "$hostConnect/tag/list_tag.php";
}
