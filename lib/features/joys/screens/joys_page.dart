import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/features/joys/widgets/joy_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

final logger = Logger('JoysPage');

class JoysPage extends StatefulWidget {
  final String locale;

  const JoysPage({super.key, this.locale = LocaleConstants.defaultLocale});

  @override
  State<JoysPage> createState() => _JoysPageState();
}

class _JoysPageState extends State<JoysPage> {
  late JoyRepository repository;

  final ScrollController _scrollController = ScrollController();

  List<Joy> joys = [];
  List<Joy> filteredItems = [];
  bool isLoading = true;
  bool isSearchInitial = true;

  final TextEditingController _searchController = TextEditingController();

  SortOrder sortOrder = SortOrder.asc;
  Set<String> likedJoyIds = {}; // Stores articleIds of liked items
  bool showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    repository = JoyRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);
    _loadAndSortJoys(shuffle: true);
    _loadLikes(); // Load saved likes from disk

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'JoysPage',
        'abideverse_screen_class': 'JoysPageClass',
      },
    );
  }

  Future<void> _loadAndSortJoys({bool shuffle = false}) async {
    setState(() => isLoading = true);
    final data = await repository.getJoys(order: sortOrder, shuffle: shuffle);
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

  List<Joy> _applyFilter(List<Joy> items, String query) {
    query = query.trim().toLowerCase();

    return items.where((joy) {
      // 1. Check Favorites Filter
      if (showOnlyFavorites &&
          !likedJoyIds.contains(joy.articleId.toString())) {
        return false;
      }

      // 2. Check Search Query
      if (query.isEmpty) return true;

      return joy.articleId.toString().contains(query) ||
          joy.title.toLowerCase().contains(query) ||
          joy.prelude.toLowerCase().contains(query) ||
          joy.laugh.toLowerCase().contains(query) ||
          joy.scriptureName.toLowerCase().contains(query) ||
          joy.scriptureVerse.toLowerCase().contains(query) ||
          joy.scriptureChapter.toLowerCase().contains(query) ||
          joy.videoName.toLowerCase().contains(query) ||
          joy.talk.toLowerCase().contains(query) ||
          joy.category.toLowerCase().contains(query);
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
      likedJoyIds = (prefs.getStringList('liked_joys') ?? []).toSet();
    });
  }

  // Toggle and Save to Local Storage
  Future<void> _toggleLike(String joyId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (likedJoyIds.contains(joyId)) {
        likedJoyIds.remove(joyId);
      } else {
        likedJoyIds.add(joyId);
      }

      // Refresh the list immediately so un-liked items disappear
      // if showOnlyFavorites is true
      filteredItems = _applyFilter(joys, _searchController.text);
    });

    // Persist the updated list
    await prefs.setStringList('liked_joys', likedJoyIds.toList());

    // Future Firebase hook:
    // if (userIsLoggedIn) { await updateFirebase(joyId, isLiked); }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.xlcd.tr()),
            Text(
              '${filteredItems.length} 😊',
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
                filteredItems = _applyFilter(joys, _searchController.text);
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
            child: RefreshIndicator(
              onRefresh: () => _loadAndSortJoys(shuffle: true),
              color: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              child: ListView.builder(
                // The physics must allow scrolling for RefreshIndicator to work properly
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final joy = filteredItems[index];
                  final String joyId = joy.articleId.toString();

                  return JoyListItem(
                    joy: joy,
                    index: index,
                    isLiked: likedJoyIds.contains(joyId),
                    onLikeToggle: () => _toggleLike(joyId),
                    onTap: () => context.push('/joys/joy/${joy.articleId}'),
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
