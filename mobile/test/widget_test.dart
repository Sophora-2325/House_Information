import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fangshi_zhitong/app.dart';
import 'package:fangshi_zhitong/core/router/app_router.dart';

void main() {
  setUp(() {
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('HTTP') ||
          message.contains('NetworkImage') ||
          message.contains('SocketException')) {
        return;
      }
      original?.call(details);
    };
  });

  testWidgets('登录页展示品牌与登录按钮', (tester) async {
    await tester.pumpWidget(const FangshiApp());
    await tester.pump();

    expect(find.text('房市直通'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('免费发布 · 免费查看 · 自主联系'), findsOneWidget);
  });

  testWidgets('核心页面可以打开', (tester) async {
    await tester.pumpWidget(const FangshiApp());
    await tester.pump();

    appRouter.go('/listings/yghy');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('房源详情'), findsOneWidget);
    expect(find.text('发布者：房主'), findsOneWidget);
    expect(find.text('1/6'), findsOneWidget);

    appRouter.go('/inquiries/i1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('意向交流详情'), findsOneWidget);
    expect(find.text('愿意'), findsOneWidget);

    appRouter.go('/services');
    await tester.pump();
    expect(find.text('其他咨询'), findsOneWidget);

    appRouter.go('/mine');
    await tester.pump();
    expect(find.text('草稿'), findsOneWidget);

    appRouter.go('/profile/settings');
    await tester.pump();
    expect(find.text('注销账户'), findsOneWidget);
  });

  testWidgets('发布页必填项未填写时不能提交', (tester) async {
    await tester.pumpWidget(const FangshiApp());
    await tester.pump();

    appRouter.go('/publish');
    await tester.pumpAndSettle();

    await tester.tap(find.text('提交审核'));
    await tester.pump();

    expect(find.text('请选择区域'), findsWidgets);
    expect(find.text('请输入小区名称'), findsWidgets);
    expect(find.text('发布房源'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextFormField, '请选择区域').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('海淀区'));
    await tester.pumpAndSettle();

    final decorator = tester.widget<InputDecorator>(
      find.descendant(
        of: find.widgetWithText(TextFormField, '海淀区'),
        matching: find.byType(InputDecorator),
      ),
    );
    expect(decorator.decoration.errorText, isNull);
  });

  testWidgets('区域下拉框可以弹出并选中', (tester) async {
    await tester.pumpWidget(const FangshiApp());
    await tester.pump();

    appRouter.go('/publish');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextFormField, '请选择区域'));
    await tester.pumpAndSettle();
    expect(find.text('海淀区'), findsOneWidget);

    await tester.tap(find.text('海淀区'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '海淀区'), findsOneWidget);
  });

  testWidgets('购房者在等待房主时看不到可选答案', (tester) async {
    await tester.pumpWidget(const FangshiApp());
    await tester.pump();

    appRouter.go('/inquiries/i2');
    await tester.pumpAndSettle();

    expect(find.text('等待房主回复'), findsOneWidget);
    expect(find.text('可以协商'), findsNothing);
    expect(find.text('等待对方回复'), findsOneWidget);
  });
}
