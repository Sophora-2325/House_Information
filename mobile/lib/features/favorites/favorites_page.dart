import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/favorites.dart';
import '../../data/mock_data.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteIdsProvider);
    final items = allListings.where((item) => ids.contains(item.id)).toList();

    return Scaffold(
      appBar: AppBackBar(title: '我的收藏', onBack: () => context.pop()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          Row(
            children: [
              Text(
                '已收藏 ${items.length} 条房源',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Text(
                '最近收藏优先',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  '还没有收藏，去首页看看房源吧',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          for (final listing in items) ...[
            ListingCard(
              listing: listing,
              subtitle: '${listing.district} · ${listing.confirmedLabel}',
              onTap: () => context.push('/listings/${listing.id}'),
            ),
            const SizedBox(height: 12),
          ],
          if (items.isNotEmpty)
            const NoticeBox(text: '收藏并不代表房源仍在出售，请以最近确认的房源状态为准。'),
        ],
      ),
    );
  }
}
