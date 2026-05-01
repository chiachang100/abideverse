import 'package:abideverse/features/gallery/models/gallery_item.dart';

class GalleryRepository {
  /// Fetches the curated list of resources.
  /// In the future, this could be an async call to a CMS or JSON file.
  List<GalleryItem> getGalleryItems() {
    return [
      //
      // --- Playlists ---
      //
      const GalleryItem(
        title: '日富一日背誦聖經 Shorts',
        subtitle: '神的話語，每日靈糧，積累屬天財富。',
        target: 'PLFyg5v4HpNhWy6JkmAPhEML1N1gH-Q5jv',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '生命河精彩信息 | Sermon',
        subtitle: '矽谷生命河靈糧堂主日講道集。',
        target: 'PLU9oumaMMswAO6FzQ9cJeZk_Ac5WRLVeb',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '矽谷生命河靈糧堂 曾興才牧師講道集',
        subtitle: '生命河流，真理餵養，活出豐盛人生。',
        target: 'PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '主的喜樂(joyolord)-中文詩歌',
        subtitle: '心靈誠實，敬拜讚美，歌頌主愛無疆。',
        target: 'PLFyg5v4HpNhW7FCTafVkB_jH1Lm7ZhBv3',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '主的喜樂(joyolord)-English_Hymns',
        subtitle: 'Spirit and Truth, Worship and Praise, Abiding in His Grace.',
        target: 'PLFyg5v4HpNhX9jZfRTKD9pDLnVb4MTW2Z',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '心靈詩歌 Hymns for the Soul',
        subtitle:
            '10首讚美詩：葛培理佈道大會的傳承 10 Inspired Hymns: Billy Graham Crusade Legacy. ',
        target: 'PLFyg5v4HpNhWah9MwwJNHyTNl0-SrJf3g',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '優美食',
        subtitle: '巧手家常菜 (優視頻道)',
        target: 'PL0ua7D5NJtvVBYciPwuC3lQxomrTlbqS0',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '焦點新聞',
        subtitle: '帶您來關心最新全球新聞焦點 (優視頻道)',
        target: 'PLw09jf23adiGZAuPOAHVnauCLlokJpFFf',
        type: GalleryItemType.playlist,
      ),

      // More Connections

      //
      // --- External Links ---
      //
      const GalleryItem(
        title: '主的喜樂網站 (joyolord.com)',
        subtitle: '主的喜樂是我力量 (尼 8:10).',
        target: 'https://joyolord.com/',
        type: GalleryItemType.externalLink,
      ),
      const GalleryItem(
        title: '耶穌愛你 App',
        subtitle: 'Jesus Loves You! (Same as AbideVerse App.)',
        //target: 'https://jesuslovesyou.app/',
        target: '',
        type: GalleryItemType.externalLink,
      ),
      const GalleryItem(
        title: '矽谷生命河靈糧堂網站',
        subtitle: '異象: 建造神榮耀的教會。 策略: 敬拜讚美、聖靈更新、小組教會、全地轉化。',
        target: 'https://rolcc.net/',
        type: GalleryItemType.externalLink,
      ),

      const GalleryItem(
        title: 'UChannel TV 優視頻道網站',
        subtitle: '優視頻道是全美#1華人非營利、全方位、生活頻道。',
        target: 'https://www.uchanneltv.us/',
        type: GalleryItemType.externalLink,
      ),
      const GalleryItem(
        title: 'GOOD TV 網站',
        subtitle: 'GOOD TV 好消息電視台。',
        target: 'https://www.youtube.com/user/goodtv',
        type: GalleryItemType.externalLink,
      ),

      /*

      const GalleryItem(
        title: '',
        subtitle: '。',
        target: '',
        type: GalleryItemType.playlist,
        type: GalleryItemType.externalLink,
      ),

      */

      /*

      const GalleryItem(
        title: 'CoComelon Playdates #shorts',
        subtitle: 'CoComelon Playdates #shorts。',
        target: 'PLT1rvk7Trkw58_e-9kX5Lj8eTetvYhHUx',
        type: GalleryItemType.playlist,
      ),

      const GalleryItem(
        title: '2026 誰來作客 (優視頻道)',
        subtitle: '2026 誰來作客 (優視頻道)',
        target: 'PLPR_qC7y5PLujUWJYoGqWr6w3zRBcPJ9X',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: 'AI 新時代 (優視頻道)',
        subtitle: 'AI 新時代 // AI 來了 - 掌握AI，就是掌握未來',
        target: 'PLvrKRwXvxwNqAcCFR97PHJkdw9Q2EyLSl',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '焦點話題 (優視頻道)',
        subtitle: '老章陪你看新聞',
        target: 'PLG4UBWNLO49iJ05lOPFLvRjPZN4ciCU0o',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '優視特別活動 // Special Event (優視頻道)',
        subtitle: '優視特別活動 // Special Event (優視頻道)',
        target: 'PLvrKRwXvxwNqT3iRu8eC4pfIMWKSuy5-i',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '性別神學講座 (優視頻道)',
        subtitle: '性別神學講座 (優視頻道)',
        target: 'PLvrKRwXvxwNrQKqUB508U4Vm4MR6DvSOF',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '龍門陣直播 (優視頻道)',
        subtitle: '龍門陣直播 (優視頻道)',
        target: 'PLZxghdYE0TEPvmZ-xPKF4g30WpqztrHvI',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '焦點財經 (優視頻道)',
        subtitle: '焦點財經 (優視頻道)',
        target: 'PLV66nvIGRo-Tv4X5_Wrd7y1H2V-tYoVHh',
        type: GalleryItemType.playlist,
      ),
      const GalleryItem(
        title: '優視SPOTLIGHT (優視頻道)',
        subtitle: '優視SPOTLIGHT (優視頻道)',
        target: 'PLvrKRwXvxwNpM2-O2S_7WFRvwsE8rn4mH',
        type: GalleryItemType.playlist,
      ),

    */
    ];
  }
}
