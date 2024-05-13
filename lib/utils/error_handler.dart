import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

/// A utility class for standardized error handling throughout the app
class ErrorHandler {
  /// Translates various error types into user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return 'Network error: Please check your internet connection and try again.';
    } else if (error is FormatException) {
      return 'Data format error: The app encountered an issue with the data format.';
    } else if (error.toString().contains('401') || error.toString().contains('unauthorized')) {
      return 'Authentication error: Please try logging in again.';
    } else if (error.toString().contains('404') || error.toString().contains('not found')) {
      return 'Resource not found: The requested information could not be found.';
    } else if (error.toString().contains('429') || error.toString().contains('too many requests')) {
      return 'Too many requests: Please wait a moment and try again.';
    } else if (error.toString().contains('500') || error.toString().contains('server error')) {
      return 'Server error: Our servers are experiencing issues. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Logs errors to the console (could be expanded to log to a service)
  static void logError(dynamic error, StackTrace? stackTrace) {
    // In a production app, this would log to a service like Firebase Crashlytics
    debugPrint('ERROR: ${error.toString()}');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: ${stackTrace.toString()}');
    }
  }

  /// Shows a snackbar with an error message
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Wraps a future with standardized error handling
  static Future<T> handleFuture<T>(
    Future<T> future, {
    Function(dynamic)? onError,
    bool throwError = false,
  }) async {
    try {
      return await future;
    } catch (e, stackTrace) {
      logError(e, stackTrace);
      
      if (onError != null) {
        onError(e);
      }
      
      if (throwError) {
        rethrow;
      }
      
      // Return a default value or rethrow based on the type
      if (T == bool) {
        return false as T;
      } else if (T == int) {
        return 0 as T;
      } else if (T == double) {
        return 0.0 as T;
      } else if (T == String) {
        return '' as T;
      } else if (T == List) {
        return <dynamic>[] as T;
      } else if (T == Map) {
        return <String, dynamic>{} as T;
      } else {
        throw Exception('Could not handle error for type $T');
      }
    }
  }
} 