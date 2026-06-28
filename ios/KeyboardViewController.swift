import UIKit

class KeyboardViewController: UIInputViewController, UIInputViewAudioFeedback { // Conforms to audio feedback protocol!

    private var keyboardLayoutMode: String = "balorabi" // "balorabi", "balotin", "symbols1", "symbols2"
    private var isShiftActive: Bool = false

    private var predictionBar: UIStackView!
    private var clipboardButton: UIButton!
    private var mainKeyboardStack: UIStackView!

    // Custom coloring configuration (Synced from Flutter App Group)
    private var kbBgColor: UIColor = UIColor(red: 0.11, green: 0.15, blue: 0.21, alpha: 1.0)
    private var keyBgColor: UIColor = .systemBackground
    private var keyTextColor: UIColor = .label

    // Timer for Swift Auto-Repeat Backspace on Long Press!
    private var backspaceTimer: Timer?

    // Required protocol property to allow playing native input clicks
    var enableInputClicksWhenVisible: Bool {
        return true
    }

    // Comprehensive standard dictionary strictly filtered (no ظطضصثقفغعخ)
    private let balorabiVocab = [
        "اَرس", "آماد", "آسمان", "آسبار", "بَرۏت", "رُمب", "چانٚک", "دو چاپی", "دیوال", "دراج",
        "ڈُنگ", "ڈَل", "اِشک", "اݔدام", "بݔر", "اِسبݔت", "گَنش", "گُب", "گوارَگ", "ھئیک",
        "ھال", "ھَشت", "کِرر", "کَپپَگی", "لَھم", "لَشکَر", "مادَگ", "مار", "نَمیبگ", "نِھݔپَگ",
        "اُستُم", "اُستاز", "اۏلاک", "اۏشت", "پَتتَر", "پِت", "پُلل", "رُنگ", "راھشۏن", "سیاہ",
        "سَنگَت", "سُھل", "شاشک", "شَش", "شَھدَربرجاہ", "تَل", "تَلار", "ٹاک", "ٹراشو", "ھور",
        "وئیل", "واھَگ", "یَل", "زَھیر", "زِڈڈ", "زال", "ژانگ", "بوژ", "بلۏچ", "بلۏچستان", "بلۏچی",
        "سَلام", "والِک", "چونَے", "چونے", "مَن", "وشوں", "تَو", "هَں", "چہ", "هال", "اِنت", 
        "وَش", "سَلامتے", "جۏڑی", "هَور", "جمبر", "استین", "استون", "گرند", "گُرۏک", "ترَمپ", 
        "ترۏنگل", "گوات", "سَنگُل", "سُهر", "بیر", "گوارَگ", "هار", "کَور", "شݔپ", "لوڈ", "لَهڈ", 
        "بچَّگ", "بچّنَگ", "بچّنۏک", "بچِّتگیں", "بچّنتگ", "بچّۏک", "مُسام", "نِمرۏچ", 
        "وَڈݔنَگ", "وَڈݔنۏک", "جۏڈݔنَگ", "جۏڈݔنۏک", "بَنݔنَگ", "بَنݔنۏک", "بَنݔنتگیں", "اَڈ", 
        "شَرر", "شؤک", "زَبَردَست"
    ]

    private let balotinVocab = [
        "Ars", "Àmàd", "Àzmàn", "Àsbàr", "Baròt", "Romb", "Cànk", "Do càpī", "Dywàl", "Dràj",
        "Ďung", "Ďal", "Ešk", "Èdàm", "Bèr", "Ispèt", "Ganš", "Gub", "Gwàrag", "Haik",
        "Hàl", "Hašt", "Kirr", "Kappagī", "Lahm", "Laškar", "Màdag", "Màr", "Nambèg", "Nihèpag",
        "Ustum", "Ustàz", "Òlàk", "Òšt", "Pattar", "Pit", "Poll", "Rung", "Ràhšòn", "Siyàh",
        "Sangat", "Suhl", "Šàšk", "Šaš", "Šahdarbarjàh", "Tal", "Talàr", "Ťak", "Ťràšò", "Hur",
        "Wail", "Wàhag", "Yal", "Zahèr", "Ziďď", "Zàl", "Žàng", "Bòž", "Balòc", "Balòcestàn", "Balòcī",
        "Salàm", "Vàlaik", "Čònai", "Man", "Vašaon", "Tà", "Han", "Ce", "Hàl", "Ent", "Vaš", "Salàmati", "Jòďī",
        "Haur", "Jambar", "Estin", "Estun", "Grand", "Goròk", "Tramp", "Tròngal", "Guàt", "Sangol", 
        "Sohr", "Bir", "Guàrag", "Hàr", "Kaur", "Šèp", "Luď", "Lahď", "Baččag", "Baččènag", 
        "Baččènòk", "Bačchetagèn", "Baččèntag", "Baččòk", "Musàm", "Nimròc", "Waďènag", "Waďènòk", 
        "Jòďènag", "Jòďènòk", "Banènag", "Banènòk", "Banèntagèn", "Aď", "Šarr", "Šauk", "Zabardast"
    ]

    // Long press alternative letters mappings
    private let longPressMappings: [String: [String]] = [
        "ت": ["ث", "ط"],
        "ج": ["ح"],
        "چ": ["خ"],
        "د": ["ذ"],
        "س": ["ص"],
        "ز": ["ض", "ظ"],
        "ا": ["ع", "آ", "أ", "إ"],
        "گ": ["غ"],
        "پ": ["ف"],
        "ک": ["ق"],
        "ھ": ["ہ", "هـ", "ح", "ه"], 
        "ء": ["ع", "ءَ", "ءِ", "ءُ"],
        "و": ["ۏ", "ؤ", "وْ", "وُ"],
        "ۏ": ["و", "ؤ", "وْ", "وُ"],
        "ی": ["ݔ", "ے", "یْ", "یٰ", "ئ"],
        "ن": ["ں", "نٚ"],
        "ر": ["ڑ"],
        "ژ": ["ظ"],
        "۔": ["ـ", "—", "-"], 
        "a": ["á", "à", "æ"],
        "d": ["ď"],
        "g": ["ĝ"],
        "i": ["í", "ì"],
        "r": ["ř"],
        "s": ["š"],
        "t": ["ť"],
        "u": ["ú", "ù"],
        "z": ["ž"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        setupKeyboardRows()
        updateTheme()
        updateClipboardSuggestion()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }

    private func updateTheme() {
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            if let bgHex = defaults.string(forKey: "flutter.kb_bg_color_hex") {
                self.view.backgroundColor = UIColor(hex: bgHex)
            } else {
                let isDark = self.traitCollection.userInterfaceStyle == .dark
                self.view.backgroundColor = isDark ? UIColor(red: 0.11, green: 0.15, blue: 0.21, alpha: 1.0) : UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1.0)
            }
        }
    }

    private func setupTopBar() {
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fillProportionally
        topStack.spacing = 8
        topStack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(topStack)

        clipboardButton = UIButton(type: .system)
        clipboardButton.setTitle("📋", for: .normal)
        clipboardButton.backgroundColor = .systemGray4
        clipboardButton.layer.cornerRadius = 6
        clipboardButton.addTarget(self, action: #selector(pasteFromClipboard), for: .touchUpInside)
        topStack.addArrangedSubview(clipboardButton)

        predictionBar = UIStackView()
        predictionBar.axis = .horizontal
        predictionBar.spacing = 10
        topStack.addArrangedSubview(predictionBar)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            topStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            topStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            topStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupKeyboardRows() {
        mainKeyboardStack = UIStackView()
        mainKeyboardStack.axis = .vertical
        mainKeyboardStack.distribution = .fillEqually
        mainKeyboardStack.spacing = 6
        mainKeyboardStack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainKeyboardStack)

        NSLayoutConstraint.activate([
            mainKeyboardStack.topAnchor.constraint(equalTo: predictionBar.bottomAnchor, constant: 8),
            mainKeyboardStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            mainKeyboardStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            mainKeyboardStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])

        renderKeys()
    }

    // High-fidelity rich text formatter (large main character in center, small red hint on top-right!)
    private func getSpannedKeyText(mainKey: String, textColor: UIColor) -> NSAttributedString {
        if mainKey == " " || mainKey == "SPACE" || mainKey == "BACKSPACE" || mainKey == "ENTER" || mainKey == "GLOBE" || mainKey == "SHIFT" || mainKey == "◀▶" || mainKey == "← 1/2" || mainKey == "2/2 →" || mainKey == "اب/ABC" || mainKey == "⌫" || mainKey == "⏎" || mainKey == "مان" || mainKey == "Màn" {
            
            var displayLabel = mainKey
            if mainKey == "SPACE" || mainKey == " " {
                displayLabel = "␣"
            } else if mainKey == "BACKSPACE" || mainKey == "⌫" {
                displayLabel = "⌫"
            } else if mainKey == "ENTER" || mainKey == "⏎" || mainKey == "مان" || mainKey == "Màn" {
                displayLabel = "⏎"
            } else if mainKey == "GLOBE" {
                displayLabel = "🌐"
            } else if mainKey == "SHIFT" {
                displayLabel = "⬆"
            }
            
            return NSAttributedString(string: displayLabel, attributes: [.foregroundColor: textColor, .font: UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)])
        }

        guard let alternatives = longPressMappings[mainKey], let hint = alternatives.first else {
            return NSAttributedString(string: mainKey, attributes: [.foregroundColor: textColor, .font: UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)])
        }
        
        let mainFont = UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let hintFont = UIFont(name: "Amiri", size: 10) ?? UIFont.systemFont(ofSize: 10)
        
        let attributedString = NSMutableAttributedString(string: "\(mainKey) ", attributes: [
            .font: mainFont,
            .foregroundColor: textColor
        ])
        
        let hintAttributedString = NSAttributedString(string: hint, attributes: [
            .font: hintFont,
            .foregroundColor: UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 1.0), // Crimson Red
            .baselineOffset: 8 // Superscript effect!
        ])
        
        attributedString.append(hintAttributedString)
        return attributedString
    }

    private func renderKeys() {
        for view in mainKeyboardStack.arrangedSubviews {
            mainKeyboardStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let keys: [[String]] = {
            switch keyboardLayoutMode {
            case "balorabi":
                return [
                    ["۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"],
                    ["ے", "ی", "ڈ", "ٹ", "ۏ", "ء", "ھ", "ج", "چ", "ءِ"],
                    ["ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"],
                    ["◀▶", "ژ", "ز", "ر", "د", "و", "ک", "گ", "BACKSPACE"],
                    ["؟۱۲۳", "GLOBE", "SPACE", "۔", "ENTER"]
                ]
            case "balotin":
                return [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["À", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ť"],
                    ["A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"],
                    ["SHIFT", "Z", "Ž", "C", "È", "B", "N", "M", "BACKSPACE"],
                    ["?123", "GLOBE", "SPACE", ".", "ENTER"]
                ]
            case "symbols1":
                return [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["+", "×", "÷", "=", "٪", "^", "!", "@", "#", "$"],
                    ["/", "\\", "~", "*", "(", ")", "-", "_", "|", "&"],
                    ["2/2 →", "[", "]", "{", "}", "<", ">", "❂", "BACKSPACE"],
                    ["اب/ABC", "SPACE", "ENTER"]
                ]
            default: // "symbols2"
                return [
                    ["۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"],
                    ["،", "؟", "?", ".", ",", ":", ";", "\"", "'", "|"],
                    ["❂", "Ꝃ", "★", "☆", "✦", "❖", "◈", "✿", "✛", "✜"],
                    ["← 1/2", "⚔", "🌴", "🐫", "🏔", "☪", "✵", "✹", "BACKSPACE"],
                    ["اب/ABC", "SPACE", "ENTER"]
                ]
            }
        }()

        var customKeyBg = UIColor.systemBackground
        var customTextColor = UIColor.label
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            if let keyBgHex = defaults.string(forKey: "flutter.key_bg_color_hex") {
                customKeyBg = UIColor(hex: keyBgHex)
            }
            if let keyTextHex = defaults.string(forKey: "flutter.key_text_color_hex") {
                customTextColor = UIColor(hex: keyTextHex)
            }
        }

        let isRtlMode = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2")

        for row in keys {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 5
            
            if isRtlMode {
                rowStack.semanticContentAttribute = .forceRightToLeft
            } else {
                rowStack.semanticContentAttribute = .forceLeftToRight
            }

            let isSpacebarRow = row.contains("SPACE") || row.contains(" ")
            rowStack.distribution = isSpacebarRow ? .fill : .fillEqually

            var nonSpaceButtons = [UIButton]()

            for key in row {
                let button = UIButton(type: .system)
                
                var keyTitle = key
                if keyboardLayoutMode == "balotin" && !isShiftActive && key.count == 1 {
                    keyTitle = key.lowercased()
                }
                
                // Set Spanned attributed text dynamically showing both main key and small crimson alternative!
                let attributedTitle = getSpannedKeyText(mainKey: keyTitle, textColor: customTextColor)
                button.setAttributedTitle(attributedTitle, for: .normal)
                
                button.backgroundColor = customKeyBg
                button.layer.cornerRadius = 8 
                button.layer.masksToBounds = true
                
                // Configure exact 40% Spacebar constraint in Swift!
                if key == "SPACE" || key == " " {
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.widthAnchor.constraint(equalTo: rowStack.widthAnchor, multiplier: 0.40).isActive = true
                } else if isSpacebarRow {
                    nonSpaceButtons.append(button)
                }
                
                // AUTO-REPEAT BACKSPACE: If key is BACKSPACE, apply repeating action listeners!
                if key == "BACKSPACE" {
                    button.addTarget(self, action: #selector(backspaceDown), for: .touchDown)
                    button.addTarget(self, action: #selector(backspaceUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
                } else {
                    button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    button.addGestureRecognizer(longPress)
                }

                rowStack.addArrangedSubview(button)
            }
            
            // Constrain remaining buttons in spacebar row to be divided equally!
            if isSpacebarRow && nonSpaceButtons.count > 1 {
                for i in 1..<nonSpaceButtons.count {
                    nonSpaceButtons[i].widthAnchor.constraint(equalTo: nonSpaceButtons[0].widthAnchor).isActive = true
                }
            }
            
            mainKeyboardStack.addArrangedSubview(rowStack)
        }
    }

    @objc private func backspaceDown() {
        self.textDocumentProxy.deleteBackward()
        
        // Play native iOS keypress delete click sound!
        playNativeClickSound()

        // Start continuous repeating timer after a 0.5 second initial holding delay
        backspaceTimer?.invalidate()
        backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.textDocumentProxy.deleteBackward()
            self?.playNativeClickSound()
        }
    }

    @objc private func backspaceUp() {
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }

    private func playNativeClickSound() {
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            let soundEnabled = defaults.bool(forKey: "flutter.kb_sound_enabled")
            if soundEnabled {
                UIDevice.current.playInputClick()
            }
        } else {
            UIDevice.current.playInputClick() // Default to playing sound if prefs not created yet
        }
    }

    private func isPunctuation(_ char: String) -> Bool {
        let punc = [" ", "\n", "،", "؟", "?", ".", ",", ":", ";", "\"", "'", "-", "_", "+", "×", "÷", "=", "۔", "ـ"]
        return punc.contains(char)
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
        handleKeyPress(key == "␣" ? " " : key)
    }

    private func handleKeyPress(_ key: String) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        // Play native system keypress sound!
        playNativeClickSound()

        switch key {
        case "SPACE", " ", "␣":
            proxy.insertText(" ")
            updatePredictions("")
        case "⌫", "BACKSPACE":
            proxy.deleteBackward()
            updatePredictions("")
        case "⏎", "ENTER", "مان", "Màn":
            proxy.insertText("\n")
            updatePredictions("")
        case "🌐":
            keyboardLayoutMode = (keyboardLayoutMode == "balorabi") ? "balotin" : "balorabi"
            renderKeys()
        case "ABC":
            keyboardLayoutMode = "balotin"
            renderKeys()
        case "اب ...":
            keyboardLayoutMode = "balorabi"
            renderKeys()
        case "؟۱۲۳", "?123":
            keyboardLayoutMode = "symbols1"
            renderKeys()
        case "2/2 →":
            keyboardLayoutMode = "symbols2"
            renderKeys()
        case "← 1/2":
            keyboardLayoutMode = "symbols1"
            renderKeys()
        case "اب/ABC":
            keyboardLayoutMode = isBalorabi ? "balorabi" : "balotin"
            renderKeys()
        case "SHIFT", "⬆":
            isShiftActive = !isShiftActive
            renderKeys()
        case "ZWNJ":
            proxy.insertText("\u{200C}") // Insert Zero Width Non-Joiner!
        default:
            var typedKey = key
            if keyboardLayoutMode == "balotin" && !isShiftActive && key.count == 1 {
                typedKey = key.lowercased()
            }
            
            if let preceding = proxy.documentContextBeforeInput?.last, String(preceding) == "ے", !typedKey.isEmpty, !isPunctuation(typedKey) {
                proxy.deleteBackward()
                proxy.insertText("ݔ")
            }
            
            proxy.insertText(typedKey)
            let documentContext = proxy.documentContextBeforeInput ?? ""
            let currentWord = documentContext.components(separatedBy: " ").last ?? ""
            updatePredictions(currentWord)
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let button = gesture.view as? UIButton,
              let key = button.titleLabel?.text,
              let alternatives = longPressMappings[key == "␣" ? " " : key] else { return }

        let alert = UIAlertController(title: "Variations", message: nil, preferredStyle: .actionSheet)
        
        for alt in alternatives {
            alert.addAction(UIAlertAction(title: alt, style: .default, handler: { _ in
                self.textDocumentProxy.insertText(alt)
                self.playNativeClickSound()
              }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, nil))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func updatePredictions(_ currentWord: String) {
        for view in predictionBar.arrangedSubviews {
            predictionBar.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if currentWord.isEmpty { return }

        let activeVocab = (keyboardLayoutMode == "balorabi") ? balorabiVocab : balotinVocab
        let matches = activeVocab.filter { $0.hasPrefix(currentWord) }.prefix(3)

        for word in matches {
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
            if let amiriFont = UIFont(name: "Amiri", size: 16) {
                button.titleLabel?.font = amiriFont
            }
            button.addTarget(self, action: #selector(predictionSelected(_:)), for: .touchUpInside)
            predictionBar.addArrangedSubview(button)
        }
    }

    @objc private func predictionSelected(_ sender: UIButton) {
        guard let word = sender.titleLabel?.text else { return }
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        let context = proxy.documentContextBeforeInput ?? ""
        if let lastWord = context.components(separatedBy: " ").last {
            for _ in 0..<lastWord.count {
                proxy.deleteBackward()
            }
        }
        proxy.insertText(word + " ")
        updatePredictions("")
        playNativeClickSound()
    }

    private func updateClipboardSuggestion() {
        if let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty {
            clipboardButton.isHidden = false
            clipboardButton.setTitle("📋 \(clipboardText.prefix(8))...", for: .normal)
        } else {
            clipboardButton.isHidden = true
        }
    }

    @objc private func pasteFromClipboard() {
        if let clipboardText = UIPasteboard.general.string {
            self.textDocumentProxy.insertText(clipboardText)
            playNativeClickSound()
        }
    }
}

// Swift helper extension for hex string to UIColor parsing
extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 8 && (cString.count) != 6) {
            self.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            return
        }
        if (cString.count == 8) {
            cString.remove(at: cString.startIndex)
            cString.remove(at: cString.startIndex) 
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
export template KeyboardViewController;
