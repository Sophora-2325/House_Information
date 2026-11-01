import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/favorites.dart';
import '../../data/mock_data.dart';
import '../theme/app_colors.dart';

void showTip(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

class AppBackBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBackBar({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.chevron_left, size: 28),
      ),
      titleSpacing: 0,
      title: Text(title),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foreground,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = foreground ?? AppColors.textPrimary;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD5DEE2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceWrap extends StatelessWidget {
  const ChoiceWrap({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoicePill(
            label: option,
            selected: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : AppColors.chip,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.options,
    this.pickerTitle,
    this.maxLines = 1,
    this.keyboardType,
    this.requiredMessage,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;

  /// 非空时为下拉选择框，点击弹出底部选项。
  final List<String>? options;
  final String? pickerTitle;
  final int maxLines;
  final TextInputType? keyboardType;

  /// 非空时为必填项，未填写显示该提示。
  final String? requiredMessage;
  final VoidCallback? onChanged;

  bool get _isDropdown => options != null;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.line),
    );
    return TextFormField(
      controller: controller,
      readOnly: _isDropdown,
      onTap: _isDropdown ? () => _pick(context) : null,
      onChanged: onChanged == null ? null : (_) => onChanged!(),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: requiredMessage == null
          ? null
          : (value) => (value == null || value.trim().isEmpty)
                ? requiredMessage
                : null,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9AA7AC), fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: _isDropdown
            ? const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final current = controller?.text;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    pickerTitle ?? hint,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final option in options!)
                        ListTile(
                          title: Text(option),
                          trailing: option == current
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, option),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null && controller != null) {
      controller!.text = picked;
      onChanged?.call();
    }
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 12,
  });

  final String url;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.mint,
      alignment: Alignment.center,
      child: const Icon(Icons.apartment, color: AppColors.primary),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone = StatusTone.success});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      StatusTone.success => (AppColors.successBg, AppColors.successText),
      StatusTone.warning => (AppColors.amberBg, AppColors.amberText),
      StatusTone.muted => (AppColors.chip, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum StatusTone { success, warning, muted }

StatusTone toneOf(String status) {
  return switch (status) {
    '待审核' || '待回复' || '草稿' => StatusTone.warning,
    '已下架' => StatusTone.muted,
    _ => StatusTone.success,
  };
}

class PriceText extends StatelessWidget {
  const PriceText(this.price, {super.key, this.size = 22});

  final int price;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$price万',
      style: TextStyle(
        color: AppColors.price,
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
  }
}

/// 白底圆角卡片，阴影画在卡片外侧，点击水波纹不会被遮住。
class ShadowCard extends StatelessWidget {
  const ShadowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B2A32),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class ListingCard extends ConsumerWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.subtitle,
    this.extra,
    this.showFavorite = true,
    this.showStatus = true,
  });

  final Listing listing;
  final VoidCallback onTap;
  final String? subtitle;
  final String? extra;
  final bool showFavorite;
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(favoriteIdsProvider).contains(listing.id);
    return ShadowCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListingImage(url: listing.images.first, width: 112, height: 84),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showFavorite)
                      InkWell(
                        onTap: () => ref
                            .read(favoriteIdsProvider.notifier)
                            .toggle(listing.id),
                        child: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: saved
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? '${listing.district} · ${listing.nearby}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${listing.rooms} · ${listing.area}㎡ · ${listing.floorLabel}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    extra!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    PriceText(listing.price),
                    const Spacer(),
                    if (showStatus) const StatusPill('在售'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListingSummary extends StatelessWidget {
  const ListingSummary({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          ListingImage(url: listing.images.first, width: 92, height: 72),
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
                const SizedBox(height: 4),
                PriceText(listing.price, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.active, this.labels});

  final int active;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= active
                        ? AppColors.primary
                        : const Color(0xFFDCE3E6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (labels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < labels!.length; i++)
                Expanded(
                  child: Text(
                    labels![i],
                    style: TextStyle(
                      fontSize: 12,
                      color: i == active
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: i == active
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
