import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safe external-URL launcher.
///
/// Only opens well-formed HTTPS links; anything else is ignored and reported to
/// the user, preventing accidental navigation to unsafe schemes.
class UrlHelper {
  const UrlHelper._();

  static Future<void> openExternal(
    BuildContext context,
    String? rawUrl,
  ) async {
    final Uri? uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
    if (uri == null || !uri.isScheme('https')) {
      _showError(context, 'This link is unavailable.');
      return;
    }

    final bool launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showError(context, 'Could not open the link.');
    }
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
