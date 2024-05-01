class StringUtils {
  /// Capitalizes the first letter of each word in a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Formats a list of strings into a comma-separated string
  static String formatList(List<String> items) {
    if (items.isEmpty) return '';
    return items.join(', ');
  }
} 