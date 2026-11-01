import 'package:flutter_riverpod/flutter_riverpod.dart';

const stage1Options = ['仍在出售', '暂停出售', '已经售出'];
const stage2Options = ['可以协商', '暂不议价'];
const stage3Options = ['愿意', '暂不愿意'];

/// 一次意向交流。前两题由房主回答，第三题双方各自回答。
class Inquiry {
  const Inquiry({
    required this.id,
    required this.listingId,
    required this.iAmBuyer,
    required this.timeLabel,
    this.saleStatus,
    this.priceAnswer,
    this.buyerWilling,
    this.sellerWilling,
    this.endedReason,
  });

  final String id;
  final String listingId;

  /// true：我是发起意向的购房者；false：我是收到意向的房主。
  final bool iAmBuyer;
  final String timeLabel;
  final String? saleStatus;
  final String? priceAnswer;
  final bool? buyerWilling;
  final bool? sellerWilling;
  final String? endedReason;

  bool get ended => endedReason != null;
  bool get bothWilling => buyerWilling == true && sellerWilling == true;

  /// 当前进行到第几题（1–3），双方都同意后为 4。
  int get stage {
    if (saleStatus == null) return 1;
    if (priceAnswer == null) return 2;
    if (bothWilling) return 4;
    return 3;
  }

  bool? get myWilling => iAmBuyer ? buyerWilling : sellerWilling;
  bool? get otherWilling => iAmBuyer ? sellerWilling : buyerWilling;

  bool get myTurn {
    if (ended) return false;
    return switch (stage) {
      1 || 2 => !iAmBuyer,
      3 => myWilling == null,
      _ => false,
    };
  }

  String get progressText {
    if (ended) return endedReason!;
    return switch (stage) {
      1 => iAmBuyer ? '等待房主确认房屋是否仍在出售' : '请确认房屋目前是否仍在出售',
      2 => iAmBuyer ? '等待房主确认价格是否可协商' : '请确认价格是否可以协商',
      3 => myWilling == null ? '请确认是否愿意交换联系方式' : '等待对方确认是否愿意交换联系方式',
      _ => '双方已同意交换联系方式',
    };
  }

  String get statusLabel {
    if (ended) return '已结束';
    if (stage == 4) return '可交换';
    return myTurn ? '待我回复' : '等待对方';
  }

  Inquiry copyWith({
    String? saleStatus,
    String? priceAnswer,
    bool? buyerWilling,
    bool? sellerWilling,
    String? endedReason,
    String? timeLabel,
  }) {
    return Inquiry(
      id: id,
      listingId: listingId,
      iAmBuyer: iAmBuyer,
      timeLabel: timeLabel ?? this.timeLabel,
      saleStatus: saleStatus ?? this.saleStatus,
      priceAnswer: priceAnswer ?? this.priceAnswer,
      buyerWilling: buyerWilling ?? this.buyerWilling,
      sellerWilling: sellerWilling ?? this.sellerWilling,
      endedReason: endedReason ?? this.endedReason,
    );
  }
}

class InquiryStore extends Notifier<List<Inquiry>> {
  @override
  List<Inquiry> build() => const [
    Inquiry(
      id: 'i1',
      listingId: 'yghy',
      iAmBuyer: true,
      timeLabel: '今天 10:24',
      saleStatus: '仍在出售',
      priceAnswer: '可以协商',
      sellerWilling: true,
    ),
    Inquiry(
      id: 'i2',
      listingId: 'jxhf',
      iAmBuyer: true,
      timeLabel: '昨天 16:08',
      saleStatus: '仍在出售',
    ),
    Inquiry(
      id: 'i3',
      listingId: 'ycxq',
      iAmBuyer: false,
      timeLabel: '今天 09:02',
      buyerWilling: true,
    ),
  ];

  Inquiry byId(String id) => state.firstWhere((item) => item.id == id);

  /// 对同一房源只保留一条进行中的意向，重复发起时返回已有的那条。
  String start(String listingId) {
    for (final item in state) {
      if (item.listingId == listingId && item.iAmBuyer && !item.ended) {
        return item.id;
      }
    }
    final id = 'n-$listingId';
    state = [
      Inquiry(id: id, listingId: listingId, iAmBuyer: true, timeLabel: '刚刚'),
      ...state,
    ];
    return id;
  }

  void answer(String id, String option) {
    state = [
      for (final item in state)
        if (item.id == id) _apply(item, option) else item,
    ];
  }

  void end(String id, String reason) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(endedReason: reason, timeLabel: '刚刚')
        else
          item,
    ];
  }

  Inquiry _apply(Inquiry item, String option) {
    final next = switch (item.stage) {
      1 => item.copyWith(saleStatus: option),
      2 => item.copyWith(priceAnswer: option),
      _ =>
        item.iAmBuyer
            ? item.copyWith(buyerWilling: option == '愿意')
            : item.copyWith(sellerWilling: option == '愿意'),
    };
    final ended = switch (item.stage) {
      1 when option != '仍在出售' => '房主表示$option，本次意向已结束',
      3 when option != '愿意' => '已选择暂不交换联系方式，本次意向已结束',
      _ => null,
    };
    return ended == null
        ? next.copyWith(timeLabel: '刚刚')
        : next.copyWith(endedReason: ended, timeLabel: '刚刚');
  }
}

final inquiryStoreProvider = NotifierProvider<InquiryStore, List<Inquiry>>(
  InquiryStore.new,
);
