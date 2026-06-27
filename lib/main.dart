import 'package:flutter/material.dart'; // Fixed import typo (.dart added!)
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Loads Amiri font automatically
import 'balochi_keyboard_config.dart';

void main() {
  runApp(const LekpadApp());
}

class LekpadApp extends StatefulWidget {
  const LekpadApp({super.key});

  @override
  State<LekpadApp> createState() => _LekpadAppState();
}

class _LekpadAppState extends State<LekpadApp> {
  // Option 2 Theme matches: Slate/Charcoal background, Glowing Gold/Amber accents, Crimson Thread red highlights
  ThemeMode _themeMode = ThemeMode.dark; // Defaults to Dark to match the luxury dark grey leather icon
  String _keyboardMode = 'balorabi'; 
  String _previousScript = 'balorabi'; 

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setKeyboardMode(String mode) {
    setState(() {
      if (mode == 'balorabi' || mode == 'balotin') {
        _previousScript = mode;
      }
      _keyboardMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Defining the synced custom theme based on Lekpad Icon Option 2
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFD97706), // Glowing Amber/Gold
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Luxury Dark Slate Grey
      cardColor: const Color(0xFF1E293B), // Slate Grey cards
      hintColor: const Color(0xFFDC2626), // Crimson Thread red
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        error: Color(0xFFDC2626),
        surface: Color(0xFF1E293B),
      ),
      textTheme: GoogleFonts.amiriTextTheme(ThemeData.dark().textTheme),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFD97706), // Golden Amber
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Light Slate
      cardColor: Colors.white,
      hintColor: const Color(0xFFB91C1C), // Crimson red
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        error: Color(0xFFB91C1C),
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.amiriTextTheme(ThemeData.light().textTheme),
    );

    return MaterialApp(
      title: 'Lekpad Standard Keyboard',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: KeyboardDashboard(
        keyboardMode: _keyboardMode,
        previousScript: _previousScript,
        themeMode: _themeMode,
        onThemeChanged: _toggleTheme,
        onModeChanged: _setKeyboardMode,
      ),
    );
  }
}

class KeyboardDashboard extends StatefulWidget {
  final String keyboardMode;
  final String previousScript;
  final ThemeMode themeMode;
  final Function(bool) onThemeChanged;
  final Function(String) onModeChanged;

  const KeyboardDashboard({
    super.key,
    required this.keyboardMode,
    required this.previousScript,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onModeChanged,
  });

  @override
  State<KeyboardDashboard> createState() => _KeyboardDashboardState();
}

class _KeyboardDashboardState extends State<KeyboardDashboard> {
  final TextEditingController _textController = TextEditingController();
  List<String> _suggestions = [];
  String _clipboardText = '';

  @override
  void initState() {
    super.initState();
    _fetchClipboardData();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _fetchClipboardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _clipboardText = data.text!;
      });
    }
  }

  void _onTextChanged() {
    String text = _textController.text;
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    String lastWord = text.split(' ').last;
    if (lastWord.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    List<String> vocab = widget.previousScript == 'balorabi' 
        ? BalochiConfig.predictionVocabulary 
        : BalochiConfig.latinPredictionVocabulary;

    setState(() {
      _suggestions = vocab
          .where((word) => word.toLowerCase().startsWith(lastWord.toLowerCase()))
          .take(4)
          .toList();
    });
  }

  void _insertText(String chars) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.replaceRange(selection.start, selection.end, chars);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: selection.start + chars.length);
  }

  void _backspace() {
    final text = _textController.text;
    final selection = _textController.selection;
    if (selection.start > 0) {
      final newText = text.replaceRange(selection.start - 1, selection.end, '');
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(offset: selection.start - 1);
    }
  }

  void _replaceLastWord(String word) {
    final text = _textController.text;
    final words = text.split(' ');
    if (words.isNotEmpty) {
      words.removeLast();
    }
    words.add(word);
    _textController.text = '${words.join(' ')} ';
    _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
  }

  String _getLocalizedText(String key) {
    return BalochiConfig.localizations[key]?[widget.previousScript] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark || 
        (widget.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final textDirection = widget.previousScript == 'balorabi' ? TextDirection.rtl : TextDirection.ltr;

    // Golden and Crimson styles from the selected Icon Option 2
    final accentGold = const Color(0xFFD97706);
    final crimsonThread = const Color(0xFFDC2626);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedText('app_title'),
          style: GoogleFonts.amiri(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: accentGold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nights_stay, color: accentGold),
            onPressed: () => widget.onThemeChanged(!isDark),
          ),
          IconButton(
            icon: Icon(Icons.swap_horizontal_circle_outlined, color: accentGold),
            tooltip: _getLocalizedText('select_script'),
            onPressed: () {
              widget.onModeChanged(widget.previousScript == 'balorabi' ? 'balotin' : 'balorabi');
            },
          )
        ],
      ),
      body: Directionality(
        textDirection: textDirection,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unified Luxury App Header (Matching Dark Leather / Golden 'ل' motif)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: accentGold.withOpacity(0.3), width: 1.5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                : [Colors.white, const Color(0xFFF1F5F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // App Logo representation
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                  border: BorderSide(color: accentGold, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentGold.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                ),
                                child: Center(
                                  child: Text(
                                    'ل',
                                    style: GoogleFonts.amiri(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: accentGold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.previousScript == 'balorabi' ? 'لِکپَد (Lekpad)' : 'Lekpad (لِکپَد)',
                                style: GoogleFonts.amiri(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: accentGold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getLocalizedText('about_text'),
                                style: GoogleFonts.amiri(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Settings (Redankan)
                    Text(
                      _getLocalizedText('settings'),
                      style: GoogleFonts.amiri(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSettingButton(
                      context,
                      icon: Icons.keyboard_capslock,
                      title: _getLocalizedText('enable_keyboard'),
                      accentGold: accentGold,
                      onTap: () {},
                    ),
                    _buildSettingButton(
                      context,
                      icon: Icons.touch_app_outlined,
                      title: _getLocalizedText('choose_keyboard'),
                      accentGold: accentGold,
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 16),
                    // Themes (Rangbandi)
                    Text(
                      _getLocalizedText('themes'),
                      style: GoogleFonts.amiri(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: accentGold.withOpacity(0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(isDark ? Icons.nights_stay : Icons.wb_sunny, color: accentGold),
                                const SizedBox(width: 12),
                                Text(
                                  isDark ? _getLocalizedText('night_mode') : _getLocalizedText('day_mode'),
                                  style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Switch(
                              value: isDark,
                              activeColor: accentGold,
                              onChanged: widget.onThemeChanged,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Typing test
                    Text(
                      _getLocalizedText('test_typing'),
                      style: GoogleFonts.amiri(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 2,
                      autofocus: true,
                      readOnly: true, // typed on simulator below
                      showCursor: true,
                      style: GoogleFonts.amiri(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: widget.previousScript == 'balorabi' 
                            ? 'بنویس اتدا... (نبیسگ)' 
                            : 'Nabèsag-a bنگیج کن...',
                        hintStyle: GoogleFonts.amiri(color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accentGold),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accentGold, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ON-SCREEN KEYBOARD SYNCHRONIZED TO LEKPAD THEME
            _buildKeyboardUI(isDark, accentGold, crimsonThread),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingButton(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Color accentGold, 
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: accentGold),
        title: Text(
          title, 
          style: GoogleFonts.amiri(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentGold),
        onTap: onTap,
      ),
    );
  }

  Widget _buildKeyboardUI(bool isDark, Color accentGold, Color crimsonThread) {
    // Rich Charcoal color matching leather backing of Option 2 App Icon
    final keyboardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
    
    List<List<String>> layout;
    if (widget.keyboardMode == 'balorabi') {
      layout = BalochiConfig.balorabiLayout;
    } else if (widget.keyboardMode == 'balotin') {
      layout = BalochiConfig.balotinLayout;
    } else if (widget.keyboardMode == 'symbols1') {
      layout = BalochiConfig.symbolsLayout1;
    } else {
      layout = BalochiConfig.symbolsLayout2;
    }

    return Container(
      color: keyboardBg,
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 4, right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Prediction & Clipboard bar
          _buildPredictionBar(isDark, accentGold),
          const SizedBox(height: 6),

          // 2. Keyboard Rows
          ...layout.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: row.map((key) {
                  return Expanded(
                    child: _buildKeyWidget(key, isDark, accentGold, crimsonThread),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPredictionBar(bool isDark, Color accentGold) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          if (_clipboardText.isNotEmpty)
            GestureDetector(
              onTap: () {
                _insertText(_clipboardText);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: BorderSide(color: accentGold.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.paste, size: 14, color: accentGold),
                    const SizedBox(width: 4),
                    Text(
                      _clipboardText.length > 8 ? '${_clipboardText.substring(0, 6)}...' : _clipboardText,
                      style: GoogleFonts.amiri(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    )
                  ],
                ),
              ),
            ),
          const VerticalDivider(width: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final word = _suggestions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    side: BorderSide(color: accentGold.withOpacity(0.2)),
                    label: Text(
                      word,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold, 
                        color: accentGold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => _replaceLastWord(word),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyWidget(String key, bool isDark, Color accentGold, Color crimsonThread) {
    // Normal key: Charcoal (Dark) or White (Light)
    final keyBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    // Highlight indicator uses the Crimson Thread red color
    final hintColor = isDark ? const Color(0xFFFCA5A5) : crimsonThread;

    final hint = BalochiConfig.keyVisualAlternativeHints[key];
    bool isSpecial = key == 'SPACE' || key == 'BACKSPACE' || key == 'Pàk' || key == 'پاکے' || key == 'مان' || key == 'Màn' || key == '🌐' || key == 'ツ' || key == 'ツ Sym' || key == 'ABC' || key == 'اب ...' || key == '◀▶' || key == '⬆' || key == 'صفحہ ۱ ◀' || key == 'صفحہ ۲ ◀' || key == 'اب/ABC';

    Color finalBg = keyBg;
    Widget keyLabel;

    if (key == 'SPACE') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      keyLabel = Container(
        height: 12,
        width: 60,
        decoration: BoxDecoration(
          color: isDark ? accentGold.withOpacity(0.5) : accentGold,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (key == 'پاکے' || key == 'Pàk' || key == 'BACKSPACE') {
      finalBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      keyLabel = Text(
        (key == 'پاکے' || key == 'BACKSPACE') ? '◀پاکے' : '< Pàk',
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: crimsonThread, fontSize: 16),
      );
    } else if (key == 'مان' || key == 'Màn') {
      finalBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      keyLabel = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            key,
            style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
          ),
          const Icon(Icons.keyboard_return, color: Colors.green, size: 14)
        ],
      );
    } else if (key == 'ツ' || key == 'ツ Sym') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Text(
        key,
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: accentGold, fontSize: 16),
      );
    } else if (key == 'صفحہ ۱ ◀' || key == 'صفحہ ۲ ◀') {
      finalBg = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
      keyLabel = Text(
        key,
        style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
      );
    } else {
      keyLabel = Text(
        key,
        style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      );
    }

    return GestureDetector(
      onTap: () {
        if (key == 'SPACE') {
          _insertText(' ');
        } else if (key == 'پاکے' || key == 'Pàk' || key == 'BACKSPACE') {
          _backspace();
        } else if (key == 'مان' || key == 'Màn') {
          _insertText('\n');
        } else if (key == 'ABC') {
          widget.onModeChanged('balotin');
        } else if (key == 'اب ...') {
          widget.onModeChanged('balorabi');
        } else if (key == 'ツ' || key == 'ツ Sym') {
          widget.onModeChanged('symbols1'); 
        } else if (key == 'صفحہ ۲ ◀') {
          widget.onModeChanged('symbols2'); 
        } else if (key == 'صفحہ ۱ ◀') {
          widget.onModeChanged('symbols1'); 
        } else if (key == 'اب/ABC') {
          widget.onModeChanged(widget.previousScript); 
        } else if (isSpecial) {
          // Extra layouts transitions
        } else {
          _insertText(key);
        }
      },
      onLongPress: () {
        if (BalochiConfig.keyAlternativeSelections.containsKey(key)) {
          _showAlternativeSelector(key, isDark, accentGold);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 2.5),
        height: 48,
        decoration: BoxDecoration(
          color: finalBg,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 1),
              blurRadius: 1,
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hint != null)
              Positioned(
                top: 2,
                right: 4,
                child: Text(
                  hint,
                  style: GoogleFonts.amiri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hintColor,
                  ),
                ),
              ),
            Center(child: keyLabel),
          ],
        ),
      ),
    );
  }

  void _showAlternativeSelector(String mainKey, bool isDark, Color accentGold) {
    final alternatives = BalochiConfig.keyAlternativeSelections[mainKey] ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_getLocalizedText('settings')} : $mainKey',
                  style: GoogleFonts.amiri(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: alternatives.map((alt) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _insertText(alt);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: BorderSide(color: accentGold.withOpacity(0.3)),
                        ),
                        child: Text(
                          alt,
                          style: GoogleFonts.amiri(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
