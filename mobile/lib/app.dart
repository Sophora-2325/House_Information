import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FangshiApp extends StatelessWidget {
  const FangshiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: '房市直通',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: appRouter,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final width = math.min(media.size.width, 430.0);
          return ColoredBox(
            color: const Color(0xFFD7E4E2),
            child: Center(
              child: SizedBox(
                width: width,
                child: MediaQuery(
                  data: media.copyWith(size: Size(width, media.size.height)),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
