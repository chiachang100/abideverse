import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/scripture.dart';
import 'scripture_list_item.dart';

class ScriptureList extends StatefulWidget {
  final List<Scripture> scriptures;
  final ValueChanged<Scripture>? onTap;

  const ScriptureList({Key? key, required this.scriptures, this.onTap})
    : super(key: key);

  @override
  State<ScriptureList> createState() => _ScriptureListState();
}

class _ScriptureListState extends State<ScriptureList> {
  final TextEditingController _searchController = TextEditingController();
  late List<Scripture> _filteredItems;
  bool isInit = true;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.scriptures;

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScriptureListScreen',
        'abideverse_screen_class': 'ScriptureListClass',
      },
    );

    _searchController.addListener(() {
      _searchItems(_searchController.text);
    });
  }

  void _searchItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.scriptures;
      });
      return;
    }

    setState(() {
      _filteredItems = widget.scriptures.where((s) {
        final q = query.toLowerCase();
        return s.title.toLowerCase().contains(q) ||
            s.scriptureName.toLowerCase().contains(q) ||
            s.scriptureVerse.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search…",
              prefixIcon: isInit
                  ? const Icon(Icons.search)
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => isInit = true);
                      },
                    ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: () => setState(() => isInit = false),
          ),
        ),

        // Scripture List
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (_, index) {
              final scripture = _filteredItems[index];
              return ScriptureListItem(
                scripture: scripture,
                index: index,
                onTap: widget.onTap != null
                    ? () => widget.onTap!(scripture)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
