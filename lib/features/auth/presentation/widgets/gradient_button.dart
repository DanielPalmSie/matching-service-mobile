import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final LinearGradient effectiveGradient = gradient ??
        const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

    final isDisabled = onPressed == null || loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDisabled
            ? LinearGradient(
                colors: effectiveGradient.colors
                    .map((c) => c.withOpacity(0.5))
                    .toList(),
                begin: effectiveGradient.begin,
                end: effectiveGradient.end,
              )
            : effectiveGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isDisabled ? null : onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
