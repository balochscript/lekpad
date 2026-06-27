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

  // 2. Comprehensive Balochi Standard Prediction Dictionary (no ظطضصثقفغعخ)
  static const List<String> predictionVocabulary = [
    // Standard BSA
    'اَرس', 'آماد', 'آسمان', 'آسبار', 'بَرۏت', 'رُمب', 'چانٚک', 'دو چاپی', 'دیوال', 'دراج',
    'ڈُنگ', 'ڈَل', 'اِشک', 'اݔدام', 'بݔر', 'اِسبݔت', 'گَنش', 'گُب', 'گوارَگ', 'ھئیک',
    'ھال', 'ھَشت', 'کِرر', 'کَپپَگی', 'لَھم', 'لَشکَر', 'مادَگ', 'مار', 'نَمیبگ', 'نِھݔپَگ',
    'اُستُم', 'اُستاز', 'اۏلاک', 'اۏشت', 'پَتتَر', 'پِت', 'پُلل', 'رُنگ', 'راھشۏن', 'سیاہ',
    'سَنگَت', 'سُھل', 'شاشک', 'شَش', 'شَھدَربرجاہ', 'تَل', 'تَلار', 'ٹاک', 'ٹراشو', 'ھور',
    'وئیل', 'واھَگ', 'یَل', 'زَھیر', 'زِڈڈ', 'زال', 'ژانگ', 'بوژ', 'بلۏچ', 'بلۏچستان',
    'بلۏچی', 'وانگ', 'جنک', 'لوگ', 'پاد', 'پاچن', 'پنج', 'مرد', 'مردین', 'جنین',
    // Greetings (Jòďi)
    'سَلام', 'والِک', 'چونَے', 'چونے', 'مَن', 'وشوں', 'تَو', 'هَں', 'چہ', 'هال', 'اِنت', 
    'وَش', 'سَلامتے', 'جۏڑی',
    // Weather & Concepts
    'هَور', 'جمبر', 'استین', 'استون', 'گرند', 'گُرۏک', 'ترَمپ', 'ترۏنگل', 'گوات', 'سَنگُل', 
    'سُهر', 'بیر', 'گوارَگ', 'هار', 'کَور', 'شݔپ', 'لوڈ', 'لَهڈ', 
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
    // Greetings
    'Salàm', 'Vàlaik', 'Čònai', 'Man', 'Vašaon', 'Tà', 'Han', 'Ce', 'Hàl', 'Ent', 'Vaš', 'Salàmati', 'Jòďī',
    // Weather & Concepts
    'Haur', 'Jambar', 'Estin', 'Estun', 'Grand', 'Goròk', 'Tramp', 'Tròngal', 'Guàt', 'Sangol', 
    'Sohr', 'Bir', 'Guàrag', 'Hàr', 'Kaur', 'Šèp', 'Luď', 'Lahď', 'Baččag', 'Baččènag', 
    'Baččènòk', 'Bačchetagèn', 'Baččèntag', 'Baččòk', 'Musàm', 'Nimròc', 'Waďènag', 'Waďènòk', 
    'Jòďènag', 'Jòďènòk', 'Banènag', 'Banènòk', 'Banèntagèn', 'Aď', 'Šarr', 'Šauk', 'Zabardast'
  ];

  // 3. Precise Balòrabi Layout Definition
  static const List<List<String>> balorabiLayout = [
    ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰'], 
    ['ے', 'ی', 'ڈ', 'ٹ', 'ۏ', 'ء', 'ھ', 'ج', 'چ', 'ءِ'], 
    ['ش', 'س', 'ی', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'پ'], 
    ['◀▶', 'ژ', 'ز', 'ر', 'د', 'و', 'ک', 'گ', '⌫'], 
    ['؟۱۲۳', '🌐', ' ', '۔', '⏎'] 
  ];

  // 4. Precise Balòtin Layout Definition
  static const List<List<String>> balotinLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'], 
    ['À', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ť'], 
    ['A', 'Š', 'S', 'D', 'Ď', 'G', 'H', 'J', 'K', 'L', 'Ò'], 
    ['⬆', 'Z', 'Ž', 'C', 'È', 'B', 'N', 'M', '⌫'], 
    ['?123', '🌐', ' ', '.', 'Màn'] 
  ];

  // 5. Symbols Page 1 Layout
  static const List<List<String>> symbolsLayout1 = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['+', '×', '÷', '=', '٪', '^', '!', '@', '#', '\$'],
    ['/', '\\', '~', '*', '(', ')', '-', '_', '|', '&'],
    ['2/2 →', '[', ']', '{', '}', '<', '>', '❂', '⌫'], 
    ['🌐', ' ', 'Màn']
  ];

  // 6. Symbols Page 2 Layout
  static const List<List<String>> symbolsLayout2 = [
    ['۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '۰'],
    ['،', '؟', '?', '.', ',', ':', ';', '"', '\'', '|'],
    ['❂', 'Ꝃ', '★', '☆', '✦', '❖', '◈', '✿', '✛', '✜'],
    ['← 1/2', '⚔', '🌴', '🐫', '🏔', '☪', '✵', '✹', '⌫'], 
    ['🌐', ' ', 'مان']
  ];

  // 7. Refined High-fidelity Long Press & Alternative Letters Mappings
  // Added standard Balochi vowel character "ۇ" under "ۏ"!
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
    'ۏ': 'ۇ', // Visual hint updated to show the standard Balochi 'ۇ' vowel!
    'ء': 'ع',
    'ھ': 'ہ', 
    'ج': 'ح',
    'چ': 'خ',
    'ژ': 'ظ',
    'ز': 'ض',
    'ر': 'ڑ',
    'د': 'ذ',
    'ک': 'ق',
    'گ': 'غ',
    '۔': 'ـ', 
    // Balotin
    'P': 'F',
    'W': 'V',
    'K': 'X',
    'G': 'Ĝ',
    'R': 'Ř',
  };

  // Full lists of alternatives for popups
  static const Map<String, List<String>> keyAlternativeSelections = {
    // Balorabi
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
    'ھ': ['ہ', 'هـ', 'ح', 'ه'], 
    'ء': ['ع', 'ءَ', 'ءِ', 'ءُ'],
    'و': ['ۏ', 'ؤ', 'وْ', 'وُ'],
    'ۏ': ['ۇ', 'و', 'ؤ', 'وْ', 'وُ'], // Included 'ۇ' as requested!
    'ی': ['ݔ', 'ے', 'یْ', 'یٰ', 'ئ'],
    'ن': ['ں', 'نٚ'],
    'ر': ['ڑ'],
    'ژ': ['ظ'],
    '۔': ['ـ', '—', '-'], 
    
    // Balotin
    'P': ['F'],
    'W': ['V'],
    'K': ['Q', 'X'],
    'G': ['Ĝ'],
    'R': ['Ř'],
    'O': ['Ó', 'Ô'],
    'E': ['É', 'Ê'],
    'A': ['Á', 'Â'],
    'I': ['Í', 'Î'],
    'U': ['Ú', 'Û'],
  };
}
