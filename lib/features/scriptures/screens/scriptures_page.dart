// lib/features/scriptures/screens/scriptures_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/features/scriptures/widgets/scripture_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/models/sort_order.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class ScripturesPage extends StatefulWidget {
  final String locale;

  const ScripturesPage({
    super.key,
    this.locale = LocaleConstants.defaultLocale,
  });

  @override
  State<ScripturesPage> createState() => _ScripturesPageState();
}

class _ScripturesPageState extends State<ScripturesPage> {
  late final ScriptureRepository repository;
  List<Scripture> scriptures = [];
  List<Scripture> filteredItems = [];
  bool isLoading = true;
  bool isSearchInitial = true;

  final TextEditingController _searchController = TextEditingController();

  SortOrder sortOrder = SortOrder.asc; // default sort order

  @override
  void initState() {
    super.initState();
    repository = ScriptureRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);

    _loadAndSortScriptures();

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScripturesPage',
        'abideverse_screen_class': 'ScripturesPageClass',
      },
    );
  }

  /// Load and sort scriptures based on the current sortOrder
  Future<void> _loadAndSortScriptures() async {
    setState(() => isLoading = true);
    final data = await repository.getScriptures(order: sortOrder);
    setState(() {
      scriptures = data;
      // apply current search query if any
      filteredItems = _applyFilter(data, _searchController.text);
      isLoading = false;
    });
  }

  /// Toggle between ascending/descending sort order
  Future<void> _toggleSortOrder() async {
    setState(() {
      sortOrder = sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    });

    await _loadAndSortScriptures();
  }

  /// Applies search filtering
  List<Scripture> _applyFilter(List<Scripture> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.scriptureName.toLowerCase().contains(q) ||
          s.scriptureVerse.toLowerCase().contains(q);
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = _applyFilter(scriptures, _searchController.text);
      isSearchInitial = _searchController.text.isEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredItems = scriptures;
      isSearchInitial = true;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.bibleVerse.tr()),
        actions: [
          IconButton(
            icon: Icon(
              sortOrder == SortOrder.asc
                  ? Icons.arrow_circle_down
                  : Icons.arrow_circle_up,
            ),
            tooltip: sortOrder == SortOrder.asc
                ? LocaleKeys.sortDesc.tr()
                : LocaleKeys.sortAsc.tr(),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (assumes you have a SearchBar widget in your project)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: LocaleKeys.search.tr(),
              onTap: () => setState(() => isSearchInitial = false),
              leading: IconButton(
                icon: isSearchInitial
                    ? const Icon(Icons.search)
                    : const Icon(Icons.arrow_back),
                onPressed: _clearSearch,
              ),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ),

          // List of Scriptures
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) => ScriptureListItem(
                scripture: filteredItems[index],
                index: index,
                onTap: () {
                  context.push(
                    '/scriptures/scripture/${filteredItems[index].articleId}',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
