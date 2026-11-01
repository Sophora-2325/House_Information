import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/inquiries.dart';
import '../../data/mock_data.dart';

class InquiryListPage extends ConsumerStatefulWidget {
  const InquiryListPage({super.key});

  @override
  ConsumerState<InquiryListPage> createState() => _InquiryListPageState();
}

class _InquiryListPageState extends ConsumerState<InquiryListPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(inquiryStoreProvider);
    final outgoing = all.where((item) => item.iAmBuyer).length;
    final incoming = all.length - outgoing;
    final items = all
        .where((item) => tab == 0 ? item.iAmBuyer : !item.iAmBuyer)
        .toList();

    return Scaffold(
      appBar: AppBackBar(title: '意向交流', onBack: () => context.go('/home')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Tab(
                  label: '我发起的（$outgoing）',
                  selected: tab == 0,
                  onTap: () => setState(() => tab = 0),
                ),
                _Tab(
                  label: '我收到的（$incoming）',
                  selected: tab == 1,
                  onTap: () => setState(() => tab = 1),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      tab == 0 ? '还没有发起意向，可从房源详情发起交流' : '还没有收到意向',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _InquiryCard(inquiry: items[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  const _InquiryCard({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final listing = listingById(inquiry.listingId);
    final tone = inquiry.ended
        ? StatusTone.muted
        : inquiry.myTurn
        ? StatusTone.warning
        : StatusTone.success;
    return ShadowCard(
      onTap: () => context.push('/inquiries/${inquiry.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListingImage(url: listing.images.first, width: 96, height: 76),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.community,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    StatusPill(inquiry.statusLabel, tone: tone),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${listing.rooms} · ${listing.area}㎡ · ${listing.price}万',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  inquiry.progressText,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  inquiry.timeLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
