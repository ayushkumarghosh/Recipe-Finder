import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// An optimized image widget that efficiently handles remote images with caching, 
/// placeholders, and error states.
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
  });

  @override
  Widget build(BuildContext context) {
    // Create the cached image widget with optimizations
    final cachedImage = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      // Memory optimization
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      // Fade in animation
      fadeInDuration: fadeInDuration,
      // Shimmer effect placeholder
      placeholder: (context, url) => loadingWidget ?? _buildDefaultLoading(),
      // Error handling
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
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

  /// Default error widget
  Widget _buildDefaultError() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
} 