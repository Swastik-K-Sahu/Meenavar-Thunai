class ValidatorUtils {
  // Email validation pattern
  static final RegExp _emailPattern = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  // Password validation patterns
  static final RegExp _passwordLengthPattern = RegExp(r'.{8,}');
  static final RegExp _passwordUppercasePattern = RegExp(r'[A-Z]');
  static final RegExp _passwordLowercasePattern = RegExp(r'[a-z]');
  static final RegExp _passwordDigitPattern = RegExp(r'[0-9]');
  static final RegExp _passwordSpecialPattern = RegExp(
    r'[!@#$%^&*(),.?":{}|<>]',
  );

  // Phone number validation pattern (generic)
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{10,15}$');

  // Name validation pattern
  static final RegExp _namePattern = RegExp(r'^[a-zA-Z\s\-]+$');

  // URL validation pattern
  static final RegExp _urlPattern = RegExp(
    r'^(http|https)://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
    caseSensitive: false,
  );

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? "$fieldName is required"
          : "This field is required";
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    final requiredCheck = validateRequired(value, fieldName: "Email");
    if (requiredCheck != null) return requiredCheck;

    if (!_emailPattern.hasMatch(value!)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {bool isStrong = true}) {
    final requiredCheck = validateRequired(value, fieldName: "Password");
    if (requiredCheck != null) return requiredCheck;

    if (!_passwordLengthPattern.hasMatch(value!)) {
      return "Password must be at least 8 characters long";
    }

    if (isStrong) {
      List<String> requirements = [];

      if (!_passwordUppercasePattern.hasMatch(value)) {
        requirements.add("uppercase letter");
      }
      if (!_passwordLowercasePattern.hasMatch(value)) {
        requirements.add("lowercase letter");
      }
      if (!_passwordDigitPattern.hasMatch(value)) {
        requirements.add("digit");
      }
      if (!_passwordSpecialPattern.hasMatch(value)) {
        requirements.add("special character");
      }

      if (requirements.isNotEmpty) {
        return "Password must include at least one ${requirements.join(', ')}";
      }
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String password) {
    final requiredCheck = validateRequired(
      value,
      fieldName: "Password confirmation",
    );
    if (requiredCheck != null) return requiredCheck;

    if (value != password) {
      return "Passwords do not match";
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    final requiredCheck = validateRequired(value, fieldName: "Phone number");
    if (requiredCheck != null) return requiredCheck;

    if (!_phonePattern.hasMatch(value!)) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value, {String? fieldName}) {
    final requiredCheck = validateRequired(
      value,
      fieldName: fieldName ?? "Name",
    );
    if (requiredCheck != null) return requiredCheck;

    if (!_namePattern.hasMatch(value!)) {
      return "Please enter a valid name";
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    final requiredCheck = validateRequired(value, fieldName: "URL");
    if (requiredCheck != null) return requiredCheck;

    if (!_urlPattern.hasMatch(value!)) {
      return "Please enter a valid URL";
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    final requiredCheck = validateRequired(value, fieldName: fieldName);
    if (requiredCheck != null) return requiredCheck;

    if (value!.length < minLength) {
      return "${fieldName ?? 'This field'} must be at least $minLength characters long";
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return "${fieldName ?? 'This field'} must not exceed $maxLength characters";
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, {String? fieldName}) {
    final requiredCheck = validateRequired(value, fieldName: fieldName);
    if (requiredCheck != null) return requiredCheck;

    if (double.tryParse(value!) == null) {
      return "${fieldName ?? 'This field'} must be a number";
    }
    return null;
  }

  // Range validation
  static String? validateRange(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    final numericCheck = validateNumeric(value, fieldName: fieldName);
    if (numericCheck != null) return numericCheck;

    final numValue = double.parse(value!);
    if (numValue < min || numValue > max) {
      return "${fieldName ?? 'This field'} must be between $min and $max";
    }
    return null;
  }
}
