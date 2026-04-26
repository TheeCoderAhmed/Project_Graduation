import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white))
        : Text(label);

    final Widget outlineLabelWidget = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary))
        : Text(label);

    if (isOutlined) {
      return icon != null
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon),
              label: outlineLabelWidget,
              style: _outlineStyle(),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: _outlineStyle(),
              child: outlineLabelWidget,
            );
    }

    return icon != null
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: Icon(icon, size: 18),
            label: labelWidget,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: labelWidget,
          );
  }

  ButtonStyle _outlineStyle() => OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}
