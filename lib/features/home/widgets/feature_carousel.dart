// lib/features/home/widgets/feature_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _cards = [
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

  @override
  Widget build(BuildContext context) {
    // Calculate exact heights
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final imageHeight = cardWidth * 0.56; // 16:9 ratio
    final textHeight = 80.0;
    final baseCardHeight = imageHeight + textHeight;

    // Add extra height for enlargeCenterPage effect
    // The enlargeFactor default is 0.3 (30% larger for center card)
    // Side cards need extra padding to prevent overflow
    final extraHeight = 50.0; // This prevents yellow bars on side cards
    final totalCarouselHeight = baseCardHeight + extraHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel with extra height for enlarged center card
        SizedBox(
          height: totalCarouselHeight,
          child: CarouselSlider.builder(
            itemCount: _cards.length,
            itemBuilder: (context, index, realIndex) {
              final card = _cards[index];
              return Center(
                child: SizedBox(
                  // Card height is the base height, but carousel has extra padding
                  height: baseCardHeight,
                  child: _buildFeatureCard(
                    context: context,
                    title: card['title'] as String,
                    description: card['description'] as String,
                    imagePath: card['imagePath'] as String,
                    imageHeight: imageHeight,
                    onTap: () => context.push(card['route'] as String),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height:
                  totalCarouselHeight, // Taller to accommodate enlarged center
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true, // Keep this enabled
              enlargeFactor: 0.25, // Slightly reduced from default 0.3
              viewportFraction: 0.85,
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),

        // Dots Indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _cards.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                final carouselController = CarouselSliderController();
                carouselController.animateToPage(entry.key);
                setState(() {
                  _currentIndex = entry.key;
                });
              },
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
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required double imageHeight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageHeight,
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),

            // Text Content - Fixed height container
            SizedBox(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        LocaleKeys.tapToExplore.tr(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
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
}
