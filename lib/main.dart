import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:maahvi/app.dart';
import 'package:maahvi/features/home/home_viewmodel.dart';
import 'package:maahvi/features/state/state_viewmodel.dart';
import 'package:maahvi/features/result/result_viewmodel.dart';
import 'package:maahvi/features/subscription/vip_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // URL থেকে # রিমুভ করার জন্য (SEO এর জন্য খুব গুরুত্বপূর্ণ)
  usePathUrlStrategy();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => StateViewModel()),
        ChangeNotifierProvider(create: (_) => ResultViewModel()),
        ChangeNotifierProvider(create: (_) => VipViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
