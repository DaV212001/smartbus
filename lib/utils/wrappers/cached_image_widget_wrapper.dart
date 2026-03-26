import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Widget cachedNetworkImageWrapper({
  required String imageUrl,
  required Widget Function(BuildContext, ImageProvider<Object>) imageBuilder,
  required Widget Function(BuildContext, String) placeholderBuilder,
  required Widget Function(BuildContext, String, Object) errorWidgetBuilder,
}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    imageBuilder: imageBuilder,
    placeholder: placeholderBuilder,
    errorWidget: errorWidgetBuilder,
    errorListener: (e) {
      print('');
    },
    cacheManager: DefaultCacheManager(), // Ensure caching is enabled
    cacheKey: imageUrl, // Assign a cache key to avoid re-downloading
  );
}

class LargeCardImageHolder extends StatelessWidget {
  const LargeCardImageHolder({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: image,
    );
  }
}

class SmallCardImageHolder extends StatelessWidget {
  const SmallCardImageHolder({
    super.key,
    required this.image,
    this.radius,
  });

  final Image image;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    var defaultRadius = 50.0;
    return Container(
      height: radius ?? defaultRadius,
      width: radius ?? defaultRadius,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(radius ?? defaultRadius),
        ),
        child: image,
      ),
    );
  }
}

class CircularImageHolder extends StatelessWidget {
  const CircularImageHolder({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child:
            ClipRRect(borderRadius: BorderRadius.circular(100), child: image));
  }
}
