import 'package:abideverse/shared/search/widget/expandable_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

// The actual TextField that appears in place of the Title
class SearchTextFieldWidget extends ConsumerWidget {
  const SearchTextFieldWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: LocaleKeys.search.tr(),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          // Update your search provider here
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }
}

// The Icon button that toggles the search mode
class SearchIconToggle extends ConsumerWidget {
  const SearchIconToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearching = ref.watch(searchStateProvider);

    return IconButton(
      icon: Icon(isSearching ? Icons.close : Icons.search),
      onPressed: () {
        ref.read(searchStateProvider.notifier).state = !isSearching;
        if (isSearching) {
          ref.read(searchQueryProvider.notifier).state = ''; // Clear on close
        }
      },
    );
  }
}
