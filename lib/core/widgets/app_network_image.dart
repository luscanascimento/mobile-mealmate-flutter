import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'shimmer_box.dart';

/// A cached network image with a shimmer placeholder and a graceful fallback.
///
/// Enforces HTTPS: any non-HTTPS URL renders the fallback rather than making a
/// plaintext request.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  bool get _isValid {
    final String? u = url;
    return u != null &&
        u.isNotEmpty &&
        Uri.tryParse(u)?.isScheme('https') == true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid) {
      return _fallback(context);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      width: width,
      height: height,
      placeholder: (BuildContext context, String _) =>
          ShimmerBox(width: width, height: height),
      errorWidget: (BuildContext context, String _, Object __) =>
          _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        color: scheme.onSurfaceVariant,
        size: 40,
      ),
    );
  }
}
