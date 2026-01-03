// lib/features/scriptures/screens/scriptures_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/features/scriptures/widgets/scripture_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/config/app_config.dart';
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

  final ScrollController _scrollController = ScrollController();

  List<Scripture> scriptures = [];
  List<Scripture> filteredItems = [];
  bool isLoading = true;
  bool isSearchInitial = true;

  final TextEditingController _searchController = TextEditingController();

  SortOrder sortOrder = SortOrder.asc; // default sort order
  Set<String> likedScriptureIds = {}; // Stores articleIds of liked items
  bool showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    repository = ScriptureRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);

    _loadAndSortScriptures(shuffle: true);
    _loadLikes(); // Load saved likes from disk

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScripturesPage',
        'abideverse_screen_class': 'ScripturesPageClass',
      },
    );
  }

  /// Load and sort scriptures based on the current sortOrder
  Future<void> _loadAndSortScriptures({bool shuffle = false}) async {
    setState(() => isLoading = true);
    final data = await repository.getScriptures(
      order: sortOrder,
      shuffle: shuffle,
    );
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

    // FORCE scroll to top AFTER rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        //_scrollController.jumpTo(0.0);
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Applies search filtering
  List<Scripture> _applyFilter(List<Scripture> items, String query) {
    final q = query.trim().toLowerCase();
    return items.where((scripture) {
      // 1. Check Favorites Filter
      if (showOnlyFavorites &&
          !likedScriptureIds.contains(scripture.articleId.toString())) {
        return false;
      }

      // 2. Check Search Query
      if (query.isEmpty) return true;

      return scripture.articleId.toString().contains(q) ||
          scripture.title.toLowerCase().contains(q) ||
          scripture.scriptureName.toLowerCase().contains(q) ||
          scripture.scriptureChapter.toLowerCase().contains(q) ||
          scripture.scriptureVerse.toLowerCase().contains(q) ||
          scripture.zhCNScriptureVerse.toLowerCase().contains(q);
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
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Load from Local Storage
  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // SharedPreferences returns a List, we convert to Set for performance
      likedScriptureIds = (prefs.getStringList('liked_scriptures') ?? [])
          .toSet();
    });
  }

  // Toggle and Save to Local Storage
  Future<void> _toggleLike(String scriptureId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (likedScriptureIds.contains(scriptureId)) {
        likedScriptureIds.remove(scriptureId);
      } else {
        likedScriptureIds.add(scriptureId);
      }

      // Refresh the list immediately so un-liked items disappear
      // if showOnlyFavorites is true
      filteredItems = _applyFilter(scriptures, _searchController.text);
    });

    // Persist the updated list
    await prefs.setStringList('liked_scriptures', likedScriptureIds.toList());

    // Future Firebase hook:
    // if (userIsLoggedIn) { await updateFirebase(scriptureId, isLiked); }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.bibleVerse.tr()),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                Routes(context).goJoys();
              },
            );
          },
        ),
        actions: [
          // Favorites Filter Toggle
          IconButton(
            icon: Icon(
              showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: showOnlyFavorites ? Colors.red : null,
            ),
            tooltip: LocaleKeys.showFavorites.tr(),
            onPressed: () {
              setState(() {
                showOnlyFavorites = !showOnlyFavorites;
                // Re-run the filter with the new state
                filteredItems = _applyFilter(
                  scriptures,
                  _searchController.text,
                );
              });
            },
          ),
          // Sort Toggle
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
            child: RefreshIndicator(
              onRefresh: () => _loadAndSortScriptures(shuffle: true),
              color: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              child: ListView.builder(
                // The physics must allow scrolling for RefreshIndicator to work properly
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final scripture = filteredItems[index];
                  final String scriptureId = scripture.articleId.toString();

                  return ScriptureListItem(
                    scripture: scripture,
                    index: index,
                    isLiked: likedScriptureIds.contains(scriptureId),
                    onLikeToggle: () => _toggleLike(scriptureId),
                    //onShare: () => _shareScripture(scripture),
                    onTap: () => context.push(
                      '/scriptures/scripture/${scripture.articleId}',
                    ),
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
