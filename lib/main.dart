  Widget _buildKeyboardUI(bool isDark, Color accentGold, Color crimsonThread) {
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
                      child: _buildKeyWidget(key, isDark, accentGold, crimsonThread),
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
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildKeyWidget(String key, bool isDark, Color accentGold, Color crimsonThread) {
    final keyBg = widget.keyBgColor;
    final textColor = widget.keyTextColor;
    final hintColor = isDark ? const Color(0xFFFCA5A5) : crimsonThread;

    final hint = BalochiConfig.keyVisualAlternativeHints[key];
    bool isSpecial = key == ' ' || key == '⌫' || key == '⏎' || key == '🌐' || key == '⬆' || key == '◀▶' || key == '؟۱۲۳' || key == '?123' || key == '← 1/2' || key == '2/2 →' || key == 'اب/ABC' || key == 'Màn';

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
      keyLabel = Icon(Icons.backspace_outlined, color: Colors.red, size: 20);
    } else if (key == '⏎' || key == 'Màn') {
      finalBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      keyLabel = Icon(Icons.keyboard_return, color: Colors.green, size: 20);
    } else if (key == '؟۱۲۳' || key == '?123') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Text(
        key,
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
      );
    } else if (key == '🌐') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = Icon(Icons.language, color: accentGold, size: 20); 
    } else if (key == '◀▶') {
      finalBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      keyLabel = const Text(
        '◀▶', 
        style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 16),
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
        } else if (key == '⏎' || key == 'Màn') {
          _insertText('\n');
        } else if (key == '⬆') {
          setState(() {
            _isShiftActive = !_isShiftActive;
          });
        } else if (key == '🌐') {
          widget.onModeChanged(widget.previousScript == 'balorabi' ? 'balotin' : 'balorabi');
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
}
