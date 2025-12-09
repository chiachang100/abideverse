import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/features/joys/widgets/joy_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/models/sort_order.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class JoysPage extends StatefulWidget {
  final String locale;

  const JoysPage({super.key, this.locale = LocaleConstants.defaultLocale});

  @override
  State<JoysPage> createState() => _JoysPageState();
}

class _JoysPageState extends State<JoysPage> {
  late JoyRepository repository;
  List<Joy> joys = [];
  List<Joy> filteredItems = [];
  bool isLoading = true;
  bool isSearchInitial = true;

  final TextEditingController _searchController = TextEditingController();

  SortOrder sortOrder = SortOrder.asc;

  @override
  void initState() {
    super.initState();
    repository = JoyRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);
    _loadAndSortJoys();

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'JoysPage',
        'abideverse_screen_class': 'JoysPageClass',
      },
    );
  }

  Future<void> _loadAndSortJoys() async {
    setState(() => isLoading = true);
    final data = await repository.getJoys(order: sortOrder);
    setState(() {
      joys = data;
      // apply current search query if any
      filteredItems = _applyFilter(data, _searchController.text);
      isLoading = false;
    });
  }

  Future<void> _toggleSortOrder() async {
    setState(() {
      sortOrder = sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    });
    await _loadAndSortJoys();
  }

  List<Joy> _applyFilter(List<Joy> items, String query) {
    query = query.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((joy) {
      return joy.title.toLowerCase().contains(query) ||
          joy.prelude.toLowerCase().contains(query) ||
          joy.laugh.toLowerCase().contains(query) ||
          joy.scriptureName.toLowerCase().contains(query) ||
          joy.scriptureVerse.toLowerCase().contains(query) ||
          joy.videoName.toLowerCase().contains(query) ||
          joy.talk.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = _applyFilter(joys, _searchController.text);
      isSearchInitial = _searchController.text.isEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredItems = joys;
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
        title: Text(LocaleKeys.joys.tr()),
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
          // Search Bar
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

          // List of Joys
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) => JoyListItem(
                joy: filteredItems[index],
                index: index,
                onTap: () {
                  context.push('/joys/joy/${filteredItems[index].articleId}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
