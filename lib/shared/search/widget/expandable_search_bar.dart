import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

final searchStateProvider = StateProvider.autoDispose<bool>((ref) => false);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class ExpandableSearchBar extends ConsumerWidget {
  const ExpandableSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(searchStateProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      // FIX: Instead of 90% width, use a fixed width that fits your AppBar
      // 200-250px is usually the 'sweet spot' for mobile AppBars
      width: isExpanded ? 220.0 : 48.0,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.grey[200] : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              isExpanded ? Icons.arrow_forward_ios : Icons.search,
              size: 20,
              color: isExpanded ? Colors.black54 : null,
            ),
            onPressed: () {
              ref.read(searchStateProvider.notifier).state = !isExpanded;
              if (isExpanded) ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
          if (isExpanded)
            Expanded(
              child: TextField(
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: LocaleKeys.search.tr(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: 12),
                ),
                onSubmitted: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
              ),
            ),
        ],
      ),
    );
  }
}
