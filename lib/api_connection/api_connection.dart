class API {
  static const hostConnect = "http://192.168.100.10/api_znajdz_chwile";
  static const hostConnectUser = "$hostConnect/user";

  //User signUp/Login
  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnect/user/signup.php";
  static const login = "$hostConnect/user/login.php";

  //Events Add
  static const addEvent = "$hostConnect/event/add_event.php";
}
