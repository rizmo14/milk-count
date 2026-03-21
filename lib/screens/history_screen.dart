import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/feeding_provider.dart';
import '../models/feeding.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      if (_selectedDate.isAfter(DateTime.now())) {
        _selectedDate = DateTime.now();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Feeding History'),
      ),
      child: SafeArea(
        child: Consumer<FeedingProvider>(
          builder: (context, provider, _) {
            final feedings = provider.getFeedingsForDate(_selectedDate);
            final dailyMl = feedings
                .where((f) => f.type == FeedingType.bottle)
                .fold(0.0, (sum, f) => sum + (f.amountMl ?? 0));
            final dailyMinutes = feedings
                .where((f) => f.type == FeedingType.breast)
                .fold(0, (sum, f) => sum + (f.durationMinutes ?? 0));

            return Column(
              children: [
                // Date Navigator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: CupertinoColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _changeDate(-1),
                        child: const Icon(CupertinoIcons.chevron_left),
                      ),
                      Text(
                        isToday
                            ? 'Today'
                            : dateFormat.format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: isToday ? null : () => _changeDate(1),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: isToday
                              ? CupertinoColors.systemGrey3
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daily Summary Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryChip(
                          '${feedings.length}', 'feedings', CupertinoIcons.drop),
                      _summaryChip('${dailyMl.toStringAsFixed(0)} ml', 'bottle',
                          CupertinoIcons.lab_flask),
                      _summaryChip('$dailyMinutes min', 'breast',
                          CupertinoIcons.heart),
                    ],
                  ),
                ),

                // Feeding List
                Expanded(
                  child: feedings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.doc_text,
                                size: 48,
                                color: CupertinoColors.systemGrey3,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No feedings recorded',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedings.length,
                          itemBuilder: (context, index) {
                            final feeding = feedings[index];
                            final isBottle =
                                feeding.type == FeedingType.bottle;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isBottle
                                          ? const Color(0xFF5B9BD5)
                                              .withOpacity(0.1)
                                          : const Color(0xFFFF6B9D)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isBottle
                                          ? CupertinoIcons.lab_flask
                                          : CupertinoIcons.heart,
                                      color: isBottle
                                          ? const Color(0xFF5B9BD5)
                                          : const Color(0xFFFF6B9D),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isBottle
                                              ? 'Bottle - ${feeding.amountMl?.toStringAsFixed(0)} ml'
                                              : 'Breast - ${feeding.durationMinutes} min',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (feeding.notes != null &&
                                            feeding.notes!.isNotEmpty)
                                          Text(
                                            feeding.notes!,
                                            style: TextStyle(
                                              color:
                                                  CupertinoColors.systemGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    timeFormat.format(feeding.dateTime),
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryChip(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF6B9D)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
        ),
      ],
    );
  }
}
