import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loading.dart';
import '../theme/theme.dart';

class VanixImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const VanixImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    Widget imageWidget;
    if (!hasUrl) {
      // Fallback custom container for local testing or empty urls
      imageWidget = Container(
        width: width,
        height: height,
        color: AppTheme.cardGrey,
        child: const Center(
          child: Icon(
            Icons.movie_creation_outlined,
            color: Colors.white24,
            size: 36,
          ),
        ),
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => ShimmerLoading(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          borderRadius: borderRadius,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppTheme.cardGrey,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white24,
              size: 28,
            ),
          ),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
