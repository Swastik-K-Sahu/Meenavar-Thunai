import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

enum LoadingSize { small, medium, large, fullScreen }

enum LoadingType { circular, linear, lottie }

class LoadingWidget extends StatelessWidget {
  final LoadingSize size;
  final LoadingType type;
  final String? message;
  final Color? color;
  final bool overlay;
  final String? lottieAsset;

  const LoadingWidget({
    super.key,
    this.size = LoadingSize.medium,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.overlay = false,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = _buildLoadingWidget();

    if (overlay) {
      return _buildOverlay(context, loadingWidget);
    }

    return _buildBasicLoading(loadingWidget);
  }

  Widget _buildOverlay(BuildContext context, Widget loadingWidget) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildBasicLoading(loadingWidget),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicLoading(Widget loadingWidget) {
    if (message == null) {
      return loadingWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingWidget,
        const SizedBox(height: 16),
        Text(message!, style: AppStyles.bodyText, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    final loadingColor = color ?? AppColors.primary;

    switch (type) {
      case LoadingType.circular:
        return _buildCircularProgressIndicator(loadingColor);
      case LoadingType.linear:
        return _buildLinearProgressIndicator(loadingColor);
      case LoadingType.lottie:
        return _buildLottieAnimation();
    }
  }

  Widget _buildCircularProgressIndicator(Color loadingColor) {
    double? size;

    switch (this.size) {
      case LoadingSize.small:
        size = 24.0;
        break;
      case LoadingSize.medium:
        size = 40.0;
        break;
      case LoadingSize.large:
        size = 60.0;
        break;
      case LoadingSize.fullScreen:
        size = 80.0;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
        strokeWidth: size / 10,
      ),
    );
  }

  Widget _buildLinearProgressIndicator(Color loadingColor) {
    double width;

    switch (size) {
      case LoadingSize.small:
        width = 100.0;
        break;
      case LoadingSize.medium:
        width = 200.0;
        break;
      case LoadingSize.large:
        width = 300.0;
        break;
      case LoadingSize.fullScreen:
        width = double.infinity;
        break;
    }

    return SizedBox(
      width: width,
      height: 4,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
        backgroundColor: loadingColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    double size;

    switch (this.size) {
      case LoadingSize.small:
        size = 80.0;
        break;
      case LoadingSize.medium:
        size = 120.0;
        break;
      case LoadingSize.large:
        size = 200.0;
        break;
      case LoadingSize.fullScreen:
        size = 300.0;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        lottieAsset ?? 'assets/animations/loading.json',
        width: size,
        height: size,
      ),
    );
  }

  // Static convenience methods
  static Widget fullscreenLoading({String? message, Color? color}) {
    return LoadingWidget(
      size: LoadingSize.large,
      overlay: true,
      message: message,
      color: color,
    );
  }

  static Widget circularSmall({Color? color}) {
    return LoadingWidget(
      size: LoadingSize.small,
      type: LoadingType.circular,
      color: color,
    );
  }

  static Widget lottieLoading({String? message, String? lottieAsset}) {
    return LoadingWidget(
      type: LoadingType.lottie,
      message: message,
      lottieAsset: lottieAsset,
    );
  }
}
