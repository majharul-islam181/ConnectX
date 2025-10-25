class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    return emailRegex.hasMatch(email.trim());
  }

  // Phone validation
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)\.]{7,15}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  // Search query validation
  static bool isValidSearchQuery(String query) {
    return query.trim().length >= 2;
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // ID validation
  static bool isValidId(int? id) {
    return id != null && id > 0;
  }

  // Page number validation
  static bool isValidPage(int page) {
    return page > 0;
  }

  // Per page validation
  static bool isValidPerPage(int perPage) {
    return perPage > 0 && perPage <= 100;
  }

  // String length validation
  static bool isValidLength(String text,
      {int minLength = 0, int maxLength = 255}) {
    final length = text.trim().length;
    return length >= minLength && length <= maxLength;
  }

  // Check if string contains only letters and spaces
  static bool isAlphaWithSpaces(String text) {
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    return regex.hasMatch(text.trim());
  }

  // Check if string is alphanumeric
  static bool isAlphanumeric(String text) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(text.trim());
  }

  // Sanitize search query
  static String sanitizeSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  // Clean name
  static String cleanName(String name) {
    return name.trim().split(RegExp(r'\s+')).join(' ');
  }

  // Extract domain from email
  static String? extractEmailDomain(String email) {
    if (isValidEmail(email)) {
      return email.split('@').last;
    }
    return null;
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d\+]'), '');
    return cleaned;
  }

  // Check if image URL is valid
  static bool isValidImageUrl(String url) {
    if (!isValidUrl(url)) return false;

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg'];
    final lowercaseUrl = url.toLowerCase();

    return imageExtensions.any((ext) => lowercaseUrl.contains(ext));
  }

  // Validate pagination parameters
  static Map<String, dynamic>? validatePaginationParams({
    required int page,
    required int perPage,
    String? searchQuery,
  }) {
    final errors = <String, String>{};

    if (!isValidPage(page)) {
      errors['page'] = 'Page must be greater than 0';
    }

    if (!isValidPerPage(perPage)) {
      errors['perPage'] = 'Per page must be between 1 and 100';
    }

    if (searchQuery != null &&
        searchQuery.isNotEmpty &&
        !isValidSearchQuery(searchQuery)) {
      errors['searchQuery'] = 'Search query must be at least 2 characters';
    }

    return errors.isEmpty ? null : errors;
  }

  // Private constructor to prevent instantiation
  Validators._();
}
