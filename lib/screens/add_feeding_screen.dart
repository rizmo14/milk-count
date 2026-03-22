import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/feeding.dart';
import '../providers/feeding_provider.dart';

class AddFeedingScreen extends StatefulWidget {
  final FeedingType initialType;

  const AddFeedingScreen({super.key, required this.initialType});

  @override
  State<AddFeedingScreen> createState() => _AddFeedingScreenState();
}

class _AddFeedingScreenState extends State<AddFeedingScreen> {
  late FeedingType _type;
  double _amountMl = 60;
  int _durationMinutes = 15;
  BreastSide _side = BreastSide.left;
  DateTime _dateTime = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final feeding = Feeding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: _dateTime,
      type: _type,
      amountMl: _type == FeedingType.bottle ? _amountMl : null,
      durationMinutes: _type == FeedingType.breast ? _durationMinutes : null,
      side: _type == FeedingType.breast ? _side : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    context.read<FeedingProvider>().addFeeding(feeding);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Log Feeding'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Feeding Type Selector
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Amount or Duration
            if (_type == FeedingType.bottle)
              _buildBottleInput()
            else
              _buildBreastInput(),
            const SizedBox(height: 24),

            // Date & Time
            _buildDateTimePicker(),
            const SizedBox(height: 24),

            // Notes
            _buildNotesField(),
            const SizedBox(height: 32),

            // Save Button
            CupertinoButton.filled(
              onPressed: _save,
              borderRadius: BorderRadius.circular(14),
              child: const Text(
                'Save Feeding',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return CupertinoSlidingSegmentedControl<FeedingType>(
      groupValue: _type,
      children: const {
        FeedingType.bottle: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Bottle', style: TextStyle(fontSize: 16)),
        ),
        FeedingType.breast: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Breast', style: TextStyle(fontSize: 16)),
        ),
      },
      onValueChanged: (value) {
        if (value != null) setState(() => _type = value);
      },
    );
  }

  Widget _buildBottleInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${_amountMl.toStringAsFixed(0)} ml',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B9BD5),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoSlider(
            value: _amountMl,
            min: 5,
            max: 300,
            divisions: 59,
            activeColor: const Color(0xFF5B9BD5),
            onChanged: (value) => setState(() => _amountMl = value),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5 ml', style: TextStyle(color: CupertinoColors.systemGrey)),
              Text('300 ml',
                  style: TextStyle(color: CupertinoColors.systemGrey)),
            ],
          ),
          const SizedBox(height: 16),
          // Quick amount buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [30, 60, 90, 120, 150]
                .map((ml) => CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      color: _amountMl == ml.toDouble()
                          ? const Color(0xFF5B9BD5)
                          : const Color(0xFF5B9BD5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      minimumSize: Size.zero,
                      onPressed: () =>
                          setState(() => _amountMl = ml.toDouble()),
                      child: Text(
                        '${ml}ml',
                        style: TextStyle(
                          color: _amountMl == ml.toDouble()
                              ? CupertinoColors.white
                              : const Color(0xFF5B9BD5),
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreastInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$_durationMinutes min',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoSlider(
            value: _durationMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            activeColor: const Color(0xFFFF6B9D),
            onChanged: (value) =>
                setState(() => _durationMinutes = value.round()),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 min',
                  style: TextStyle(color: CupertinoColors.systemGrey)),
              Text('60 min',
                  style: TextStyle(color: CupertinoColors.systemGrey)),
            ],
          ),
          const SizedBox(height: 20),
          // Breast side selector
          const Text(
            'Side',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          CupertinoSlidingSegmentedControl<BreastSide>(
            groupValue: _side,
            children: const {
              BreastSide.left: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Left'),
              ),
              BreastSide.right: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Right'),
              ),
              BreastSide.both: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Both'),
              ),
            },
            onValueChanged: (value) {
              if (value != null) setState(() => _side = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date & Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _dateTime,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (value) => setState(() => _dateTime = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes (optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _notesController,
            placeholder: 'Add any notes...',
            maxLines: 3,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
