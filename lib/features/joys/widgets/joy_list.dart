import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/services/locale_services.dart';
import '../../../src/data/data_index.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class JoyList extends StatefulWidget {
  final List<Joy> joys;
  final bool isRanked;
  final ValueChanged<Joy>? onTap;

  JoyList({required this.joys, this.isRanked = false, this.onTap, super.key});

  @override
  State<JoyList> createState() => _JoyListState();
}

class _JoyListState extends State<JoyList> {
  List<Joy> _filteredItems = [];
  bool isInit = true;

  TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.joys;
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    super.dispose();
  }

  void _searchItems(String query) {
    final results = widget.joys
        .where(
          (m) =>
              m.scriptureName.toLowerCase().contains(query.toLowerCase()) ||
              m.scriptureVerse.toLowerCase().contains(query.toLowerCase()) ||
              m.title.toLowerCase().contains(query.toLowerCase()) ||
              m.prelude.toLowerCase().contains(query.toLowerCase()) ||
              m.laugh.toLowerCase().contains(query.toLowerCase()) ||
              m.videoName.toLowerCase().contains(query.toLowerCase()) ||
              m.talk.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () {
              isInit = false;
            },
            onChanged: (query) {
              _searchItems(query);
            },
            leading: IconButton(
              icon: isInit
                  ? const Icon(Icons.search)
                  : const Icon(Icons.arrow_back),
              onPressed: () {
                // Handle back action, e.g., close the search or navigate back
                // close(context, '');
                _searchController.clear();
                isInit = true;
              },
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
              return ListTile(
                // isThreeLine: true,
                title: Text(
                  '${(index + 1)}. ${_filteredItems[index].title} (${_filteredItems[index].articleId})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✞ (${_filteredItems[index].scripture.name})${_filteredItems[index].scripture.verse}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    Text(
                      '•ᴗ•${_filteredItems[index].laugh}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
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
                  child: Image.asset(_filteredItems[index].photoUrl),
                ),
                //trailing: const Icon(Icons.arrow_forward_ios),
                onTap: widget.onTap != null
                    ? () => widget.onTap!(_filteredItems[index])
                    : null,
                // onTap: onTap != null ? () => {} : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleSearchChanged() {
    _searchItems(_searchController.text);
  }
}
