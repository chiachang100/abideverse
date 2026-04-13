import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/widgets/markdown_viewer.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.resources.tr()), elevation: 0),
      body: ListView(
        children: [
          _buildResourceCard(
            context,
            icon: Icons.stars,
            title: LocaleKeys.mdAwesomeReferences.tr(),
            description: LocaleKeys.mdAwesomeReferencesDesc.tr(),
            assetPath: 'assets/markdown/awesome_references.md',
            color: Colors.amber,
          ),
          _buildResourceCard(
            context,
            icon: Icons.info_outline,
            title: LocaleKeys.mdAboutAbideVerse.tr(),
            description: LocaleKeys.mdAboutAbideVerseDesc.tr(),
            assetPath: 'assets/markdown/about.md',
            color: Colors.blue,
          ),
          _buildResourceCard(
            context,
            icon: Icons.favorite_outline,
            title: LocaleKeys.mdAcknowledgments.tr(),
            description: LocaleKeys.mdAcknowledgmentsDesc.tr(),
            assetPath: 'assets/markdown/acknowledgments.md',
            color: Colors.green,
          ),
          _buildResourceCard(
            context,
            icon: Icons.book_outlined,
            title: LocaleKeys.mdStudyGuides.tr(),
            description: LocaleKeys.mdStudyGuidesDesc.tr(),
            assetPath: 'assets/markdown/study_guides.md',
            color: Colors.purple,
          ),
          _buildResourceCard(
            context,
            icon: Icons.code,
            title: LocaleKeys.mdOpenSourceLicenses.tr(),
            description: LocaleKeys.mdOpenSourceLicensesDesc.tr(),
            assetPath: 'assets/markdown/licenses.md',
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String assetPath,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MarkdownViewer(assetPath: assetPath, title: title),
            ),
          );
        },
      ),
    );
  }
}
