import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/feeding_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MilkCountApp());
}

class MilkCountApp extends StatelessWidget {
  const MilkCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedingProvider()..loadFeedings(),
      child: const CupertinoApp(
        title: 'Milk Count',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemPink,
          brightness: Brightness.light,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
