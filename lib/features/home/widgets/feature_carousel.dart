// lib/features/home/widgets/feature_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

// ... imports remain the same

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  late List<Map<String, dynamic>> _shuffledCards;

  @override
  void initState() {
    super.initState();
    _shuffledCards = _generateInitialCards()..shuffle();
  }

  List<Map<String, dynamic>> _generateInitialCards() {
    return [
      {
        'title': LocaleKeys.xlcd.tr(),
        'description': LocaleKeys.xlcdDescription.tr(),
        'imagePath': 'assets/images/carousel/joys_preview.webp',
        'route': '/joys',
      },
      {
        'title': LocaleKeys.bibleVerse.tr(),
        'description': LocaleKeys.bibleVerseDescription.tr(),
        'imagePath': 'assets/images/carousel/scriptures_preview.webp',
        'route': '/scriptures',
      },
      {
        'title': LocaleKeys.treasures.tr(),
        'description': LocaleKeys.treasuresDescription.tr(),
        'imagePath': 'assets/images/carousel/treasures_preview.webp',
        'route': '/treasures',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = MediaQuery.of(context).size.height;
        final bool isLandscape = screenWidth > screenHeight; // Defined here
        final bool isWeb = screenWidth > 800;

        double dynamicAspectRatio;
        if (isWeb) {
          dynamicAspectRatio = 3.0;
        } else if (isLandscape) {
          dynamicAspectRatio = 2.2;
        } else {
          dynamicAspectRatio = 1.1;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isLandscape
                    ? screenHeight * 0.5
                    : screenHeight * 0.6,
              ),
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _shuffledCards.length,
                options: CarouselOptions(
                  aspectRatio: dynamicAspectRatio,
                  viewportFraction: isWeb ? 0.4 : (isLandscape ? 0.6 : 0.85),
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  disableCenter: true,
                  onPageChanged: (index, reason) =>
                      setState(() => _currentIndex = index),
                ),
                itemBuilder: (context, index, realIndex) {
                  return _buildFeatureCard(
                    context: context,
                    title: _shuffledCards[index]['title'],
                    description: _shuffledCards[index]['description'],
                    imagePath: _shuffledCards[index]['imagePath'],
                    onTap: () => context.push(_shuffledCards[index]['route']),
                    isLandscape: isLandscape, // Pass it here
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildIndicators(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
    required bool isLandscape, // Added parameter
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                // ... errorBuilder
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape
                            ? 18
                            : null, // Slight adjustment for landscape
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium, // Using bodyMedium as requested
                        maxLines: isLandscape ? 1 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Navigation
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => _carouselController.previousPage(),
          // Increased padding creates a larger 'hit' zone around the icon
          padding: const EdgeInsets.all(12.0),
          // We remove the zero-constraints so it can expand to include the padding
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        const SizedBox(width: 16),

        // Dot Array
        ..._shuffledCards.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _carouselController.animateToPage(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 24.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: _currentIndex == entry.key
                    ? Colors.green
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          );
        }),

        const SizedBox(width: 16),

        // Right Navigation
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 28),
          onPressed: () => _carouselController.nextPage(),
          // Increased padding creates a larger 'hit' zone around the icon
          padding: const EdgeInsets.all(12.0),
          // We remove the zero-constraints so it can expand to include the padding
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ],
    );
  }
}
