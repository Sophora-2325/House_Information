import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/favorites.dart';
import '../../data/inquiries.dart';
import '../../data/mock_data.dart';

class ListingDetailPage extends ConsumerStatefulWidget {
  const ListingDetailPage({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends ConsumerState<ListingDetailPage> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = listingById(widget.listingId);
    final saved = ref.watch(favoriteIdsProvider).contains(listing.id);
    final closed = listing.mineStatus == '已下架';

    return Scaffold(
      appBar: AppBackBar(title: '房源详情', onBack: () => context.pop()),
      bottomNavigationBar: BottomActionBar(
        children: [
          SecondaryButton(
            label: saved ? '已收藏' : '收藏',
            icon: saved ? Icons.favorite : Icons.favorite_border,
            foreground: AppColors.primary,
            onPressed: () =>
                ref.read(favoriteIdsProvider.notifier).toggle(listing.id),
          ),
          PrimaryButton(
            label: '发起意向交流',
            onPressed: closed
                ? null
                : () {
                    final id = ref
                        .read(inquiryStoreProvider.notifier)
                        .start(listing.id);
                    showTip(context, '已向房主发起意向，等待房主回复');
                    context.push('/inquiries/$id');
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: listing.images.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      return ListingImage(
                        url: listing.images[index],
                        height: 220,
                        radius: 0,
                      );
                    },
                  ),
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _CircleIcon(
                        icon: Icons.chevron_left,
                        onTap: _previous,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Row(
                      children: [
                        _CircleIcon(
                          icon: Icons.ios_share,
                          onTap: () => showTip(context, '原型不提供分享'),
                        ),
                        const SizedBox(width: 8),
                        _CircleIcon(
                          icon: saved ? Icons.favorite : Icons.favorite_border,
                          onTap: () => ref
                              .read(favoriteIdsProvider.notifier)
                              .toggle(listing.id),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_index + 1}/${listing.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PriceText(listing.price, size: 32),
              const Spacer(),
              StatusPill(
                '${closed ? '已下架' : '在售'} · ${listing.confirmedShort}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            listing.community,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                listing.cityLine,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '发布者：${listing.publisherType}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          WhiteCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              children: [
                _Spec(value: listing.rooms, label: '户型'),
                _Spec(value: '${listing.area}㎡', label: '建筑面积'),
                _Spec(value: listing.floorLabel, label: '楼层'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('房屋介绍'),
          Text(
            listing.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const NoticeBox(
            icon: Icons.info_outline,
            text: '平台未对房屋产权和实地状况进行专业核验。',
          ),
        ],
      ),
    );
  }

  void _previous() {
    final listing = listingById(widget.listingId);
    final next = (_index - 1 + listing.images.length) % listing.images.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
