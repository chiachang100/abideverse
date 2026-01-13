import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';
import 'package:abideverse/features/joys/models/joy.dart';

final _logger = Logger('JoysShareUtils');

Future<void> shareJoy(Joy joy) async {
  final String shareText =
      '''
${joy.articleId}. ${joy.title}

"${joy.talk}"

— ${joy.scriptureName} ${joy.scriptureChapter}:${joy.scriptureVerse}
''';

  final result = await SharePlus.instance.share(
    ShareParams(text: shareText, subject: 'Look at this from AbideVerse!'),
  );

  _logger.info('[ShareUtils] Share Status: ${result.status}');
  if (result.status == ShareResultStatus.success) {
    _logger.info('[ShareUtils] Thank you for sharing the info!');
  }
}
