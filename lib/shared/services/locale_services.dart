import 'package:abideverse/core/constants/locale_constants.dart';

enum LanguageType { english, traditional, simplified }

class LocaleServices {
  LocaleServices._(); // Private constructor to prevent instantiation

  static LanguageType getCurrentLanguageType() {
    var lang = LanguageType.traditional;
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.enUS:
        lang = LanguageType.english;
      case LocaleConstants.zhCN:
        lang = LanguageType.simplified;
      case LocaleConstants.zhTW:
      default:
        lang = LanguageType.traditional;
    }
    return lang;
  }

  static String getLanguageTextByLanguageType(LanguageType lang) {
    String str = '';

    switch (lang) {
      case LanguageType.english:
        str = getEnglishLanguageText();
      case LanguageType.simplified:
        str = getSimplifiedLanguageText();
      case LanguageType.traditional:
        str = getTraditionalLanguageText();
    }
    return str;
  }

  static bool isTraditionalLanguage() {
    var isTraditional = true;
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.enUS:
      case LocaleConstants.zhCN:
        isTraditional = false;
      case LocaleConstants.zhTW:
      default:
        isTraditional = true;
    }
    return isTraditional;
  }

  static String getSignInLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.enUS:
        str = '↪Sign In';
      case LocaleConstants.zhCN:
        str = '↪登入';
      case LocaleConstants.zhTW:
      default:
        str = '↪登入';
    }
    return str;
  }

  static String getSignOutLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.enUS:
        str = '↪Sign Out';
      case LocaleConstants.zhCN:
        str = '↪登出';
      case LocaleConstants.zhTW:
      default:
        str = '↪登出';
    }
    return str;
  }

  static String getAbideverseTitle() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '笑里藏道';
      case LocaleConstants.zhTW:
      default:
        str = '笑裡藏道';
    }
    return str;
  }

  static String getAbideverseScriptLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '圣经经文';
      case LocaleConstants.zhTW:
      default:
        str = '聖經經文';
    }
    return str;
  }

  static String getAbideverseTreasureLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '金玉良言';
      case LocaleConstants.zhTW:
      default:
        str = '金玉良言';
    }
    return str;
  }

  static String getAbideverseSettingsLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '个人设置';
      case LocaleConstants.zhTW:
      default:
        str = '個人設置';
    }
    return str;
  }

  static String getAbideverseAboutLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '资源简介';
      case LocaleConstants.zhTW:
      default:
        str = '資源簡介';
    }
    return str;
  }

  static String getAbideverseJoysScreenLikes() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '喜乐榜';
      case LocaleConstants.zhTW:
      default:
        str = '喜樂榜';
    }
    return str;
  }

  static String getAbideverseJoysScreenNew() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '新出炉';
      case LocaleConstants.zhTW:
      default:
        str = '新出爐';
    }
    return str;
  }

  static String getAbideverseJoysScreenAll() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '目录表';
      case LocaleConstants.zhTW:
      default:
        str = '目錄表';
    }
    return str;
  }

  static String getSettingsScreenTitle() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '个人设置';
      case LocaleConstants.zhTW:
      default:
        str = '個人設置';
    }
    return str;
  }

  static String getAboutScreenTitle() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '《笑里藏道》简介';
      case LocaleConstants.zhTW:
      default:
        str = '《笑裡藏道》簡介';
    }
    return str;
  }

  static String getQRCodeIntro() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '二维码(QR Code)';
      case LocaleConstants.zhTW:
      default:
        str = '二維碼(QR Code)';
    }
    return str;
  }

  static String getQRCodeDescription() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '请扫描二维码(QR Code)便于使用abideverse(《笑里藏道》App)。';
      case LocaleConstants.zhTW:
      default:
        str = '請掃描二維碼(QR Code)便於使用abideverse(《笑裡藏道》App)。';
    }
    return str;
  }

  static String getLanguageSelection() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '语言设置更换后，请重新启动应用程式。';
      case LocaleConstants.zhTW:
      default:
        str = '語言設置更換後，請重新啟動應用程式。';
    }
    return str;
  }

  static String getLanguageSelectionHeader() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '语言设置:  ';
      case LocaleConstants.zhTW:
      default:
        str = '語言設置:  ';
    }
    return str;
  }

  static String getEnglishLanguageText() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '英文';
      case LocaleConstants.zhTW:
      default:
        str = '英文';
    }
    return str;
  }

  static String getTraditionalLanguageText() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '繁体中文';
      case LocaleConstants.zhTW:
      default:
        str = '繁體中文';
    }
    return str;
  }

  static String getSimplifiedLanguageText() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '简体中文';
      case LocaleConstants.zhTW:
      default:
        str = '簡體中文';
    }
    return str;
  }

  static String getBookIntro() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '《笑里藏道》书籍介绍';
      case LocaleConstants.zhTW:
      default:
        str = '《笑裡藏道》書籍介紹';
    }
    return str;
  }

  static String getBookIntroDescription() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str =
            '《笑里藏道》，曾兴才着，天恩出版社，2016年11月初版，2022第七版。 '
            '《笑里藏道》是曾兴才牧师首本著作，收集了五十二篇他这些年于矽谷生命河灵粮堂主日证道中分享的精彩笑话及其中引申的经文应用。 '
            '喜乐的心乃是良药，这本让人开怀大笑的好书，能使大家从幽默文字中领悟属灵的道理，也为您打开与人分享真理的机会之门！ ';
      case LocaleConstants.zhTW:
      default:
        str =
            '《笑裡藏道》，曾興才著，天恩出版社，2016年11月初版，2022第七版。'
            '《笑裡藏道》是曾興才牧師首本著作，收集了五十二篇他這些年於矽谷生命河靈糧堂主日證道中分享的精彩笑話及其中引申的經文應用。'
            '喜樂的心乃是良藥，這本讓人開懷大笑的好書，能使大家從幽默文字中領悟屬靈的道理，也為您打開與人分享真理的機會之門！';
    }
    return str;
  }

  static String getGraceBookStoreButtonLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '📚天恩出版社';
      case LocaleConstants.zhTW:
      default:
        str = '📚天恩出版社';
    }
    return str;
  }

  static String getRiverBookStoreButtonLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '📚灵粮书房';
      case LocaleConstants.zhTW:
      default:
        str = '📚靈糧書房';
    }
    return str;
  }

  static String getBookAuthor() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '曾兴才牧师: 《笑里藏道》书籍作者';
      case LocaleConstants.zhTW:
      default:
        str = '曾興才牧師: 《笑裡藏道》書籍作者';
    }
    return str;
  }

  static String getBookAuthorDescription() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str =
            '出生于马来西亚，至英国及美国路易斯安那州攻读建筑学位。 '
            '全职奉献后于1990年获得达拉斯神学院神学硕士，曾于德州阿灵顿圣经教会牧会。 '
            '1995年返回马来西亚担任吉隆坡信义会主任牧师。 '
            '2001年全家返美，加入「矽谷生命河灵粮堂」事奉团队，目前负责牧养处事工。 '
            '与师母 Connie 育有两个女儿。 ';
      case LocaleConstants.zhTW:
      default:
        str =
            '出生於馬來西亞，至英國及美國路易斯安那州攻讀建築學位。'
            '全職奉獻後於1990年獲得達拉斯神學院神學碩士，曾於德州阿靈頓聖經教會牧會。'
            '1995年返回馬來西亞擔任吉隆坡信義會主任牧師。'
            '2001年全家返美，加入「矽谷生命河靈糧堂」事奉團隊，目前負責牧養處事工。'
            '與師母 Connie 育有兩個女兒。';
    }
    return str;
  }

  static String getBookAuthorVideoButtonLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '▶️曾兴才牧师讲道视频';
      case LocaleConstants.zhTW:
      default:
        str = '▶️曾興才牧師講道視頻';
    }
    return str;
  }

  static String getBookPraiseSectionTitle() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '赞扬《笑里藏道》书籍';
      case LocaleConstants.zhTW:
      default:
        str = '讚揚《笑裡藏道》書籍';
    }
    return str;
  }

  static String getBookPraiseDescription1() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '来，领受一份 「幽默感」的恩膏！ 累积你的笑话存款，提升你的亲和指数，打开分享真理的机会之门！';
      case LocaleConstants.zhTW:
      default:
        str = '來，領受一份 「幽默感」的恩膏！ 累積你的笑話存款，提升你的親和指數，打開分享真理的機會之門！';
    }
    return str;
  }

  static String getBookPraiseDescription2Title() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '若同样有功效，能用幽默的笑话，把神的道解明，岂不更好？ 郑重推荐本书，帮助你分享真道，有笑果，更有效果！';
      case LocaleConstants.zhTW:
      default:
        str = '若同樣有功效，能用幽默的笑話，把神的道解明，豈不更好？鄭重推薦本書，幫助你分享真道，有笑果，更有效果！';
    }
    return str;
  }

  static String getBookPraiseDescription2SubTitle() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '👍灵粮全球使徒性网络主席 周神助';
      case LocaleConstants.zhTW:
      default:
        str = '👍靈糧全球使徒性網絡主席 周神助';
    }
    return str;
  }

  static String getBookPraiseDescription3Title() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str =
            '幽默感能使我们从新的角度来看每天周遭发生的事，也使我们可以笑谈自己的缺失，并接纳别人的软弱。 事实上，幽默感能帮助我们的信仰 更人性化，使人更容易来亲近神。';
      case LocaleConstants.zhTW:
      default:
        str =
            '幽默感能使我們從新的角度來看每天周遭發生的事，也使我們可以笑談自己的缺失，並接納別人的軟弱。事實上，幽默感能幫助我們的信仰 更人性化，使人更容易來親近神。';
    }
    return str;
  }

  static String getBookPraiseDescription3SubTitle() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '👍美国加州矽谷生命河灵粮堂主任牧师 刘彤';
      case LocaleConstants.zhTW:
      default:
        str = '👍美國加州矽谷生命河靈糧堂主任牧師 劉彤';
    }
    return str;
  }

  static String getBookPraiseDescription4Title() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '曾牧师这本书颠覆传统，诠释了矽谷的创新精神⋯⋯一个牧师写本关于「笑」的书，就如同严肃人讲笑话，讲的时候常有意想不到的效果。';
      case LocaleConstants.zhTW:
      default:
        str = '曾牧師這本書顛覆傳統，詮釋了矽谷的創新精神⋯⋯一個牧師寫本關於「笑」的書，就如同嚴肅人講笑話，講的時候常有意想不到的效果。';
    }
    return str;
  }

  static String getBookPraiseDescription4SubTitle() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '👍矽谷创新频道「丁丁电视」创办人丁维平';
      case LocaleConstants.zhTW:
      default:
        str = '👍矽谷創新頻道「丁丁電視」創辦人丁維平';
    }
    return str;
  }

  static String getBookPraiseDescription5Title() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '每篇短文都像是曾牧师喜欢的一杯好茶，初尝不酸，再喝不涩，品完后喉韵甘醇，回味无穷。';
      case LocaleConstants.zhTW:
      default:
        str = '每篇短文都像是曾牧師喜歡的一杯好茶，初嚐不酸，再喝不澀，品完後喉韻甘醇，回味無窮。';
    }
    return str;
  }

  static String getBookPraiseDescription5SubTitle() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '👍欣欣教育基金会教育顾问 廖本荣';
      case LocaleConstants.zhTW:
      default:
        str = '👍欣欣教育基金會教育顧問 廖本榮';
    }
    return str;
  }

  static String getBookPraiseDescription6Title() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str =
            '独乐乐，不如众乐乐。 我预测你的朋友们会和你一样，迫不及待地想要享受 《笑里藏道》。 所以，做一件让他们大为开怀的事一一送他们一人一本吧！';
      case LocaleConstants.zhTW:
      default:
        str =
            '獨樂樂，不如眾樂樂。我預測你的朋友們會和你一樣，迫不及待地想要享受 《笑裡藏道》。所以，做一件讓他們大為開懷的事一一送他們一人一本吧！';
    }
    return str;
  }

  static String getBookPraiseDescription6SubTitle() {
    String str = '';
    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '👍北加州全福会会长、优视频道执行委员会主席 刘效宏';
      case LocaleConstants.zhTW:
      default:
        str = '👍北加州全福會會長、優視頻道執行委員會主席 劉效宏';
    }
    return str;
  }

  static String getAppAuthor() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '张嘉: 《笑里藏道》软件(App)设计者';
      case LocaleConstants.zhTW:
      default:
        str = '張嘉: 《笑裡藏道》軟件(App)設計者';
    }
    return str;
  }

  static String getAppDeveloperDescription() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str =
            '感谢主! 如同圣经上的应许:「一生一世有主的恩惠、慈爱随着我!」出生于台湾，大学毕业，服完兵役，来美留学，完成电脑硕士及兼职完成企管硕士。 '
            '1981年起即在矽谷电脑公司，从事多种电脑软体工程开发。 2023年从Microsoft退休。 '
            '业余时领受主的呼召及恩典，在教会里担任过多种事奉，传主福音，跟随耶稣，荣神益人。 '
            '与妻子Judy目前领受主赐儿孙满堂。 '
            '祈求借着《笑里藏道》书籍+App为主多传喜乐的福音，领人归主。 颂赞、荣耀归于我们的神，直到永永远远！ 阿们。 ';
      case LocaleConstants.zhTW:
      default:
        str =
            '感謝主! 如同聖經上的應許:「一生一世有主的恩惠、慈愛隨著我!」出生於台灣，大學畢業，服完兵役，來美留學，完成電腦碩士及兼職完成企管碩士。'
            '1981年起即在矽谷電腦公司，從事多種電腦軟體工程開發。2023年從Microsoft退休。'
            '業餘時領受主的呼召及恩典，在教會裡擔任過多種事奉，傳主福音，跟隨耶穌，榮神益人。'
            '與妻子Judy目前領受主賜兒孫滿堂。'
            '祈求藉著《笑裡藏道》書籍+App為主多傳喜樂的福音，領人歸主。頌讚、榮耀歸於我們的神，直到永永遠遠！阿們。';
    }
    return str;
  }

  static String getOnlineBibleButtonLabel() {
    String str = '';

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = '✝️线上阅读圣经';
      case LocaleConstants.zhTW:
      default:
        str = '✝️線上閱讀聖經';
    }
    return str;
  }

  static List<String> getButtonText() {
    List<String> str = <String>[];

    switch (LocaleConstants.currentLocale) {
      case LocaleConstants.zhCN:
        str = [
          '⚕️喜乐的心乃是良药',
          '🤣尽情地开怀大笑吧',
          '💓神的道是活泼的',
          '✞神的道是有功效的',
          '😌领受一份幽默感',
          '💰累积你的笑话存款',
          '📈提升你的亲和指数',
        ];
      case LocaleConstants.zhTW:
      default:
        str = [
          '⚕️喜樂的心乃是良藥',
          '🤣盡情地開懷大笑吧',
          '💓神的道是活潑的',
          '✞神的道是有功效的',
          '😌領受一份幽默感',
          '💰累積你的笑話存款',
          '📈提升你的親和指數',
        ];
    }
    return str;
  }
}
