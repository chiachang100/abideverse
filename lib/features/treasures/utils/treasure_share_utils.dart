import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';
import 'package:abideverse/features/treasures/models/treasure.dart';

final _logger = Logger('TreasuresShareUtils');

void shareTreasure(Treasure treasure) async {
  final String shareText =
      '''
${treasure.articleId}. ${treasure.title}
  
${treasure.treasureMeaning}

${treasure.treasureStory}

${treasure.treasureRealLife}
''';

  final result = await SharePlus.instance.share(
    ShareParams(text: shareText, subject: 'Look at this from AbideVerse!'),
  );

  _logger.info('[TreasuresPage] Share Status: ${result.status}');

  if (result.status == ShareResultStatus.success) {
    _logger.info('[TreasuresPage] Thank you for sharing the info!');
  }
}
