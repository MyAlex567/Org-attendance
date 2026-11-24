import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';
import '../atoms/app_chip.dart';

/// One attendance session in the sessions list on the Org Page.
class EventCard extends StatelessWidget {
  final String title;
  final String venue;
  final DateTime startsAt;
  final bool isOpen;

  // Only passed for officers and the admin; members can't read attendance
  // lists (security rules), so their cards show no count.
  final int? attendeeCount;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.venue,
    required this.startsAt,
    required this.isOpen,
    this.attendeeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, h:mm a').format(startsAt);
    final countColor = isOpen ? AppColors.darkGreen : AppColors.muted;

    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        // Keeps the tap ripple inside the card's round corners.
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // Only as tall as its content, not the whole screen.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Takes the leftover space so long titles wrap instead of
                  // pushing the chip off the card.
                  Expanded(
                    child: AppText(text: title, variant: AppTextVariant.subtitle),
                  ),
                  AppChip(
                    text: isOpen ? 'Open' : 'Closed',
                    variant: isOpen ? AppChipVariant.green : AppChipVariant.gray,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppText(text: '$venue · $date', variant: AppTextVariant.caption),
              if (attendeeCount != null) const SizedBox(height: 10),
              if (attendeeCount != null)
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 18, color: countColor),
                    const SizedBox(width: 6),
                    AppText(
                      text: '$attendeeCount attended',
                      variant: AppTextVariant.caption,
                      fontWeight: FontWeight.w600,
                      color: countColor,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
