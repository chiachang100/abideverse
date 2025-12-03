import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class ScriptureList extends StatefulWidget {
  final List<Scripture> scriptures;
  final ValueChanged<Scripture>? onTap;

  ScriptureList({required this.scriptures, this.onTap, super.key});

  @override
  State<ScriptureList> createState() => _ScriptureListState();
}

class _ScriptureListState extends State<ScriptureList> {
  List<Scripture> _filteredItems = [];
  bool isInit = true;

  TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.scriptures;
    _searchController.addListener(_handleSearchChanged);
    isInit = true;
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    super.dispose();
  }

  void _searchItems(String query) {
    final results = widget.scriptures
        .where(
          (m) =>
              m.title.toLowerCase().contains(query.toLowerCase()) ||
              m.name.toLowerCase().contains(query.toLowerCase()) ||
              m.verse.toLowerCase().contains(query.toLowerCase()),
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
        'abideverse_screen': 'ScriptureListScreen',
        'abideverse_screen_class': 'ScriptureListClass',
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
            itemBuilder: (context, index) => ListTile(
              title: Text(
                '${index + 1}. ${_filteredItems[index].title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '(${_filteredItems[index].name}) ${_filteredItems[index].verse}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    UIConstants.circleAvatarBgColors[(_filteredItems[index].id %
                        UIConstants.circleAvatarBgColors.length)],
                child: Text(
                  _filteredItems[index].name.substring(0, 1),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              //trailing: const Icon(Icons.arrow_forward_ios),
              onTap: widget.onTap != null
                  ? () => widget.onTap!(_filteredItems[index])
                  : null,
              // onTap: onTap != null ? () => {} : null,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSearchChanged() {
    _searchItems(_searchController.text);
  }
}
