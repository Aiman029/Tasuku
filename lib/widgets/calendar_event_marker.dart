import 'package:flutter/material.dart';

class CalendarEventMarker extends StatelessWidget {
  final int count;

  const CalendarEventMarker({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 4,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}