import 'package:flutter/material.dart';
import 'package:abideverse/features/home/widgets/feature_carousel.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('AbideVerse'),
            floating: true,
            centerTitle: false,
          ),

          // Featured Content Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: const FeatureCarousel(),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                LocaleKeys.continueYourJourney.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          // You can add more sections here later
          // For example: Recent Joys, Verse of the Day, etc.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  LocaleKeys.moreContentComingSoon.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
