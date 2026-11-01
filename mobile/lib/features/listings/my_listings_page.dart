import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/mock_data.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  static const tabs = ['全部', '展示中', '待审核', '草稿', '已下架'];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final items = index == 0
        ? myListings
        : myListings.where((item) => item.mineStatus == tabs[index]).toList();

    return Scaffold(
      appBar: AppBackBar(title: '我的房源', onBack: () => context.go('/home')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push('/publish'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('发布新房源'),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 18),
              itemBuilder: (context, tabIndex) {
                final selected = tabIndex == index;
                return InkWell(
                  onTap: () => setState(() => index = tabIndex),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tabs[tabIndex],
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 28,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: items.length + 1,
              separatorBuilder: (context, itemIndex) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, itemIndex) {
                if (itemIndex == items.length) {
                  return const NoticeBox(text: '房源有效期30天，需按期确认在售状态，续期免费。');
                }
                return _MineCard(listing: items[itemIndex]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MineCard extends StatelessWidget {
  const _MineCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final status = listing.mineStatus ?? '展示中';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B2A32),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push('/listings/${listing.id}'),
            child: Row(
              children: [
                ListingImage(url: listing.images.first, width: 108, height: 80),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.community,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listing.rooms} · ${listing.area}㎡',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PriceText(listing.price, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusPill(status, tone: toneOf(status)),
              const Spacer(),
              Text(
                listing.mineHint ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _actions(context, status),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, String status) {
    return switch (status) {
      '展示中' => Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: '编辑',
              onPressed: () => context.push('/publish'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SecondaryButton(
              label: '确认在售',
              onPressed: () => showTip(context, '已确认在售，有效期将续期（原型）'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              label: '下架',
              onPressed: () => showTip(context, '已下架（原型）'),
            ),
          ),
        ],
      ),
      '待审核' => Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: '查看',
              onPressed: () => context.push('/listings/${listing.id}'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SecondaryButton(
              label: '编辑草稿',
              onPressed: () => context.push('/publish'),
            ),
          ),
        ],
      ),
      '草稿' => Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: '继续编辑',
              onPressed: () => context.push('/publish'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              label: '提交审核',
              onPressed: () => showTip(context, '草稿已提交审核（原型）'),
            ),
          ),
        ],
      ),
      _ => Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: '查看',
              onPressed: () => context.push('/listings/${listing.id}'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SecondaryButton(
              label: '重新发布',
              onPressed: () => context.push('/publish'),
            ),
          ),
        ],
      ),
    };
  }
}
