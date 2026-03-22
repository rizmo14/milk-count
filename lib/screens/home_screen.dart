import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/feeding_provider.dart';
import '../models/feeding.dart';
import 'add_feeding_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'No feedings yet';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ago';
    return '${minutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Milk Count'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.time),
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ),
      child: SafeArea(
        child: Consumer<FeedingProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                _buildSummaryCard(context, provider),
                const SizedBox(height: 20),

                // Quick Add Buttons
                _buildQuickAddSection(context),
                const SizedBox(height: 20),

                // Today's Feedings
                _buildTodayFeedingsSection(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, FeedingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFA3C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Today's Summary",
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(
                '${provider.todayFeedingCount}',
                'Feedings',
                CupertinoIcons.drop,
              ),
              _summaryItem(
                '${provider.todayTotalMl.toStringAsFixed(0)} ml',
                'Bottle',
                CupertinoIcons.lab_flask,
              ),
              _summaryItem(
                '${provider.todayTotalBreastMinutes} min',
                'Breast',
                CupertinoIcons.heart,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Last feeding: ${_formatDuration(provider.timeSinceLastFeeding)}',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CupertinoColors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.85),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickAddButton(
            context,
            'Bottle',
            CupertinoIcons.lab_flask,
            const Color(0xFF5B9BD5),
            FeedingType.bottle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAddButton(
            context,
            'Breast',
            CupertinoIcons.heart,
            const Color(0xFFFF6B9D),
            FeedingType.breast,
          ),
        ),
      ],
    );
  }

  Widget _quickAddButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    FeedingType type,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => AddFeedingScreen(initialType: type),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              '+ Add $label',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayFeedingsSection(
      BuildContext context, FeedingProvider provider) {
    final todayFeedings = provider.todayFeedings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Feedings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (todayFeedings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.moon_zzz,
                  size: 48,
                  color: CupertinoColors.systemGrey3,
                ),
                const SizedBox(height: 12),
                Text(
                  'No feedings recorded today',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ...todayFeedings.map((feeding) => _feedingTile(context, feeding)),
      ],
    );
  }

  Widget _feedingTile(BuildContext context, Feeding feeding) {
    final timeFormat = DateFormat('h:mm a');
    final isBottle = feeding.type == FeedingType.bottle;

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
                  ? const Color(0xFF5B9BD5).withValues(alpha: 0.1)
                  : const Color(0xFFFF6B9D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBottle ? CupertinoIcons.lab_flask : CupertinoIcons.heart,
              color: isBottle
                  ? const Color(0xFF5B9BD5)
                  : const Color(0xFFFF6B9D),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBottle ? 'Bottle Feeding' : 'Breast Feeding',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBottle
                      ? '${feeding.amountMl?.toStringAsFixed(0)} ml'
                      : '${feeding.durationMinutes} min${feeding.side != null ? ' (${feeding.side!.name})' : ''}',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: const Text('Delete Feeding?'),
                  content:
                      const Text('This action cannot be undone.'),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Delete'),
                      onPressed: () {
                        context
                            .read<FeedingProvider>()
                            .removeFeeding(feeding.id);
                        Navigator.pop(ctx);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.systemGrey3,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
