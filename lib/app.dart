import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maahvi/features/admin/admin_ad_prediction.dart';
import 'package:maahvi/features/admin/admin_dashboard.dart';
import 'package:maahvi/features/admin/admin_login.dart';
import 'package:maahvi/features/admin/admin_result_upload.dart';
import 'package:maahvi/features/admin/admin_vip_manager.dart';
import 'package:maahvi/features/home/home_screen.dart';
import 'package:maahvi/features/result/old_result_screen.dart';
import 'package:maahvi/features/result/result_screen.dart';
import 'package:maahvi/features/state/state_screen.dart';
import 'package:maahvi/features/subscription/vip_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),

        // SEO Friendly URLs with Dynamic Titles (Fixed Const Errors)
        GoRoute(
          path: '/today-result',
          builder: (context, state) => Title(
            title: 'Today Lottery Result - Maahvi Lottery',
            color: Colors.red,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/nagaland-result',
          builder: (context, state) => Title(
            title: 'Nagaland State Lottery Result - Maahvi',
            color: Colors.red,
            child: const StateScreen(stateId: 'nagaland'),
          ),
        ),
        GoRoute(
          path: '/west-bengal-result',
          builder: (context, state) => Title(
            title: 'West Bengal Lottery Result Today - Maahvi',
            color: Colors.red,
            child: const StateScreen(stateId: 'west-bengal'),
          ),
        ),
        GoRoute(
          path: '/kerala-result',
          builder: (context, state) => Title(
            title: 'Kerala Lottery Result Today - Maahvi',
            color: Colors.red,
            child: const StateScreen(stateId: 'kerala'),
          ),
        ),
        GoRoute(
          path: '/dear-prediction',
          builder: (context, state) => Title(
            title: 'Daily Dear Lottery Prediction & Guessing - Maahvi',
            color: Colors.red,
            child: const HomeScreen(),
          ),
        ),

        GoRoute(
            path: '/state/:stateId',
            builder: (context, state) =>
                StateScreen(stateId: state.pathParameters['stateId']!)),
        GoRoute(
            path: '/result/:id',
            builder: (context, state) =>
                ResultScreen(resultId: state.pathParameters['id']!)),
        GoRoute(
            path: '/old-results/:stateId',
            builder: (context, state) =>
                OldResultScreen(stateId: state.pathParameters['stateId']!)),

        // Admin Routes
        GoRoute(
            path: '/admin-login',
            builder: (context, state) => const AdminLogin()),
        GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboard(),
            routes: [
              GoRoute(
                  path: 'upload-result',
                  builder: (context, state) => const AdminResultUpload()),
              GoRoute(
                  path: 'manage-ads',
                  builder: (context, state) => const AdminAdPrediction()),
              GoRoute(
                  path: 'vip-manager',
                  builder: (context, state) => const AdminVipManager()),
            ]),

        GoRoute(path: '/vip', builder: (context, state) => const VipScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Maahvi Lottery Result',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          useMaterial3: true),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
