/// Form validators shared by LoginForm, RegisterForm and EventForm.
/// Each one returns an error message, or null when the value is valid.
class Validators {
  /// For any field that must not be empty, e.g. full name, student ID, venue.
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Something@something.something, with no spaces. Kept simple because
    // Firebase also rejects bad emails with invalid-email.
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    // Not trimmed: a space can be part of a real password.
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? joinCode(String? value){
    if(value == null || value.trim().isEmpty){
      return 'Join code is required';
    }

    final joinCodePattern = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');

    if(!joinCodePattern.hasMatch(value.trim().toUpperCase())){
      return 'Please Enter the 6-character code';
    }

    return null;
  }
}
