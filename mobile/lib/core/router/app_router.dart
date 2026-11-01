import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';
import '../../features/contacts/consent_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/inquiries/inquiry_detail_page.dart';
import '../../features/inquiries/inquiry_list_page.dart';
import '../../features/listings/detail_page.dart';
import '../../features/listings/filter_page.dart';
import '../../features/listings/home_page.dart';
import '../../features/listings/my_listings_page.dart';
import '../../features/listings/publish_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/profile/settings_page.dart';
import '../../features/providers/provider_apply_page.dart';
import '../../features/providers/provider_detail_page.dart';
import '../../features/providers/service_list_page.dart';
import '../../features/reports/report_page.dart';
import '../../features/shell/main_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mine',
              builder: (context, state) => const MyListingsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inquiries',
              builder: (context, state) => const InquiryListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/services',
              builder: (context, state) => const ServiceListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'favorites',
                  builder: (context, state) => const FavoritesPage(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/filter',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const FilterPage(),
    ),
    GoRoute(
      path: '/listings/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return ListingDetailPage(listingId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/publish',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PublishPage(),
    ),
    GoRoute(
      path: '/inquiries/:id/consent',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return ConsentPage(inquiryId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/inquiries/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return InquiryDetailPage(inquiryId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/providers/apply',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProviderApplyPage(),
    ),
    GoRoute(
      path: '/providers/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return ProviderDetailPage(agencyId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/reports',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ReportPage(),
    ),
  ],
);
