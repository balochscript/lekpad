import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:audioplayers/audioplayers.dart';
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
  ThemeMode _themeMode = ThemeMode.dark; 
  String _keyboardMode = 'balorabi'; 
  String _previousScript = 'balorabi'; 

  Color _kbBgColor = const Color(0xFF0F172A);
  Color _keyBgColor = const Color(0xFF1E293B);
  Color _keyTextColor = Colors.white;

  bool _isSoundEnabled = true;
  double _soundVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadCustomColors();
  }

  void _loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kbBgColor = Color(prefs.getInt('kb_bg_color') ?? 0xFF0F172A);
      _keyBgColor = Color(prefs.getInt('key_bg_color') ?? 0xFF1E293B);
      _keyTextColor = Color(prefs.getInt('key_text_color') ?? 0xFFFFFFFF);
      _isSoundEnabled = prefs.getBool('kb_sound_enabled') ?? true;
      _soundVolume = prefs.getDouble('kb_sound_volume') ?? 0.5;
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (isDark) {
        _kbBgColor = const Color(0xFF0F172A);
        _keyBgColor = const Color(0xFF1E293B);
        _keyTextColor = Colors.white;
      } else {
        _kbBgColor = const Color(0xFFE2E8F0);
        _keyBgColor = Colors.white;
        _keyTextColor = Colors.black87;
      }
    });
    
    await prefs.setInt('kb_bg_color', _kbBgColor.value);
    await prefs.setInt('key_bg_color', _keyBgColor.value);
    await prefs.setInt('key_text_color', _keyTextColor.value);
    
    await prefs.setString('kb_bg_color_hex', _colorToHex(_kbBgColor));
    await prefs.setString('key_bg_color_hex', _colorToHex(_keyBgColor));
    await prefs.setString('key_text_color_hex', _colorToHex(_keyTextColor));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  void _setKeyboardMode(String mode) {
    setState(() {
      if (mode == 'balorabi' || mode == 'balotin') {
        _previousScript = mode;
      }
      _keyboardMode = mode;
    });
  }

  void _toggleSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = enabled;
    });
    await prefs.setBool('kb_sound_enabled', enabled);
  }

  void _updateSoundVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundVolume = volume;
    });
    await prefs.setDouble('kb_sound_volume', volume);
  }

  void _updateCustomColors(Color bg, Color key, Color text) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kbBgColor = bg;
      _keyBgColor = key;
      _keyTextColor = text;
    });
    
    await prefs.setInt('kb_bg_color', bg.value);
    await prefs.setInt('key_bg_color', key.value);
    await prefs.setInt('key_text_color', text.value);
    
    await prefs.setString('kb_bg_color_hex', _colorToHex(bg));
    await prefs.setString('key_bg_color_hex', _colorToHex(key));
    await prefs.setString('key_text_color_hex', _colorToHex(text));
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFD97706),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      hintColor: const Color(0xFFDC2626),
      fontFamily: 'Amiri',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        error: Color(0xFFDC2626),
        surface: Color(0xFF1E293B),
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFD97706), 
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), 
      cardColor: Colors.white,
      hintColor: const Color(0xFFB91C1C), 
      fontFamily: 'Amiri',
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        error: Color(0xFFB91C1C),
        surface: Colors.white,
      ),
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
        kbBgColor: _kbBgColor,
        keyBgColor: _keyBgColor,
        keyTextColor: _keyTextColor,
        isSoundEnabled: _isSoundEnabled,
        soundVolume: _soundVolume,
        onThemeChanged: _toggleTheme,
        onSoundChanged: _toggleSound,
        onVolumeChanged: _updateSoundVolume,
        onModeChanged: _setKeyboardMode,
        onColorsChanged: _updateCustomColors,
      ),
    );
  }
}

class KeyboardDashboard extends StatefulWidget {
  final String keyboardMode;
  final String previousScript;
  final ThemeMode themeMode;
  final Color kbBgColor;
  final Color keyBgColor;
  final Color keyTextColor;
  final bool isSoundEnabled;
  final double soundVolume;
  final Function(bool) onThemeChanged;
  final Function(bool) onSoundChanged;
  final Function(double) onVolumeChanged;
  final Function(String) onModeChanged;
  final Function(Color, Color, Color) onColorsChanged;

  const KeyboardDashboard({
    super.key,
    required this.keyboardMode,
    required this.previousScript,
    required this.themeMode,
    required this.kbBgColor,
    required this.keyBgColor,
    required this.keyTextColor,
    required this.isSoundEnabled,
    required this.soundVolume,
    required this.onThemeChanged,
    required this.onSoundChanged,
    required this.onVolumeChanged,
    required this.onModeChanged,
    required this.onColorsChanged,
  });

  @override
  State<KeyboardDashboard> createState() => _KeyboardDashboardState();
}

class _KeyboardDashboardState extends State<KeyboardDashboard> {
  final TextEditingController _textController = TextEditingController();
  List<String> _suggestions = [];
  String _clipboardText = '';
  static const MethodChannel _settingsChannel = MethodChannel('bc.lekpad.balochi/settings');
  
  bool _isShiftActive = false;

  String? _longPressKey;
  List<String> _longPressAlternatives = [];
  Offset? _longPressPosition;

  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _audioPlayer.dispose();
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
      _suggestions = vocab.where((word) {
        String normalizedWord = word.replaceAll('ݔ', 'ے');
        String normalizedLastWord = lastWord.replaceAll('ݔ', 'ے');
        return normalizedWord.toLowerCase().startsWith(normalizedLastWord.toLowerCase());
      }).take(4).toList();
    });
  }

  bool _isPunctuation(String char) {
    const punc = [' ', '\n', '،', '؟', '?', '.', ',', ':', ';', '"', '\'', '-', '_', '+', '×', '÷', '=', '۔', 'ـ', '\u200C'];
    return punc.contains(char);
  }

  void _insertText(String chars) {
    final text = _textController.text;
    final selection = _textController.selection;
    
    String finalChars = chars;
    String modifiedText = text;
    int cursorOffset = selection.start;

    if (widget.keyboardMode == 'balotin' && !_isShiftActive) {
      finalChars = chars.toLowerCase();
    }

    if (selection.start > 1 && 
        text[selection.start - 1] == ' ' && 
        (text[selection.start - 2] == 'ه' || text[selection.start - 2] == 'ہ' || text[selection.start - 2] == 'ھ' || text[selection.start - 2] == 'ے') &&
        chars == 'ی') {
      modifiedText = text.replaceRange(selection.start - 1, selection.start, '\u200C');
    }

    if (selection.start > 0 && text[selection.start - 1] == 'ے' && chars.isNotEmpty && !_isPunctuation(chars)) {
      modifiedText = text.replaceRange(selection.start - 1, selection.start, 'ݔ');
    }

    final newText = modifiedText.replaceRange(cursorOffset, selection.end, finalChars);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: cursorOffset + finalChars.length);
    _playLocalClickSound();
  }

  void _playLocalClickSound() async {
    if (widget.isSoundEnabled) {
      try {
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.stop();
        }
        await _audioPlayer.setVolume(widget.soundVolume);
        await _audioPlayer.play(AssetSource('sounds/key_click.mp3'));
      } catch (e) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  void _backspace() {
    final text = _textController.text;
    final selection = _textController.selection;
    if (selection.start > 0) {
      final newText = text.replaceRange(selection.start - 1, selection.end, '');
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(offset: selection.start - 1);
    }
    _playLocalClickSound();
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
    _playLocalClickSound();
  }

  String _getLocalizedText(String key) {
    return BalochiConfig.localizations[key]?[widget.previousScript] ?? key;
  }

  Future<void> _enableKeyboard() async {
    try {
      await _settingsChannel.invokeMethod('openKeyboardSettings');
    } catch (e) {
      debugPrint("Failed to open keyboard settings: $e");
    }
  }

  Future<void> _chooseKeyboard() async {
    try {
      await _settingsChannel.invokeMethod('openKeyboardPicker');
    } catch (e) {
      debugPrint("Failed to open keyboard picker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark || 
        (widget.themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final textDirection = widget.previousScript == 'balorabi' ? TextDirection.rtl : TextDirection.ltr;

    final accentGold = const Color(0xFFD97706);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedText('app_title'),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xFFD97706),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () => widget.onThemeChanged(!isDark),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horizontal_circle_outlined),
            onPressed: () {
              widget.onModeChanged(widget.previousScript == 'balorabi' ? 'balotin' : 'balorabi');
            },
          )
        ],
      ),
      body: Directionality(
        textDirection: textDirection,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentGold.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    ),
                                    child: Image.asset(
                                      'images/icon.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.previousScript == 'balorabi' ? 'بلۏچی (balochi)' : 'balochi (بلۏچی)',
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _getLocalizedText('about_text'),
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      color: Colors.grey,
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

                        Text(
                          _getLocalizedText('settings'),
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSettingButton(
                          context,
                          icon: Icons.keyboard,
                          title: _getLocalizedText('enable_keyboard'),
                          accentGold: accentGold,
                          onTap: _enableKeyboard, 
                        ),
                        _buildSettingButton(
                          context,
                          icon: Icons.touch_app,
                          title: _getLocalizedText('choose_keyboard'),
                          accentGold: accentGold,
                          onTap: _chooseKeyboard, 
                        ),
                        
                        const SizedBox(height: 16),
                        Text(
                          _getLocalizedText('themes'),
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: accentGold.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              Padding(
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
                                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w500),
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
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.volume_up, color: accentGold),
                                            const SizedBox(width: 12),
                                            Text(
                                              _getLocalizedText('sound_enabled'),
                                              style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        Switch(
                                          value: widget.isSoundEnabled,
                                          activeColor: accentGold,
                                          onChanged: widget.onSoundChanged,
                                        ),
                                      ],
                                    ),
                                    if (widget.isSoundEnabled) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.volume_down, size: 18, color: accentGold.withOpacity(0.7)),
                                          Expanded(
                                            child: Slider(
                                              value: widget.soundVolume,
                                              min: 0.0,
                                              max: 1.0,
                                              divisions: 10,
                                              activeColor: accentGold,
                                              label: '${(widget.soundVolume * 100).toInt()}%',
                                              onChanged: widget.onVolumeChanged,
                                            ),
                                          ),
                                          Icon(Icons.volume_up, size: 18, color: accentGold),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'کیبورڈءِ رنگبندی',
                                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildColorPickerButton(_getLocalizedText('kb_bg_color'), widget.kbBgColor, (color) {
                                          widget.onColorsChanged(color, widget.keyBgColor, widget.keyTextColor);
                                        }),
                                        _buildColorPickerButton(_getLocalizedText('key_bg_color'), widget.keyBgColor, (color) {
                                          widget.onColorsChanged(widget.kbBgColor, color, widget.keyTextColor);
                                        }),
                                        _buildColorPickerButton(_getLocalizedText('key_text_color'), widget.keyTextColor, (color) {
                                          widget.onColorsChanged(widget.kbBgColor, widget.keyBgColor, color);
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          _getLocalizedText('test_typing'),
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _textController,
                          maxLines: 2,
                          autofocus: true,
                          readOnly: true,
                          showCursor: true,
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
                          decoration: InputDecoration(
                            hintText: widget.previousScript == 'balorabi' 
                                ? 'ادا بہ لِک...' 
                                : 'Edà be lekk...',
                            hintStyle: const TextStyle(fontFamily: 'Amiri', color: Colors.grey),
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

                _buildKeyboardUI(isDark, accentGold),
              ],
            ),

            _buildFloatingBubblePopup(isDark, accentGold),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBubblePopup(bool isDark, Color accentGold) {
    if (_longPressKey == null || _longPressPosition == null) return const SizedBox.shrink();

    final bubbleWidth = (_longPressAlternatives.length * 52.0) + 20.0;
    double leftPosition = _longPressPosition!.dx - (bubbleWidth / 2);
    if (leftPosition < 10) leftPosition = 10; 

    return Positioned(
      left: leftPosition,
      top: _longPressPosition!.dy - 90, 
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.keyBgColor, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentGold, width: 1.5), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _longPressAlternatives.map((alt) {
              return GestureDetector(
                onTap: () {
                  _insertText(alt);
                  setState(() {
                    _longPressKey = null;
                    _longPressPosition = null;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alt,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.keyTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPickerButton(String label, Color currentColor, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () async {
        Color pickedColor = currentColor;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_getLocalizedText('color_picker_title'), style: const TextStyle(fontFamily: 'Amiri')),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (color) {
                  pickedColor = color;
                },
                pickerAreaHeightPercent: 0.8,
                displayThumbColor: true,
                showLabel: true,
                paletteType: PaletteType.hsvWithHue,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_getLocalizedText('cancel'), style: const TextStyle(fontFamily: 'Amiri')),
              ),
              TextButton(
                onPressed: () {
                  onSelect(pickedColor);
                  Navigator.of(context).pop();
                },
                child: Text(_getLocalizedText('confirm'), style: const TextStyle(fontFamily: 'Amiri')),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontFamily: 'Amiri', fontSize: 12)),
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
          style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w500, fontSize: 18),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentGold),
        onTap: onTap,
      ),
    );
  }

  Widget _buildKeyboardUI(bool isDark, Color accentGold) {
    final keyboardBg = widget.kbBgColor;
    
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

    final kbDirection = (widget.keyboardMode == 'balorabi' || widget.keyboardMode == 'symbols2')
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Container(
      color: keyboardBg,
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 4, right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPredictionBar(isDark, accentGold),
          const SizedBox(height: 6),

          ...layout.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: row.map((key) {
                  int flexValue = 1;
                  if (key == ' ') {
                    flexValue = 3;
                  }
                  return Expanded(
                    flex: flexValue,
                    child: Directionality(
                      textDirection: kbDirection,
                      child: _buildKeyWidget(key, isDark, accentGold),
                    ),
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
                  border: Border.all(color: accentGold.withOpacity(0.5)), 
                ),
                child: Row(
                  children: [
                    Icon(Icons.paste, size: 14, color: accentGold),
                    const SizedBox(width: 4),
                    Text(
                      _clipboardText.length > 8 ? '${_clipboardText.substring(0, 6)}...' : _clipboardText,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: widget.keyTextColor,
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
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFFD97706),
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

  Widget _buildKeyWidget(String key, bool isDark, Color accentGold) {
    final keyBg = widget.keyBgColor;
    final textColor = widget.keyTextColor;

    final hint = BalochiConfig.keyVisualAlternativeHints[key];
    bool isSpecial = key == ' ' || key == '⌫' || key == '⏎' || key == '🌐' || key == '⬆' || key == '◀▶' || key == '⚙️' || key == '؟۱۲۳' || key == '?123' || key == '← 1/2' || key == '2/2 →' || key == 'اب/ABC' || key == 'Màn' || key == 'مان';

    Color finalBg = keyBg;
    Widget keyLabel;

    if (key == ' ') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      keyLabel = Container(
        height: 12,
        decoration: BoxDecoration(
          color: isDark ? accentGold.withOpacity(0.5) : accentGold,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (key == '⌫') {
      finalBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      keyLabel = Icon(Icons.backspace_outlined, color: textColor, size: 20);
    } else if (key == '⏎' || key == 'Màn' || key == 'مان') {
      finalBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      keyLabel = Icon(Icons.keyboard_return, color: textColor, size: 20);
    } else if (key == '؟۱۲۳' || key == '?123') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Text(
        key,
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
      );
    } else if (key == '🌐') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Icon(Icons.language, color: textColor, size: 20); 
    } else if (key == '⚙️') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Icon(Icons.settings, color: accentGold, size: 20);
    } else if (key == '◀▶') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Text(
        '◀▶', 
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
      );
    } else if (key == '← 1/2' || key == '2/2 →') {
      finalBg = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
      keyLabel = Text(
        key,
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
      );
    } else if (key == 'اب/ABC') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Text(
        key,
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
      );
    } else if (key == '⬆') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Icon(Icons.arrow_upward, color: _isShiftActive ? accentGold : textColor, size: 20);
    } else {
      String displayKey = key;
      if (widget.keyboardMode == 'balotin' && !_isShiftActive) {
        displayKey = key.toLowerCase();
      }
      keyLabel = Text(
        displayKey,
        style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      );
    }

    return GestureDetector(
      onTap: () {
        if (key == ' ') {
          _insertText(' ');
        } else if (key == '⌫') {
          _backspace();
        } else if (key == '⏎' || key == 'Màn' || key == 'مان') {
          _insertText('\n');
        } else if (key == '⬆') {
          setState(() {
            _isShiftActive = !_isShiftActive;
          });
        } else if (key == '🌐') {
          widget.onModeChanged(widget.previousScript == 'balorabi' ? 'balotin' : 'balorabi');
        } else if (key == '⚙️') {
          _enableKeyboard();
        } else if (key == '؟۱۲۳' || key == '?123') {
          widget.onModeChanged('symbols1'); 
        } else if (key == '2/2 →') {
          widget.onModeChanged('symbols2'); 
        } else if (key == '← 1/2') {
          widget.onModeChanged('symbols1'); 
        } else if (key == 'اب/ABC') {
          widget.onModeChanged(widget.previousScript); 
        } else if (key == '◀▶') {
          _insertText('\u200C');
        } else if (isSpecial) {
        } else {
          String typedKey = key;
          if (!_isShiftActive && key.length == 1) {
            typedKey = key.toLowerCase();
          }
          _insertText(typedKey);
        }
      },
      onLongPressStart: (details) {
        final alternatives = BalochiConfig.keyAlternativeSelections[key] ?? [];
        if (alternatives.isNotEmpty) {
          setState(() {
            _longPressKey = key;
            _longPressAlternatives = alternatives;
            _longPressPosition = details.globalPosition; 
          });
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
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            Center(child: keyLabel),
          ],
        ),
      ),
    );
  }
}
