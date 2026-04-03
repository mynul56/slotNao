import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/turf_entity.dart';

class SlotGrid extends StatefulWidget {
  final List<SlotEntity> slots;
  final String turfId;
  const SlotGrid({super.key, required this.slots, required this.turfId});

  @override
  State<SlotGrid> createState() => _SlotGridState();
}

class _SlotGridState extends State<SlotGrid> {
  String? _selectedSlotId;

  @override
  void didUpdateWidget(covariant SlotGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedSlotId == null) return;

    final selected = widget.slots.where((slot) => slot.id == _selectedSlotId);
    if (selected.isEmpty || !selected.first.isAvailable) {
      _selectedSlotId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selected slot is no longer available. Please choose another slot.')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: const Center(
          child: Text('No slots available for this date', style: TextStyle(color: AppTheme.neutralGrey)),
        ),
      );
    }
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: widget.slots.length,
          itemBuilder: (_, i) {
            final slot = widget.slots[i];
            final isSelected = slot.id == _selectedSlotId;
            final isAvailable = slot.isAvailable;
            return GestureDetector(
              onTap: isAvailable ? () => setState(() => _selectedSlotId = slot.id) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : isAvailable
                      ? AppTheme.dark600
                      : AppTheme.dark700,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : isAvailable
                        ? AppTheme.dark500
                        : AppTheme.dark600,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot.startTime.toDisplayTime(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.dark900
                            : isAvailable
                            ? AppTheme.white
                            : AppTheme.dark500,
                      ),
                    ),
                    if (!isAvailable) const Text('Booked', style: TextStyle(fontSize: 9, color: AppTheme.dark500)),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedSlotId != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final slot = widget.slots.firstWhere((s) => s.id == _selectedSlotId);
              if (!slot.isAvailable) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('This slot just got booked. Pick another one.')));
                setState(() => _selectedSlotId = null);
                return;
              }
              context.push('/home/turf/${widget.turfId}/book', extra: slot);
            },
            icon: const Icon(CupertinoIcons.sportscourt_fill, size: 18),
            label: Text('Book Selected Slot  •  ৳${widget.slots.firstWhere((s) => s.id == _selectedSlotId).price.toInt()}'),
          ),
        ],
      ],
    );
  }
}
