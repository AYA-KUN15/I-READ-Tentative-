class FormData {
  static final FormData _instance = FormData._internal();

  factory FormData() {
    return _instance;
  }

  FormData._internal();

  String fullName = ''; // User's full name
  String strand = ''; // User's educational strand
  String birthday = ''; // User's birthday
  String address = ''; // User's address
  String email = ''; // User's email
  String username = ''; // User's username
  String password = ''; // User's password
  String uniqueCode = ''; // Unique code for registration
}
