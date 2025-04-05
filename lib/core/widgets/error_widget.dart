import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import 'package:lottie/lottie.dart';

enum ErrorType { general, network, server, notFound }

class ErrorWidgetCustom extends StatelessWidget {
  final ErrorType type;
  final String? message;
  final VoidCallback? onRetry;
  final String? lottieAsset;

  const ErrorWidgetCustom({
    super.key,
    this.type = ErrorType.general,
    this.message,
    this.onRetry,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildErrorIcon(),
              const SizedBox(height: 16),
              Text(
                message ?? _getDefaultMessage(),
                style: AppStyles.bodyText,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    if (lottieAsset != null) {
      return Lottie.asset(lottieAsset!, width: 120, height: 120);
    }

    IconData icon;
    Color color = AppColors.error;

    switch (type) {
      case ErrorType.network:
        icon = Icons.wifi_off;
        break;
      case ErrorType.server:
        icon = Icons.cloud_off;
        break;
      case ErrorType.notFound:
        icon = Icons.search_off;
        break;
      default:
        icon = Icons.error_outline;
    }

    return Icon(icon, size: 80, color: color);
  }

  String _getDefaultMessage() {
    switch (type) {
      case ErrorType.network:
        return "No internet connection. Please check your network and try again.";
      case ErrorType.server:
        return "Server error. Please try again later.";
      case ErrorType.notFound:
        return "Data not found. Please check again.";
      default:
        return "Something went wrong. Please try again.";
    }
  }

  // Static convenience methods
  static Widget networkError({VoidCallback? onRetry}) {
    return ErrorWidgetCustom(type: ErrorType.network, onRetry: onRetry);
  }

  static Widget serverError({VoidCallback? onRetry}) {
    return ErrorWidgetCustom(type: ErrorType.server, onRetry: onRetry);
  }

  static Widget notFoundError({VoidCallback? onRetry}) {
    return ErrorWidgetCustom(type: ErrorType.notFound, onRetry: onRetry);
  }
}
