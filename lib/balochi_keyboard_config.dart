// Lekpad Standard Keyboard Configuration, Layout Mappings, Dictionary, and Symbols
class BalochiConfig {
  // 1. Dual-Script Localization Dictionary (Balòrabi & Balòtin)
  static const Map<String, Map<String, String>> localizations = {
    'app_title': {
      'balorabi': 'لِکپَد',
      'balotin': 'Lekpad',
    },
    'enable_keyboard': {
      'balorabi': 'لکپدا کار بَند',
      'balotin': 'Lekpadà kàr band',
    },
    'choose_keyboard': {
      'balorabi': 'لکپدا وتی کیبورڈ گچݔن کَن',
      'balotin': 'Lekpadà wati kiborď gecèn kan',
    },
    'settings': {
      'balorabi': 'رِدانکان',
      'balotin': 'Redànkàn',
    },
    'themes': {
      'balorabi': 'رنگبندی',
      'balotin': 'Rangbandi',
    },
    'day_mode': {
      'balorabi': 'رۏچءِ ڈؤل(اسپݔت)',
      'balotin': 'Ròc e ďaul(Ispèt)',
    },
    'night_mode': {
      'balorabi': 'شپءِ ڈؤل(سیاه)',
      'balotin': 'Šap e ďaul(Siyàh)',
    },
    'help_guide': {
      'balorabi': 'سرۏشتادی',
      'balotin': 'Saròštàdi',
    },
    'about_us': {
      'balorabi': 'مئی بارَوا',
      'balotin': 'Mai Bàrawà',
    },
    'about_text': {
      'balorabi': 'اے لکپد یک دݔمارپتگݔن کیبورڈے کہ بلۏچی استاندارد ابءِ سرا جۏڈݔنَگ بیتَگ ءُ ھنچۏ شما تۏن اݔت گۏن اے کیبورڈا بلۏچی کُھنݔن ابانءِ سرا ھن بہ لِکّ اݔت',
      'balotin': 'È Lekpad yak dèmà raptagèn kiborďè ka Balòci estàndàrdèn àb e sarà jòďènag bitag o hancòš šomà tòn èt gòn è kiborďà Balòci kohnèn àb àn e sarà han be lekk èt',
    },
    'test_typing': {
      'balorabi': 'وتی لکَّگءِ پَدَّری‌ئا بہ کَن',
      'balotin': 'Wati lekkag e paddari à be kan',
    },
    'select_script': {
      'balorabi': 'وتی لِکَّگءِ ڈؤلا گچݔن بہ گن',
      'balotin': 'Wati lekkag e ďaulà gecèn be kan',
    }
  };

  // 2. Comprehensive Balochi Standard Prediction Dictionary (Including greetings & @SarOSouj vocabulary)
  // Strictly validated: DOES NOT contain forbidden characters: ظطضصثقفغعخ
  static const List<String> predictionVocabulary = [
    // Standard BSA
    'اَرس', 'آماد', 'آسمان', 'آسبار', 'بَرۏت', 'رُمب', 'چانٚک', 'دو چاپی', 'دیوال', 'دراج',
    'ڈُنگ', 'ڈَل', 'اِشک', 'اݔدام', 'بݔر', 'اِسبݔت', 'گَنش', 'گُب', 'گوارَگ', 'ھئیک',
    'ھال', 'ھَشت', 'کِرر', 'کَپپَگی', 'لَھم', 'لَشکَر', 'مادَگ', 'مار', 'نَمیبگ', 'نِھݔپَگ',
    'اُستُم', 'اُستاز', 'اۏلاک', 'اۏشت', 'پَتتَر', 'پِت', 'پُلل', 'رُنگ', 'راھشۏن', 'سیاہ',
    'سَنگَت', 'سُھل', 'شاشک', 'شَش', 'شَھدَربرجاہ', 'تَل', 'تَلار', 'ٹاک', 'ٹراشو', 'ھور',
    'وئیل', 'واھَگ', 'یَل', 'زَھیر', 'زِڈڈ', 'زال', 'ژانگ', 'بوژ', 'بلۏچ', 'بلۏچستان',
    'بلۏچی', 'وانگ', 'جنک', 'لوگ', 'پاد', 'پاچن', 'پنج', 'مرد', 'مردین', 'جنین',
    // Greetings (احوالپرسی) from madaran.net & SarOSouj
    'سَلام', 'والِک', 'چونَے', 'چونے', 'مَن', 'وشوں', 'تَو', 'هَں', 'چہ', 'هال', 'اِنت', 
    'وَش', 'سَلامتے', 'جۏڑی',
    // Weather & Words from t.me/SarOSouj
    'هَور', 'جمبر', 'استین', 'استون', 'گرند', 'گُرۏک', 'ترَمپ', 'ترۏنگل', 'گوات', 'سَنگُل', 
    'سُهر', 'بیر', 'گوارَگ', 'هار', 'کَور', 'شݔپ', 'لوڈ', 'لَهڈ', 
    // Concepts & Adjectives from t.me/SarOSouj
    'بچَّگ', 'بچّنَگ', 'بچّنۏک', 'بچِّتگیں', 'بچّنتگ', 'بچّۏک', 'مُسام', 'نِمرۏچ', 
    'وَڈݔنَگ', 'وَڈݔنۏک', 'جۏڈݔنَگ', 'جۏڈݔنۏک', 'بَنݔنَگ', 'بَنݔنۏک', 'بَنݔنتگیں', 'اَڈ', 
    'شَرر', 'شؤک', 'زَبَردَست'
  ];

  static const List<String> latinPredictionVocabulary = [
    // Standard Balotin
    'Ars', 'Àmàd', 'Àzmàn', 'Àsbàr', 'Baròt', 'Romb', 'Cànk', 'Do càpī', 'Dywàl', 'Dràj',
    'Ďung', 'Ďal', 'Ešk', 'Èdàm', 'Bèr', 'Ispèt', 'Ganš', 'Gub', 'Gwàrag', 'Haik',
    'Hàl', 'Hašt', 'Kirr', 'Kappagī', 'Lahm', 'Laškar', 'Màdag', 'Màr', 'Nambèg', 'Nihèpag',
    'Ustum', 'Ustàz', 'Òlàk', 'Òšt', 'Pattar', 'Pit', 'Poll', 'Rung', 'Ràhšòn', 'Siyàh',
    'Sangat', 'Suhl', 'Šàšk', 'Šaš', 'Šahdarbarjàh', 'Tal', 'Talàr', 'Ťak', 'Ťràšò', 'Hur',
    'Wail', 'Wàhag', 'Yal', 'Zahèr', 'Ziďď', 'Zàl', 'Žàng', 'Bòž', 'Balòc', 'Balòcestàn',
    'Balòcī', 'Wànag', 'Janek', 'Lúg', 'Pàd', 'Pàcen', 'Panč', 'Mard', 'Marden', 'Janèn',
    // Greetings (Jòďi)
    'Salàm', 'Vàlaik', 'Čònai', 'Man', 'Vašaon', 'Tà', 'Han', 'Ce', 'Hàl', 'Ent', 'Vaš', 
    'Salàmati', 'Jòďī',
    // Weather & Concepts
    'Haur', 'Jambar', 'Estin', 'Estun', 'Grand', 'Goròk', 'Tramp', 'Tròngal', 'Guàt', 'Sangol', 
    'Sohr', 'Bir', 'Guàrag', 'Hàr', 'Kaur', 'Šèp', 'Luď', 'Lahď', 'Baččag', 'Baččènag', 
    'Baččènòk', 'Bačchetagèn', 'Baččèntag', 'Baččòk', 'Musàm', 'Nimròc', 'Waďènag', 'Waďènòk', 
    'Jòďènag', 'Jòďènòk', 'Banènag', 'Banènòk', 'Banèntagèn', 'Aď', 'Šarr', 'Šauk', 'Zabardast'
  ];

  // 3. Precise Balòrabi Layout Definition (With "مان" as Enter key)
  static const List<List<String>> balorabiLayout = [
    ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰'], // Row 0: Numbers
    ['ے', 'ی', 'ڈ', 'ٹ', 'و', 'ء', 'هـ', 'ج', 'چ', 'ءِ'], // Row 1: Vowels and some consonants
    ['ش', 'س', 'ی', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'پ'], // Row 2: Standard consonants
    ['◀▶', 'ژ', 'ز', 'ر', 'د', 'و', 'ک', 'گ', 'پاکے'], // Row 3: Command & Consonants
    ['ツ', 'ABC', 'SPACE', '-', 'مان'] // Row 4: Action bar (Màn as Enter!)
  ];

  // 4. Precise Balòtin Layout Definition (With "Màn" as Enter key)
  static const List<List<String>> balotinLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'], // Row 0: Numbers
    ['À', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ť'], // Row 1
    ['A', 'Š', 'S', 'D', 'Ď', 'G', 'H', 'J', 'K', 'L', 'Ò'], // Row 2
    ['⬆', 'Z', 'Ž', 'C', 'È', 'B', 'N', 'M', 'Pàk'], // Row 3
    ['ツ Sym', 'اب ...', 'SPACE', '.', 'Màn'] // Row 4 (Màn as Enter!)
  ];

  // 5. Symbols Page 1 Layout
  static const List<List<String>> symbolsLayout1 = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['+', '×', '÷', '=', '٪', '^', '!', '@', '#', '\$'],
    ['/', '\\', '~', '*', '(', ')', '-', '_', '|', '&'],
    ['صفحہ ۲ ◀', '[', ']', '{', '}', '<', '>', '❂', 'Pàk'],
    ['اب/ABC', 'SPACE', 'Màn']
  ];

  // 6. Symbols Page 2 Layout (With "مان" as Enter key)
  static const List<List<String>> symbolsLayout2 = [
    ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰'],
    ['،', '؟', '?', '.', ',', ':', ';', '"', '\'', '|'],
    ['❂', 'Ꝃ', '★', '☆', '✦', '❖', '◈', '✿', '✛', '✜'],
    ['صفحہ ۱ ◀', '⚔', '🌴', '🐫', '🏔', '☪', '✵', '✹', 'پاکے'],
    ['اب/ABC', 'SPACE', 'مان']
  ];

  // 7. High-fidelity Long Press & Alternative Letters Mappings
  static const Map<String, String> keyVisualAlternativeHints = {
    // Balorabi
    'پ': 'ف',
    'ن': 'ں',
    'ت': 'ث',
    'ا': 'آ',
    'س': 'ص',
    'ش': 'ض',
    'ی': 'ئ',
    'ڈ': 'ذ',
    'ٹ': 'ط',
    'و': 'ۏ',
    'ء': 'ع',
    'هـ': 'ح',
    'ج': 'ح',
    'چ': 'خ',
    'ژ': 'ظ',
    'ز': 'ض',
    'ر': 'ڑ',
    'د': 'ذ',
    'ک': 'ق',
    'گ': 'غ',
    // Balotin
    'S': 'Š',
    'D': 'Ď',
    'G': 'Ĝ',
    'O': 'Ò',
    'Z': 'Ž',
    'E': 'È',
  };

  // Full lists of alternatives for popups
  static const Map<String, List<String>> keyAlternativeSelections = {
    'ت': ['ث', 'ط'],
    'ج': ['ح'],
    'چ': ['خ'],
    'د': ['ذ'],
    'س': ['ص'],
    'ز': ['ض', 'ظ'],
    'ا': ['ع', 'آ', 'أ', 'إ'],
    'گ': ['غ'],
    'پ': ['ف'],
    'ک': ['ق'],
    'هـ': ['ح', 'ھ', 'ه'],
    'ء': ['ع', 'ءَ', 'ءِ', 'ءُ'],
    'و': ['ۏ', 'ؤ', 'وْ', 'وُ'],
    'ی': ['ݔ', 'ے', 'یْ', 'یٰ', 'ئ'],
    'ن': ['ں', 'نٚ'],
    'ر': ['ڑ'],
    'ژ': ['ظ'],
    
    'S': ['Š'],
    'D': ['Ď'],
    'G': ['Ĝ'],
    'O': ['Ò', 'Ó'],
    'Z': ['Ž'],
    'E': ['È', 'É'],
  };
}
