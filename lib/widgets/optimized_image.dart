import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;

/// An optimized image widget that efficiently handles remote images with caching, 
/// placeholders, error states, and optimized loading.
class OptimizedImage extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;
  
  /// Optional height constraint
  final double? height;
  
  /// Optional width constraint
  final double? width;
  
  /// How the image should be inscribed into the space allocated
  final BoxFit fit;
  
  /// Optional border radius for the image
  final BorderRadius? borderRadius;
  
  /// Memory cache width for image resizing optimization
  final int? memCacheWidth;
  
  /// Memory cache height for image resizing optimization
  final int? memCacheHeight;
  
  /// Widget to display when loading (overrides default shimmer effect)
  final Widget? loadingWidget;
  
  /// Widget to display when an error occurs (overrides default)
  final Widget? errorWidget;
  
  /// Hero tag for animations between screens (optional)
  final String? heroTag;
  
  /// Duration for the fade-in animation
  final Duration fadeInDuration;
  
  /// Whether to enable blur-up effect for progressive loading
  final bool enableBlurUp;
  
  /// Blur sigma for the blur-up effect
  final double blurSigma;
  
  /// Whether to use high quality for the network image
  final bool highQuality;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.loadingWidget,
    this.errorWidget,
    this.heroTag,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableBlurUp = true,
    this.blurSigma = 10.0,
    this.highQuality = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine optimal memory cache width and height based on device pixel ratio
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final calculatedMemCacheWidth = memCacheWidth != null 
        ? (memCacheWidth! * pixelRatio).toInt() 
        : (width != null ? (width! * pixelRatio).toInt() : null);
    final calculatedMemCacheHeight = memCacheHeight != null 
        ? (memCacheHeight! * pixelRatio).toInt() 
        : (height != null ? (height! * pixelRatio).toInt() : null);
    
    // Create the cached image widget with optimizations
    final cachedImage = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      // Memory optimization
      memCacheWidth: calculatedMemCacheWidth,
      memCacheHeight: calculatedMemCacheHeight,
      // Fade in animation
      fadeInDuration: fadeInDuration,
      // Shimmer effect placeholder
      placeholder: (context, url) => loadingWidget ?? _buildDefaultLoading(),
      // Error handling
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
      // Use high quality for important images
      maxWidthDiskCache: highQuality ? 2000 : 800,
      maxHeightDiskCache: highQuality ? 2000 : 800,
      // Progressive loading
      progressIndicatorBuilder: enableBlurUp 
          ? (context, url, progress) => _buildProgressiveLoading(progress) 
          : null,
    );
    
    // Apply hero animation if tag is provided
    final imageWidget = heroTag != null
        ? Hero(tag: heroTag!, child: cachedImage)
        : cachedImage;
    
    // Apply border radius if specified
    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: imageWidget)
        : imageWidget;
  }

  /// Default shimmer loading effect
  Widget _buildDefaultLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        color: Colors.grey.shade300,
      ),
    );
  }

  /// Progressive loading with blur effect
  Widget _buildProgressiveLoading(DownloadProgress progress) {
    if (progress.progress == null) {
      return _buildDefaultLoading();
    }
    
    // If we have a thumbnail, show it with blur
    if (progress.progress! > 0 && enableBlurUp) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          Image.network(
            imageUrl,
            height: height,
            width: width,
            fit: fit,
            filterQuality: FilterQuality.low,
            cacheHeight: 100, // Very small for thumbnail
            cacheWidth: 100,  // Very small for thumbnail
            frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
              // Apply blur effect
              return ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: blurSigma * (1 - (progress.progress ?? 0)), 
                  sigmaY: blurSigma * (1 - (progress.progress ?? 0)),
                ),
                child: Opacity(
                  opacity: 0.8,
                  child: child,
                ),
              );
            },
          ),
          // Show loading indicator
          Center(
            child: CircularProgressIndicator(
              value: progress.progress,
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    } else {
      // Fallback to simple progress indicator
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildDefaultLoading(),
          CircularProgressIndicator(
            value: progress.progress,
            color: Colors.white,
            strokeWidth: 2,
          ),
        ],
      );
    }
  }

  /// Default error widget
  Widget _buildDefaultError() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Image failed to load',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 