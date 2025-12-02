#!/bin/bash

mkdir -p lib/{app,models,services/{ai,db,api},widgets,shared/{theme,utils,constants},features/{verse_memorizer/{screens,data,widgets},daily_devotion/{screens,data,widgets}}}
mkdir -p test/{unit_tests,integration_tests}

# Create placeholder files
touch lib/app/app.dart
touch lib/app/router.dart

touch lib/models/bible_verse.dart
touch lib/models/user_preferences.dart

touch lib/services/ai/verse_predictor_service.dart
touch lib/services/db/local_storage_service.dart
touch lib/services/api/bible_api_service.dart

touch lib/widgets/custom_button.dart
touch lib/widgets/verse_text.dart

touch lib/shared/theme/app_theme.dart
touch lib/shared/utils/date_utils.dart
touch lib/shared/constants/verse_constants.dart

touch lib/features/verse_memorizer/screens/memorize_home_screen.dart
touch lib/features/verse_memorizer/screens/memorize_quiz_screen.dart
touch lib/features/verse_memorizer/data/memorization_repository.dart
touch lib/features/verse_memorizer/data/verse_quiz_generator.dart
touch lib/features/verse_memorizer/widgets/verse_card.dart
touch lib/features/verse_memorizer/widgets/progress_bar.dart

touch lib/features/daily_devotion/screens/devotion_home_screen.dart
touch lib/features/daily_devotion/screens/devotion_detail_screen.dart
touch lib/features/daily_devotion/data/devotion_repository.dart
touch lib/features/daily_devotion/widgets/devotion_card.dart

touch test/unit_tests/widget_test.dart
touch test/integration_tests/app_test.dart

echo "Flutter structure created!"
