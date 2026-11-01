import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/inquiries.dart';
import '../../data/mock_data.dart';

class InquiryDetailPage extends ConsumerStatefulWidget {
  const InquiryDetailPage({super.key, required this.inquiryId});

  final String inquiryId;

  @override
  ConsumerState<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends ConsumerState<InquiryDetailPage> {
  String? choice;

  @override
  Widget build(BuildContext context) {
    final inquiry = ref.watch(
      inquiryStoreProvider.select(
        (items) => items.firstWhere((item) => item.id == widget.inquiryId),
      ),
    );
    final listing = listingById(inquiry.listingId);
    final stage = inquiry.stage;

    return Scaffold(
      appBar: AppBackBar(title: '意向交流详情', onBack: () => context.pop()),
      bottomNavigationBar: BottomActionBar(children: _actions(inquiry)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ListingSummary(listing: listing),
          const SizedBox(height: 8),
          Text(
            inquiry.iAmBuyer
                ? '你是购房者，房主回答前两题后，双方再确认是否交换联系方式。'
                : '你是房主，请回答购房者的问题。',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _StageCard(
            index: 1,
            title: '确认房源状态',
            question: '房屋目前是否仍在出售？',
            answeredBy: inquiry.iAmBuyer ? '房主' : '你',
            answer: inquiry.saleStatus,
            state: _stateFor(inquiry, 1),
            options: stage1Options,
            selected: choice,
            onSelect: _select,
          ),
          const SizedBox(height: 12),
          _StageCard(
            index: 2,
            title: '确认议价意愿',
            question: '房屋价格是否可以协商？',
            answeredBy: inquiry.iAmBuyer ? '房主' : '你',
            answer: inquiry.priceAnswer,
            state: _stateFor(inquiry, 2),
            options: stage2Options,
            selected: choice,
            onSelect: _select,
          ),
          const SizedBox(height: 12),
          _StageCard(
            index: 3,
            title: '联系意愿确认',
            question: '是否愿意进一步交换联系方式？',
            answeredBy: '你',
            answer: switch (inquiry.myWilling) {
              true => '愿意',
              false => '暂不愿意',
              null => null,
            },
            otherNote: stage >= 3 && !inquiry.ended
                ? (inquiry.otherWilling == true ? '对方已确认愿意交换' : '对方尚未确认')
                : null,
            state: _stateFor(inquiry, 3),
            options: stage3Options,
            selected: choice,
            onSelect: _select,
          ),
          const SizedBox(height: 12),
          if (inquiry.ended) ...[
            NoticeBox(icon: Icons.info_outline, text: inquiry.endedReason!),
            const SizedBox(height: 12),
          ],
          const NoticeBox(text: '预设回复仅用于确认初步意向，不替代实际房屋核验和交易沟通。'),
        ],
      ),
    );
  }

  void _select(String value) => setState(() => choice = value);

  _StageState _stateFor(Inquiry inquiry, int index) {
    if (index < inquiry.stage || (index == 3 && inquiry.myWilling != null)) {
      return _StageState.answered;
    }
    if (index > inquiry.stage || inquiry.ended) return _StageState.locked;
    return inquiry.myTurn ? _StageState.myTurn : _StageState.waiting;
  }

  List<Widget> _actions(Inquiry inquiry) {
    if (inquiry.ended) {
      return [PrimaryButton(label: '返回意向列表', onPressed: () => context.pop())];
    }
    if (inquiry.stage == 4) {
      return [
        PrimaryButton(
          label: '进入联系方式授权',
          onPressed: () => context.push('/inquiries/${inquiry.id}/consent'),
        ),
      ];
    }
    return [
      SecondaryButton(label: '结束交流', onPressed: () => _confirmEnd(inquiry)),
      PrimaryButton(
        label: inquiry.myTurn ? '确认回复' : '等待对方回复',
        onPressed: inquiry.myTurn ? () => _confirm(inquiry) : null,
      ),
    ];
  }

  void _confirm(Inquiry inquiry) {
    final selected = choice;
    if (selected == null) {
      showTip(context, '请先选择一个回复');
      return;
    }
    ref.read(inquiryStoreProvider.notifier).answer(inquiry.id, selected);
    setState(() => choice = null);
    showTip(context, '已回复「$selected」');
  }

  Future<void> _confirmEnd(Inquiry inquiry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束本次意向交流？'),
        content: const Text('结束后双方都无法继续回复，需要时可从房源详情重新发起。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('结束'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(inquiryStoreProvider.notifier).end(inquiry.id, '你已结束本次意向交流');
    }
  }
}

enum _StageState { answered, myTurn, waiting, locked }

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.title,
    required this.question,
    required this.answeredBy,
    required this.answer,
    required this.state,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.otherNote,
  });

  final int index;
  final String title;
  final String question;
  final String answeredBy;
  final String? answer;
  final _StageState state;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final String? otherNote;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: state == _StageState.locked
                    ? const Color(0xFFB8C4C8)
                    : AppColors.primary,
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...switch (state) {
            _StageState.answered => [
              _Option(
                label: '$answeredBy：${answer ?? ''}',
                checked: true,
                onTap: null,
              ),
            ],
            _StageState.myTurn => [
              for (final option in options) ...[
                _Option(
                  label: option,
                  checked: option == selected,
                  onTap: () => onSelect(option),
                ),
                const SizedBox(height: 8),
              ],
            ],
            _StageState.waiting => [
              const _Hint(icon: Icons.hourglass_empty, text: '等待房主回复'),
            ],
            _StageState.locked => [
              const _Hint(icon: Icons.lock_outline, text: '等待前一题完成'),
            ],
          },
          if (otherNote != null) ...[
            const SizedBox(height: 8),
            _Hint(icon: Icons.person_outline, text: otherNote!),
          ],
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? AppColors.mint : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: checked
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              if (checked) ...[
                const Icon(Icons.check, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: checked ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
