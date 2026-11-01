import 'package:fangshi_zhitong/data/inquiries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late InquiryStore store;

  setUp(() {
    container = ProviderContainer();
    store = container.read(inquiryStoreProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('购房者新发起的意向要等房主先回答', () {
    final id = store.start('xcyy');
    final inquiry = store.byId(id);

    expect(inquiry.stage, 1);
    expect(inquiry.myTurn, isFalse);
    expect(inquiry.progressText, '等待房主确认房屋是否仍在出售');
  });

  test('同一房源重复发起返回已有意向', () {
    expect(store.start('yghy'), 'i1');
  });

  test('房主逐题回答，双方都愿意后可以交换联系方式', () {
    expect(store.byId('i3').myTurn, isTrue);

    store.answer('i3', '仍在出售');
    expect(store.byId('i3').stage, 2);

    store.answer('i3', '可以协商');
    expect(store.byId('i3').stage, 3);
    expect(store.byId('i3').myTurn, isTrue);

    store.answer('i3', '愿意');
    expect(store.byId('i3').bothWilling, isTrue);
    expect(store.byId('i3').stage, 4);
  });

  test('只有一方愿意时还不能交换', () {
    final id = store.start('xcyy');
    store.answer(id, '仍在出售');
    store.answer(id, '可以协商');
    store.answer(id, '愿意');

    final inquiry = store.byId(id);
    expect(inquiry.stage, 3);
    expect(inquiry.bothWilling, isFalse);
    expect(inquiry.myTurn, isFalse);
  });

  test('房源已售出或暂不愿意时意向结束', () {
    store.answer('i3', '已经售出');
    expect(store.byId('i3').ended, isTrue);

    store.answer('i1', '暂不愿意');
    expect(store.byId('i1').ended, isTrue);
    expect(store.byId('i1').bothWilling, isFalse);
  });
}
