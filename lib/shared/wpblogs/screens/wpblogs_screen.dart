import 'package:flutter/material.dart';
import 'package:abideverse/shared/wpblogs/data/wordpress_api.dart';
import 'package:abideverse/shared/wpblogs/models/wpblog.dart';
import 'package:abideverse/shared/wpblogs/widgets/wpblog_list_item.dart';

import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/constants/global_constants.dart';
import 'package:abideverse/shared/services/url_service.dart';

class WPBlogsScreen extends StatelessWidget {
  final api = WordpressApi();

  WPBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbideAppBar(title: LocaleKeys.latestArticles.tr()),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    UrlService.launch(GlobalConstants.scripturesUrlString),
                child: Text(
                  '${LocaleKeys.gotoString.tr()} '
                  '「${LocaleKeys.bibleVerse.tr()}」 '
                  '${LocaleKeys.websiteString.tr()}',
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    UrlService.launch(GlobalConstants.treasuresUrlString),
                child: Text(
                  '${LocaleKeys.gotoString.tr()} '
                  '「${LocaleKeys.treasures.tr()}」 '
                  '${LocaleKeys.websiteString.tr()}',
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<WPPost>>(
              future: api.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  //return Center(child: Text(snapshot.error.toString()));
                  return Center(
                    child: Text(
                      '${LocaleKeys.unableToLoadArticles.tr()}'
                      '\n'
                      '${LocaleKeys.tryAgainLater.tr()}',
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(LocaleKeys.noArticlesAvailable.tr()),
                  );
                }

                final posts = snapshot.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return WPBlogListItem(
                      index: index,
                      isExternal: true,
                      title: post.title,
                      //subtitle: post.date.substring(0, 10),
                      subtitle: post.excerpt
                          .replaceAll(RegExp(r'<[^>]*>'), '')
                          .trim(),
                      onTap: () {
                        UrlService.launch(post.link);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
