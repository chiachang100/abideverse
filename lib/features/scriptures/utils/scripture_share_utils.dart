import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';

final _logger = Logger('ScripturesShareUtils');

void shareScripture(Scripture scripture) async {
  final String shareText =
      '''
${scripture.articleId}. ${scripture.title}
  
YouTube Video: https://www.youtube.com/watch?v=${scripture.videoId}
  
— ${scripture.scriptureName} ${scripture.scriptureChapter}:${scripture.scriptureVerse}
''';

  final result = await SharePlus.instance.share(
    ShareParams(text: shareText, subject: 'Look at this from AbideVerse!'),
  );

  _logger.info('[ScripturesPage] Share Status: ${result.status}');

  if (result.status == ShareResultStatus.success) {
    _logger.info('[ScripturesPage] Thank you for sharing the info!');
  }
}
