import UIKit

class KeyboardViewController: UIInputViewController {

    private var isBalorabi: Bool = true
    private var predictionBar: UIStackView!
    private var clipboardButton: UIButton!
    private var mainKeyboardStack: UIStackView!

    // Custom coloring configuration (Synced from Flutter App Group)
    private var kbBgColor: UIColor = UIColor(red: 0.11, green: 0.15, blue: 0.21, alpha: 1.0)
    private var keyBgColor: UIColor = .systemBackground
    private var keyTextColor: UIColor = .label

    // Comprehensive standard dictionary strictly filtered (no ظطضصثقفغعخ)
    private val balorabiVocab = [
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

    private val balotinVocab = [
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
    private val longPressMappings: [String: [String]] = [
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
        "هـ": ["ھ", "ح", "ه"],
        "ء": ["ع", "ءَ", "ءِ", "ءُ"],
        "و": ["ۏ", "ؤ", "وْ", "وُ"],
        "ی": ["ݔ", "ے", "یْ", "یٰ", "ئ"],
        "ن": ["ں", "نٚ"],
        "ر": ["ڑ"],
        "ژ": ["ظ"],
        "a": ["á", "à", "æ"],
        "d" to ["ď"],
        "g" to ["ĝ"],
        "i" to ["í", "ì"],
        "r" to ["ř"],
        "s" to ["š"],
        "t" to ["ť"],
        "u" to ["ú", "ù"],
        "z" to ["ž"]
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
        // Read customization colors from Shared App Group UserDefaults!
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            if let bgHex = defaults.string(forKey: "kbBgColor") {
                self.view.backgroundColor = UIColor(hex: bgBgColorHex)
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

    private func renderKeys() {
        for view in mainKeyboardStack.arrangedSubviews {
            mainKeyboardStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Exact layout matching IMG_20260626_214608.png (with "ۏ" in row 1, no emojis!)
        let keys: [[String]] = isBalorabi ? [
            ["۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"],
            ["ے", "ی", "ڈ", "ٹ", "ۏ", "ء", "هـ", "ج", "چ", "ءِ"],
            ["ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"],
            ["◀▶", "ژ", "ز", "ر", "د", "و", "ک", "گ", "پاکے"],
            ["؟۱۲۳", "ABC", "SPACE", "-", "مان"]
        ] : [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["À", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ť"],
            ["A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"],
            ["⬆", "Z", "Ž", "C", "È", "B", "N", "M", "Pàk"],
            ["?123", "اب ...", "SPACE", ".", "Màn"]
        ]

        // Fetch custom colors from UserDefaults
        var customKeyBg = UIColor.systemBackground
        var customTextColor = UIColor.label
        if let defaults = UserDefaults(suiteName: "group.bc.lekpad.balochi") {
            if let keyBgHex = defaults.string(forKey: "keyBgColor") {
                customKeyBg = UIColor(hex: keyBgHex)
            }
            if let keyTextHex = defaults.string(forKey: "keyTextColor") {
                customTextColor = UIColor(hex: keyTextHex)
            }
        }

        for row in keys {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 5

            for key in row {
                let button = UIButton(type: .system)
                button.setTitle(key, for: .normal)
                button.backgroundColor = customKeyBg
                button.layer.cornerRadius = 5
                button.setTitleColor(customTextColor, for: .normal)
                
                button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)

                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                button.addGestureRecognizer(longPress)

                rowStack.addArrangedSubview(button)
            }
            mainKeyboardStack.addArrangedSubview(rowStack)
        }
    }

    private func isPunctuation(_ char: String) -> Bool {
        let punc = [" ", "\n", "،", "؟", "?", ".", ",", ":", ";", "\"", "'", "-", "_", "+", "×", "÷", "="]
        return punc.contains(char)
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
        handleKeyPress(key)
    }

    private func handleKeyPress(_ key: String) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        switch key {
        case "SPACE":
            proxy.insertText(" ")
            updatePredictions("")
        case "پاکے", "Pàk":
            proxy.deleteBackward()
            updatePredictions("")
        case "مان", "Màn":
            proxy.insertText("\n")
            updatePredictions("")
        case "ABC":
            isBalorabi = false
            renderKeys()
        case "اب ...":
            isBalorabi = true
            renderKeys()
        default:
            // Dynamic Contextual Ligature joining logic (Bari Ye 'ے' to 'ݔ' replacement)
            if let preceding = proxy.documentContextBeforeInput?.last, String(preceding) == "ے", !key.isEmpty, !isPunctuation(key) {
                proxy.deleteBackward()
                proxy.insertText("ݔ")
            }
            
            proxy.insertText(key)
            let documentContext = proxy.documentContextBeforeInput ?? ""
            let currentWord = documentContext.components(separatedBy: " ").last ?? ""
            updatePredictions(currentWord)
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let button = gesture.view as? UIButton,
              let key = button.titleLabel?.text,
              let alternatives = longPressMappings[key] else { return }

        let alert = UIAlertController(title: "Variations", message: nil, preferredStyle: .actionSheet)
        
        for alt in alternatives {
            alert.addAction(UIAlertAction(title: alt, style: .default, handler: { _ in
                self.textDocumentProxy.insertText(alt)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

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

        let activeVocab = isBalorabi ? balorabiVocab : balotinVocab
        let matches = activeVocab.filter { $0.hasPrefix(currentWord) }.prefix(3)

        for word in matches {
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
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
        }
    }
}

// Swift helper extension for hex string to UIColor parsing
extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercaseString
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            self.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            return
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
