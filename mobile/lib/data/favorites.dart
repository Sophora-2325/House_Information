import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'yghy', 'jxhf', 'ycxq'};

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) {
      next.add(id);
    }
    state = next;
  }
}

final favoriteIdsProvider = NotifierProvider<FavoriteIds, Set<String>>(
  FavoriteIds.new,
);
