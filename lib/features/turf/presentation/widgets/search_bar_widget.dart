import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SearchBarWidget({super.key, required this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dark500, width: 0.8),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppTheme.white, fontFamily: 'Outfit'),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search turfs by name or area…',
          hintStyle: TextStyle(
            color: AppTheme.neutralGrey.withValues(alpha: 0.7),
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.neutralGrey, size: 20),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.neutralGrey, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
