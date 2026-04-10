// lib/features/treasures/screens/treasures_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/treasures/data/treasure_repository.dart';
import 'package:abideverse/features/treasures/models/treasure.dart';
import 'package:abideverse/features/treasures/widgets/treasure_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/utils/task_status.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

final logger = Logger('TreasuresPage');

class TreasuresPage extends StatefulWidget {
  final String locale;

  const TreasuresPage({super.key, this.locale = LocaleConstants.defaultLocale});

  @override
  State<TreasuresPage> createState() => _TreasuresPageState();
}

class _TreasuresPageState extends State<TreasuresPage> {
  late final TreasureRepository repository;

  final ScrollController _scrollController = ScrollController();

  List<Treasure> treasures = [];
  List<Treasure> filteredItems = [];
  bool isLoading = true;
  bool isSearchInitial = true;

  final TextEditingController _searchController = TextEditingController();

  SortOrder sortOrder = SortOrder.none; // Initial state
  Set<String> doneTreasureIds = {}; // Stores articleIds of liked items
  TaskStatus filterStatus = TaskStatus.all;
  bool showOnlyBibleStories = false;

  final bibleStoriesTag = '聖經故事';

  @override
  void initState() {
    super.initState();
    repository = TreasureRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);
    _loadInitialData(); // Combined loader

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'TreasuresPage',
        'abideverse_screen_class': 'TreasuresPageClass',
      },
    );
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doneTreasureIds = (prefs.getStringList('treasures_done_status') ?? [])
          .toSet();
    });
    await _loadAndSortTreasures(shuffle: true);
  }

  // Generic toggle for the tri-state filter
  void _cycleTaskFilter() {
    setState(() {
      if (filterStatus == TaskStatus.all) {
        filterStatus = TaskStatus.done;
      } else if (filterStatus == TaskStatus.done) {
        filterStatus = TaskStatus.pending;
      } else {
        filterStatus = TaskStatus.all;
      }

      filteredItems = _applyFilter(treasures, _searchController.text);
    });
  }

  /// Load and sort treasures based on the current sortOrder
  Future<void> _loadAndSortTreasures({bool shuffle = false}) async {
    setState(() => isLoading = true);
    final data = await repository.getTreasures(
      order: sortOrder,
      shuffle: shuffle,
    );
    setState(() {
      treasures = data;
      // apply current search query if any
      filteredItems = _applyFilter(data, _searchController.text);
      isLoading = false;
    });
  }

  /// Toggle between ascending/descending sort order
  Future<void> _toggleSortOrder() async {
    setState(() {
      // Cycle through: none → asc → desc → none
      if (sortOrder == SortOrder.none) {
        sortOrder = SortOrder.asc;
      } else if (sortOrder == SortOrder.asc) {
        sortOrder = SortOrder.desc;
      } else {
        sortOrder = SortOrder.none;
      }
    });

    await _loadAndSortTreasures();

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
  List<Treasure> _applyFilter(List<Treasure> items, String query) {
    final q = query.trim().toLowerCase();
    return items.where((treasure) {
      final String id = treasure.articleId.toString();
      final bool isDone = doneTreasureIds.contains(id);

      // 1. Tri-State Logic (Task Status)
      if (filterStatus == TaskStatus.done && !isDone) return false;
      if (filterStatus == TaskStatus.pending && isDone) return false;

      // 2. Check Bible Stories Filter (New)
      if (showOnlyBibleStories &&
          !treasure.category.toLowerCase().contains(
            bibleStoriesTag.toLowerCase(),
          )) {
        return false;
      }

      // 3. Check Search Query
      if (query.isEmpty) return true;

      return treasure.articleId.toString().contains(q) ||
          treasure.title.toLowerCase().contains(q) ||
          treasure.treasureMeaning.toLowerCase().contains(q) ||
          treasure.treasureStory.toLowerCase().contains(q) ||
          treasure.treasureRealLife.toLowerCase().contains(q) ||
          treasure.category.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _toggleTaskDone(String treasureId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (doneTreasureIds.contains(treasureId)) {
        doneTreasureIds.remove(treasureId);
      } else {
        doneTreasureIds.add(treasureId);
      }
      filteredItems = _applyFilter(treasures, _searchController.text);
    });
    await prefs.setStringList(
      'treasures_done_status',
      doneTreasureIds.toList(),
    );
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = _applyFilter(treasures, _searchController.text);
      isSearchInitial = _searchController.text.isEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredItems = treasures;
      isSearchInitial = true;
    });
  }

  /// Bible Stories filtering
  List<Treasure> _showBibleStories(List<Treasure> items) {
    //final q = query.trim().toLowerCase();
    return items.where((treasure) {
      return treasure.category.toLowerCase().contains('rolcc');
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.treasures.tr()),
            Text(
              '${filteredItems.length} 📖',
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
          // Bible Stories Filter
          IconButton(
            icon: Icon(
              showOnlyBibleStories
                  ? Icons
                        .church // Filled when active
                  : Icons.church_outlined, // Outlined when inactive
              color: showOnlyBibleStories ? Colors.blue : null,
            ),
            tooltip: LocaleKeys.bibleStories.tr(),
            onPressed: () {
              setState(() {
                // Re-run the filter with the new state
                showOnlyBibleStories = !showOnlyBibleStories;
                filteredItems = _applyFilter(treasures, _searchController.text);
              });
            },
          ),
          // Generic Tri-State Task Filter
          TaskStatusFilterIcon(status: filterStatus, onTap: _cycleTaskFilter),
          // Sort Toggle
          IconButton(
            icon: Icon(
              sortOrder == SortOrder.asc
                  ? Icons.arrow_circle_down
                  : sortOrder == SortOrder.desc
                  ? Icons.arrow_circle_up
                  : Icons.swap_vert, // Neutral icon for initial state
              color: sortOrder == SortOrder.asc
                  ? Colors.green[600] // Use 600-800 for better visibility
                  : sortOrder == SortOrder.desc
                  ? Colors.orange[700]
                  : Colors.grey[500], // Grey for initial state
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

          // List of Treasures
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadAndSortTreasures(shuffle: true),
              color: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              child: ListView.builder(
                // The physics must allow scrolling for RefreshIndicator to work properly
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final treasure = filteredItems[index];
                  final String treasureId = treasure.articleId.toString();

                  return TreasureListItem(
                    treasure: treasure,
                    index: index,
                    isLiked: doneTreasureIds.contains(treasureId),
                    onLikeToggle: () => _toggleTaskDone(treasureId),
                    onTap: () => context.push(
                      '/treasures/treasure/${treasure.articleId}',
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
