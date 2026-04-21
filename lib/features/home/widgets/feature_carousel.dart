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

  // Store cards in a list for easier management
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
    // Make height responsive to screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.35; // 35% of screen height
    final clampedHeight = carouselHeight.clamp(200.0, 280.0); // Between 200-280

    return Column(
      children: [
        // Carousel
        CarouselSlider(
          items: _cards.map((card) {
            return _buildFeatureCard(
              context: context,
              title: card['title'] as String,
              description: card['description'] as String,
              imagePath: card['imagePath'] as String,
              onTap: () => context.push(card['route'] as String),
            );
          }).toList(),
          options: CarouselOptions(
            height: clampedHeight,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        // Dots Indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _cards.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // Animate to the tapped dot's card
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

        // Optional: Text indicator (shows "1 / 3")
        const SizedBox(height: 4),
        Text(
          '${_currentIndex + 1} / ${_cards.length}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),

              // Dark overlay for text readability
              Container(color: Colors.black.withValues(alpha: 0.5)),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        LocaleKeys.tapToExplore.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
