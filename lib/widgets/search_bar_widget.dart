import 'package:flutter/material.dart';
import '../config/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool readOnly;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool autoFocus;

  const SearchBarWidget({
    super.key,
    required this.onTap,
    this.readOnly = true,
    this.onChanged,
    this.controller,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: readOnly ? onTap : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: readOnly
                      ? const Text(
                          'Search your screenshots...',
                          style: AppTheme.bodyLarge,
                        )
                      : TextField(
                          controller: controller,
                          onChanged: onChanged,
                          autofocus: autoFocus,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search your screenshots...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            fillColor: Colors.transparent,
                          ),
                        ),
                ),
                if (!readOnly && (controller?.text.isNotEmpty ?? false))
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () {
                      controller?.clear();
                      onChanged?.call('');
                    },
                  ),
                if (readOnly) const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
