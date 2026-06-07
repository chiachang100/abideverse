import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import 'package:abideverse/shared/services/url_service.dart';

/// Enum defining the visual style variants for the custom button
enum CustomButtonVariant {
  /// Outlined button with border - good for secondary actions
  outlined,

  /// Filled button with background color - good for primary actions
  filled,

  /// Text-only button with no border or background - good for low-emphasis links
  text,

  /// Elevated button with shadow - good for the most important actions
  elevated,

  /// Tonal button - good for medium emphasis with colored background
  tonal,
}

class CustomButton extends StatelessWidget {
  final String text;
  final String url;
  final CustomButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final double? iconSize;
  final bool isExternalLink;
  final VoidCallback? onCustomTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.url,
    this.variant = CustomButtonVariant.outlined,
    this.backgroundColor,
    this.textColor,
    this.iconSize = 18,
    this.isExternalLink = true,
    this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uri = Uri.tryParse(url);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Link(
        uri: isExternalLink ? uri : null,
        builder: (context, followLink) => Semantics(
          button: true,
          label: 'Open $text',
          hint: isExternalLink ? 'Opens in external browser' : 'Opens link',
          child: _buildButtonByVariant(theme, followLink),
        ),
      ),
    );
  }

  Widget _buildButtonByVariant(ThemeData theme, VoidCallback? followLink) {
    // Function declaration instead of nullable variable
    void onPressed() {
      if (onCustomTap != null) {
        onCustomTap!();
      }
      if (isExternalLink && followLink != null) {
        followLink();
      } else if (url.isNotEmpty) {
        UrlService.launch(url);
      }
    }

    final commonIcon = Icon(
      isExternalLink ? Icons.open_in_new : Icons.arrow_forward,
      size: iconSize,
    );

    switch (variant) {
      case CustomButtonVariant.outlined:
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: commonIcon,
          label: Text(text),
          style: _getOutlinedStyle(theme),
        );

      case CustomButtonVariant.filled:
        return FilledButton.icon(
          onPressed: onPressed,
          icon: commonIcon,
          label: Text(text),
          style: _getFilledStyle(theme),
        );

      case CustomButtonVariant.text:
        return TextButton.icon(
          onPressed: onPressed,
          icon: commonIcon,
          label: Text(text),
          style: _getTextStyle(theme),
        );

      case CustomButtonVariant.elevated:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: commonIcon,
          label: Text(text),
          style: _getElevatedStyle(theme),
        );

      case CustomButtonVariant.tonal:
        return FilledButton.icon(
          onPressed: onPressed,
          icon: commonIcon,
          label: Text(text),
          style: _getTonalStyle(theme),
        );
    }
  }

  // ==================== Style Configurations ====================

  ButtonStyle _getBaseStyle() {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
      maximumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
    );
  }

  ButtonStyle _getOutlinedStyle(ThemeData theme) {
    return _getBaseStyle().copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) => textColor ?? theme.colorScheme.primary,
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => backgroundColor,
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (states) => BorderSide(color: textColor ?? theme.colorScheme.primary),
      ),
    );
  }

  ButtonStyle _getFilledStyle(ThemeData theme) {
    final color = backgroundColor ?? theme.colorScheme.primary;
    return _getBaseStyle().copyWith(
      foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
      backgroundColor: WidgetStateProperty.all(color),
    );
  }

  ButtonStyle _getTextStyle(ThemeData theme) {
    return _getBaseStyle().copyWith(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) => textColor ?? theme.colorScheme.primary,
      ),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
    );
  }

  ButtonStyle _getElevatedStyle(ThemeData theme) {
    final color = backgroundColor ?? theme.colorScheme.primary;
    return _getBaseStyle().copyWith(
      foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
      backgroundColor: WidgetStateProperty.all(color),
      elevation: WidgetStateProperty.resolveWith<double>(
        (states) => states.contains(WidgetState.pressed) ? 2 : 4,
      ),
    );
  }

  ButtonStyle _getTonalStyle(ThemeData theme) {
    final surfaceColor =
        backgroundColor ?? theme.colorScheme.secondaryContainer;
    final contentColor = textColor ?? theme.colorScheme.onSecondaryContainer;
    return _getBaseStyle().copyWith(
      foregroundColor: WidgetStateProperty.all(contentColor),
      backgroundColor: WidgetStateProperty.all(surfaceColor),
    );
  }
}
