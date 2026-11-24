import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/validators.dart';
import '../atoms/app_button.dart';
import '../molecules/app_text_field.dart';

/// Title, venue and start date/time fields with a "Create event" button.
/// The page decides what happens on submit, so this form never talks to Firebase.
class EventForm extends StatefulWidget {
  final void Function(String title, String venue, DateTime startsAt) onSubmit;
  final bool isLoading;

  const EventForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  // Only shows the picked date as text; the real value is kept in _startsAt.
  final _startsAtController = TextEditingController();
  DateTime? _startsAt;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _startsAtController.dispose();
    super.dispose();
  }

  Future<void> _pickStartsAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day), // no past days
      lastDate: DateTime(now.year + 1),
    );
    // Stop if the user cancelled, or left the screen while the picker was open.
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (time == null) return;

    final startsAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _startsAt = startsAt;
      _startsAtController.text =
          DateFormat('MMM d, y • h:mm a').format(startsAt);
    });
  }

  String? _validateStartsAt(String? value) {
    final error = Validators.requiredField(value, 'Start date and time');
    if (error != null) return error;

    // The time picker can't block past times, so check here. Comparing to the
    // start of the current minute lets the officer pick "right now".
    final now = DateTime.now();
    final thisMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (_startsAt!.isBefore(thisMinute)) {
      return "Start time can't be in the past";
    }
    return null;
  }

  void _submit() {
    // The date field only passes validation after a date is picked,
    // so _startsAt can't be null here.
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text.trim(),
        _venueController.text.trim(),
        _startsAt!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _titleController,
            label: 'Event title',
            validator: (value) => Validators.requiredField(value, 'Event title'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _venueController,
            label: 'Venue',
            validator: (value) => Validators.requiredField(value, 'Venue'),
          ),
          const SizedBox(height: 16),
          // Taps go to the picker instead of the text field, so no keyboard opens.
          GestureDetector(
            onTap: _pickStartsAt,
            child: AbsorbPointer(
              child: AppTextField(
                controller: _startsAtController,
                label: 'Start date and time',
                validator: _validateStartsAt,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Create event',
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
