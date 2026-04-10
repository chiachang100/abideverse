// lib/features/scriptures/screens/scriptures_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/features/scriptures/widgets/scripture_list_item.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/utils/task_status.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

final logger = Logger('ScripturesPage');

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

  SortOrder sortOrder = SortOrder.none; // Initial state
  Set<String> doneScriptureIds = {}; // Stores articleIds of liked items
  bool showOnlyFavorites = false;
  TaskStatus filterStatus = TaskStatus.all;
  bool showOnlyRolcc = false;

  final rolccTag = 'ROLCC';

  @override
  void initState() {
    super.initState();
    repository = ScriptureRepository(locale: widget.locale);
    _searchController.addListener(_onSearchChanged);
    _loadInitialData(shuffle: true); // Combined loader

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScripturesPage',
        'abideverse_screen_class': 'ScripturesPageClass',
      },
    );
  }

  Future<void> _loadInitialData({bool shuffle = false}) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doneScriptureIds = (prefs.getStringList('scriptures_done_status') ?? [])
          .toSet();
    });
    await _loadAndSortScriptures(shuffle: shuffle);
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

      filteredItems = _applyFilter(scriptures, _searchController.text);
    });
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
      // Cycle through: none → asc → desc → none
      if (sortOrder == SortOrder.none) {
        sortOrder = SortOrder.asc;
      } else if (sortOrder == SortOrder.asc) {
        sortOrder = SortOrder.desc;
      } else {
        sortOrder = SortOrder.none;
      }
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
      final String id = scripture.articleId.toString();
      final bool isDone = doneScriptureIds.contains(id);

      // 1. Tri-State Logic
      if (filterStatus == TaskStatus.done && !isDone) return false;
      if (filterStatus == TaskStatus.pending && isDone) return false;

      // 2. Check ROLCC Filter (New)
      if (showOnlyRolcc &&
          !scripture.category.toLowerCase().contains(rolccTag.toLowerCase())) {
        return false;
      }

      // 3. Check Search Query
      if (query.isEmpty) return true;

      return scripture.articleId.toString().contains(q) ||
          scripture.title.toLowerCase().contains(q) ||
          scripture.scriptureName.toLowerCase().contains(q) ||
          scripture.scriptureChapter.toLowerCase().contains(q) ||
          scripture.scriptureVerse.toLowerCase().contains(q) ||
          scripture.scriptureReader.toLowerCase().contains(q) ||
          scripture.zhCNScriptureVerse.toLowerCase().contains(q) ||
          scripture.category.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _toggleTaskDone(String scriptureId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (doneScriptureIds.contains(scriptureId)) {
        doneScriptureIds.remove(scriptureId);
      } else {
        doneScriptureIds.add(scriptureId);
      }
      filteredItems = _applyFilter(scriptures, _searchController.text);
    });
    await prefs.setStringList(
      'scriptures_done_status',
      doneScriptureIds.toList(),
    );
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

  /// ROLCC filtering
  List<Scripture> _showRolcc(List<Scripture> items) {
    //final q = query.trim().toLowerCase();
    return items.where((scripture) {
      return scripture.category.toLowerCase().contains('rolcc');
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
            Text(LocaleKeys.bibleVerse.tr()),
            Text(
              '${filteredItems.length} ✝️',
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
          // ROLCC Filter
          IconButton(
            icon: Icon(
              showOnlyRolcc
                  ? Icons
                        .water // Filled when active
                  : Icons.water_outlined, // Outlined when inactive
              color: showOnlyRolcc ? Colors.blue : null,
            ),
            tooltip: rolccTag,
            onPressed: () {
              setState(() {
                // Re-run the filter with the new state
                showOnlyRolcc = !showOnlyRolcc;
                filteredItems = _applyFilter(
                  scriptures,
                  _searchController.text,
                );
              });
            },
          ),
          // Generic Tri-State Filter
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
                    isLiked: doneScriptureIds.contains(scriptureId),
                    onLikeToggle: () => _toggleTaskDone(scriptureId),
                    onTap: () async {
                      await context.push(
                        '/scriptures/scripture/${scripture.articleId}',
                      );
                      // This line runs AFTER you come back from the detail page
                      _loadInitialData(shuffle: false);
                    },
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
