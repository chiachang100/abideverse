import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class JoyList extends StatefulWidget {
  final List<Joy> joys;
  final bool isRanked;
  final void Function(Joy joy) onTap; // ⚡ Non-nullable

  const JoyList({
    super.key,
    required this.joys,
    this.isRanked = false,
    required this.onTap,
  });

  @override
  State<JoyList> createState() => _JoyListState();
}

class _JoyListState extends State<JoyList> {
  late List<Joy> _filteredItems;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.joys;
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.joys.where((joy) {
        return joy.title.toLowerCase().contains(query) ||
            joy.prelude.toLowerCase().contains(query) ||
            joy.laugh.toLowerCase().contains(query) ||
            joy.scripture.name.toLowerCase().contains(query) ||
            joy.scripture.verse.toLowerCase().contains(query) ||
            joy.videoName.toLowerCase().contains(query) ||
            joy.talk.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearchActive = false;
      _filteredItems = widget.joys;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'JoyListScreen',
        'abideverse_screen_class': 'JoyListClass',
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchBar(
            controller: _searchController,
            hintText: LocaleKeys.search.tr(),
            onTap: () => setState(() => _isSearchActive = true),
            onChanged: (query) => _handleSearchChanged(),
            leading: IconButton(
              icon: Icon(_isSearchActive ? Icons.arrow_back : Icons.search),
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
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final joy = _filteredItems[index]; // ⚡ Typed as Joy
              return ListTile(
                title: Text(
                  '${widget.isRanked ? '${index + 1}. ' : ''}${joy.title} (${joy.articleId})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✞ (${joy.scripture.name})${joy.scripture.verse}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '•ᴗ•${joy.laugh}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                leading: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                    maxWidth: 64,
                    maxHeight: 64,
                  ),
                  child: Image.asset(joy.photoUrl),
                ),
                onTap: () => widget.onTap(joy), // ⚡ joy.id safe
              );
            },
          ),
        ),
      ],
    );
  }
}
