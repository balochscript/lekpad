import UIKit
import AVFoundation

class KeyboardViewController: UIInputViewController, UIInputViewAudioFeedback {

    private var keyboardLayoutMode: String = "balorabi"
    private var isShiftActive: Bool = false

    private var predictionBar: UIStackView!
    private var clipboardButton: UIButton!
    private var mainKeyboardStack: UIStackView!

    private var kbBgColor: UIColor = UIColor(red: 0.11, green: 0.15, blue: 0.21, alpha: 1.0)
    private var keyBgColor: UIColor = .systemBackground
    private var keyTextColor: UIColor = .label

    private var backspaceTimer: Timer?
    
    private var audioPlayer: AVAudioPlayer?
    private var soundVolume: Float = 0.5
    private var isSoundEnabled: Bool = true

    var enableInputClicksWhenVisible: Bool {
        return true
    }

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
        "بچَّگ", "بچّنَگ", "بچّنۏک", "بچِّتگیں", "بچّنتگ", "بچّۏک", "مُسام", "نِمرۏچ", 
        "وَڈݔنَگ", "وَڈݔنۏک", "جۏڈݔنَگ", "جۏڈݔنۏک", "بَنݔنَگ", "بَنݔنۏک", "بَنݔنتگیں", "اَڈ", 
        "شَرر", "شؤک", "زَبَردَست", "مئی", "نن", "ھؤ", "چے", "کوئ", "کُجئ", "کجا", "کۏ", "کئ",
        "بیتَگ", "شُت", "آتک", "آتکَگ", "وَلا", "نامھُدا", "پوکو", "بگوَش", "ھُدایی", "مَھرنگ",
        "بݔکار", "دَزبَند", "دَزگوھار", "بۏگ", "مَٹ", "اوڈہ", "چُپت", "جاتیگ", "کَلمانٹ",
        "لُنڈ", "لَوَند", "چاپتال", "چَپورت", "ایماندار", "چاکَلݔٹ"
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
        "Jòďènag", "Jòďènòk", "Banènag", "Banènòk", "Banèntagèn", "Aď", "Šarr", "Šauk", "Zabardast",
        "Mai", "Nan", "Hau", "Cè", "Kuae", "Kojae", "Koja", "Kò", "Kae", "Bitag", "Šot", "Àtk",
        "Àtkag", "Walla", "Nàmhoda", "Poko", "Beguaš", "Hodayi", "Mahrang", "Bèkàr", "Dazband",
        "Dazguhar", "Bòg", "Mať", "Oďe", "Copt", "Jàtig", "Kalmànť", "Lonď", "Lawand", "Càptàl",
        "Capurt", "Imàndàr", "Càkalèť"
    ]

    private let longPressMappings: [String: [String]] = [
        "ت": ["ث", "ط"],
        "ج": ["ح"],
        "چ": ["خ", "ځ"],
        "د": ["ذ"],
        "س": ["ص"],
        "ز": ["ض", "ظ"],
        "ا": ["آ", "أ", "إ", "َ", "ِ", "ُ", "ّ", "ْ", "ٚ", "ٝ"],
        "گ": ["غ"],
        "پ": ["ف"],
        "ک": ["ق"],
        "ھ": ["ہ", "هـ", "ه", "ة", "ۀ"], 
        "ء": ["ع", "ءَ", "ءِ", "ءُ"],
        "و": ["ؤ", "ۆ", "ۇ"],
        "ۏ": ["وُ"],
        "ی": ["ئ", "ي", "ۓ", "ئی"],
        "ے/ݔ": ["یٚ"],
        "ن": ["ں", "نٚ", "ڻ"],
        "ر": ["ڑ"],
        "ل": ["ڷ", "ڵ"],
        "۔": ["ـ", "—", "-"],
        "◀▶": ["\u{200C}", "\u{200D}", "\u{200B}"],
        "a": ["á", "æ", "â", "ä"],
        "e": ["é", "ê", "ë"],
        "g": ["ĝ"],
        "i": ["í", "ì", "î", "ï"],
        "o": ["ó", "ô", "ö"],
        "r": ["ř"],
        "u": ["ú", "ù", "û", "ü"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        
        loadSoundSettings()
        setupTopBar()
        setupKeyboardRows()
        updateTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateClipboardSuggestion()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }

    private func loadSoundSettings() {
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            isSoundEnabled = defaults.bool(forKey: "flutter.kb_sound_enabled")
            soundVolume = defaults.float(forKey: "flutter.kb_sound_volume")
            if soundVolume == 0 {
                soundVolume = 0.5
            }
        }
    }

    private func updateTheme() {
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            if let bgHex = defaults.string(forKey: "flutter.kb_bg_color_hex") {
                self.view.backgroundColor = UIColor(hex: bgHex)
            } else {
                let isDark = self.traitCollection.userInterfaceStyle == .dark
                self.view.backgroundColor = isDark ? UIColor(red: 0.11, green: 0.15, blue: 0.21, alpha: 1.0) : UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1.0)
            }
            
            if let keyBgHex = defaults.string(forKey: "flutter.key_bg_color_hex") {
                keyBgColor = UIColor(hex: keyBgHex)
            }
            
            if let keyTextHex = defaults.string(forKey: "flutter.key_text_color_hex") {
                keyTextColor = UIColor(hex: keyTextHex)
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

    private func getSpannedKeyText(mainKey: String, textColor: UIColor) -> NSAttributedString {
        var displayLabel = mainKey
        
        switch mainKey {
            case "SPACE", " ": displayLabel = "␣"
            case "BACKSPACE", "⌫": displayLabel = "⌫"
            case "⏎": displayLabel = "⏎"
            case "GLOBE": displayLabel = "🌐"
            case "SHIFT": displayLabel = "⬆"
            case "⚙️": displayLabel = "⚙️"
            default: break
        }
        
        if mainKey == " " || mainKey == "SPACE" || mainKey == "BACKSPACE" || mainKey == "⏎" || mainKey == "GLOBE" || mainKey == "SHIFT" || mainKey == "◀▶" || mainKey == "⚙️" || mainKey == "← 1/2" || mainKey == "2/2 →" || mainKey == "اب/ABC" || mainKey == "⌫" || mainKey == "؟۱۲۳" || mainKey == "?123" {
            return NSAttributedString(string: displayLabel, attributes: [.foregroundColor: textColor, .font: UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)])
        }

        let lookupKey = mainKey.lowercased()
        let alternatives = longPressMappings[mainKey] ?? longPressMappings[lookupKey]
        
        guard let alts = alternatives, let hintRaw = alts.first else {
            return NSAttributedString(string: displayLabel, attributes: [.foregroundColor: textColor, .font: UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)])
        }
        
        var hint = hintRaw
        if keyboardLayoutMode == "balotin" && isShiftActive {
            hint = hintRaw.uppercased()
        }
        
        let mainFont = UIFont(name: "Amiri", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let hintFont = UIFont(name: "Amiri", size: 10) ?? UIFont.systemFont(ofSize: 10)
        
        let attributedString = NSMutableAttributedString(string: "\(mainKey) ", attributes: [
            .font: mainFont,
            .foregroundColor: textColor
        ])
        
        var displayHint = hint
        switch hint {
            case "َ": displayHint = "◌َ"
            case "ِ": displayHint = "◌ِ"
            case "ُ": displayHint = "◌ُ"
            case "ّ": displayHint = "◌ّ"
            case "ٚ": displayHint = "◌ٚ"
            case "ْ": displayHint = "◌ْ"
            case "ٝ": displayHint = "◌ٝ"
            default: break
        }
        
        let hintAttributedString = NSAttributedString(string: displayHint, attributes: [
            .font: hintFont,
            .foregroundColor: UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 1.0),
            .baselineOffset: 8
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
                    ["ے/ݔ", "ڈ", "ٹ", "ۏ", "ء", "ھ", "ج", "چ", "ءِ"],
                    ["ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"],
                    ["⚙️", "ژ", "ز", "ر", "د", "و", "ک", "گ", "⌫"],
                    ["؟۱۲۳", "GLOBE", "◀▶", "SPACE", "۔", "⏎"]
                ]
            case "balotin":
                return [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["À", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ť"],
                    ["A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"],
                    ["SHIFT", "Z", "Ž", "C", "È", "B", "N", "M", "⌫"],
                    ["?123", "GLOBE", "SPACE", ".", "⏎"]
                ]
            case "symbols1":
                return [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["+", "×", "÷", "=", "٪", "^", "!", "@", "#", "$"],
                    ["/", "\\", "~", "*", "(", ")", "-", "_", "|", "&"],
                    ["2/2 →", "[", "]", "{", "}", "<", ">", "❂", "⌫"],
                    ["اب/ABC", "SPACE", "⏎"]
                ]
            default:
                return [
                    ["۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"],
                    ["،", "؟", "?", ".", ",", ":", ";", "\"", "'", "|"],
                    ["❂", "Ꝃ", "★", "☆", "✦", "❖", "◈", "✿", "✛", "✜"],
                    ["← 1/2", "⚔", "🌴", "🐫", "🏔", "☪", "✵", "✹", "⌫"],
                    ["اب/ABC", "SPACE", "⏎"]
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
                
                let attributedTitle = getSpannedKeyText(mainKey: keyTitle, textColor: customTextColor)
                button.setAttributedTitle(attributedTitle, for: .normal)
                
                let currentKeyBg: UIColor
                switch key {
                case "BACKSPACE", "⌫":
                    currentKeyBg = UIColor(red: 0.5, green: 0.11, blue: 0.11, alpha: 1.0)
                case "⏎":
                    currentKeyBg = UIColor(red: 0.02, green: 0.31, blue: 0.23, alpha: 1.0)
                case "⚙️":
                    currentKeyBg = UIColor(red: 0.28, green: 0.33, blue: 0.41, alpha: 1.0)
                default:
                    currentKeyBg = customKeyBg
                }
                
                button.backgroundColor = currentKeyBg
                button.layer.cornerRadius = 6
                button.layer.masksToBounds = true
                
                if key == "SPACE" || key == " " {
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.widthAnchor.constraint(equalTo: rowStack.widthAnchor, multiplier: 0.40).isActive = true
                } else if isSpacebarRow {
                    nonSpaceButtons.append(button)
                }
                
                if key == "BACKSPACE" || key == "⌫" {
                    button.addTarget(self, action: #selector(backspaceDown), for: .touchDown)
                    button.addTarget(self, action: #selector(backspaceUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
                } else {
                    button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    button.addGestureRecognizer(longPress)
                }

                rowStack.addArrangedSubview(button)
            }
            
            if isSpacebarRow && nonSpaceButtons.count > 1 {
                for i in 1..<nonSpaceButtons.count {
                    nonSpaceButtons[i].widthAnchor.constraint(equalTo: nonSpaceButtons[0].widthAnchor).isActive = true
                }
            }
            
            mainKeyboardStack.addArrangedSubview(rowStack)
        }
    }

    private func isPunctuation(_ char: String) -> Bool {
        let punc = [" ", "\n", "،", "؟", "?", ".", ",", ":", ";", "\"", "'", "-", "_", "+", "×", "÷", "=", "۔", "ـ", "\u{200C}"]
        return punc.contains(char)
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let keyText = sender.currentAttributedTitle?.string ?? sender.titleLabel?.text else { return }
        let key = keyText.components(separatedBy: " ").first ?? keyText
        
        let cleanedKey = key.replacingOccurrences(of: "◌", with: "")
        handleKeyPress(cleanedKey == "␣" ? " " : cleanedKey)
    }

    private func handleKeyPress(_ key: String) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        playNativeClickSound()

        switch key {
        case "SPACE", " ", "␣":
            proxy.insertText(" ")
            updatePredictions("")
        case "⌫", "BACKSPACE":
            proxy.deleteBackward()
            updatePredictions("")
        case "⏎":
            proxy.insertText("\n")
            updatePredictions("")
        case "🌐", "GLOBE":
            keyboardLayoutMode = (keyboardLayoutMode == "balorabi") ? "balotin" : "balorabi"
            renderKeys()
        case "⚙️":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                extensionContext?.open(url, completionHandler: nil)
            }
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
            let isBalorabi = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2")
            keyboardLayoutMode = isBalorabi ? "balotin" : "balorabi"
            renderKeys()
        case "SHIFT", "⬆":
            isShiftActive = !isShiftActive
            renderKeys()
        case "◀▶":
            proxy.insertText("\u{200C}")
        case "ے/ݔ":
            proxy.insertText("ے")
            let documentContext = proxy.documentContextBeforeInput ?? ""
            let currentWord = documentContext.components(separatedBy: " ").last ?? ""
            updatePredictions(currentWord)
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
              let mainText = button.currentAttributedTitle?.string ?? button.titleLabel?.text else { return }

        let rawKey = mainText.components(separatedBy: " ").first ?? ""
        var key = rawKey.replacingOccurrences(of: "◌", with: "")
        if key == "␣" { key = " " }
        
        let lookupKey = key.lowercased()
        guard let alternativesRaw = longPressMappings[key] ?? longPressMappings[lookupKey] else { return }
        
        let alternatives = (keyboardLayoutMode == "balotin" && isShiftActive) ? alternativesRaw.map { $0.uppercased() } : alternativesRaw

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.view.tintColor = UIColor(hex: "#D97706")
        
        for alt in alternatives {
            let action = UIAlertAction(title: alt, style: .default) { _ in
                self.textDocumentProxy.insertText(alt)
                self.playNativeClickSound()
            }
            
            var displayAlt = alt
            switch alt {
                case "َ": displayAlt = "◌َ"
                case "ِ": displayAlt = "◌ِ"
                case "ُ": displayAlt = "◌ُ"
                case "ّ": displayAlt = "◌ّ"
                case "ٚ": displayAlt = "◌ٚ"
                case "ْ": displayAlt = "◌ْ"
                case "ٝ": displayAlt = "◌ٝ"
                default: break
            }
            
            if let amiriFont = UIFont(name: "Amiri", size: 28) {
                action.setValue(NSAttributedString(string: displayAlt, attributes: [.font: amiriFont]), forKey: "attributedTitle")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "بَججَگ", style: .cancel))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        self.present(alert, animated: true)
    }

    private func updatePredictions(_ currentWord: String) {
        for view in predictionBar.arrangedSubviews {
            predictionBar.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if currentWord.isEmpty { return }

        let activeVocab = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2") ? balorabiVocab : balotinVocab
        let normalizedCurrentWord = currentWord.replacingOccurrences(of: "ݔ", with: "ے")
        let matches = activeVocab.filter { 
            let normalizedWord = $0.replacingOccurrences(of: "ݔ", with: "ے")
            return normalizedWord.hasPrefix(normalizedCurrentWord)
        }.prefix(3)

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

    private func playNativeClickSound() {
        if isSoundEnabled {
            if let soundURL = Bundle.main.url(forResource: "key_click", withExtension: "mp3", subdirectory: "flutter_assets/assets/sounds") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.volume = soundVolume
                    audioPlayer?.play()
                } catch {
                    UIDevice.current.playInputClick()
                }
            } else {
                UIDevice.current.playInputClick()
            }
        }
    }

    @objc private func backspaceDown() {
        backspaceTimer?.invalidate()
        textDocumentProxy.deleteBackward()
        playNativeClickSound()
        
        backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
                self?.playNativeClickSound()
            }
        }
    }

    @objc private func backspaceUp() {
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }
}

extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count == 8 {
            cString = String(cString.suffix(6))
        }
        
        if cString.count != 6 {
            self.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
