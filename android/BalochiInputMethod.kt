package bc.lekpad.balochi

import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.inputmethodservice.InputMethodService
import android.text.Spannable
import android.text.SpannableString
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.text.style.SuperscriptSpan
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView
import bc.lekpad.balochi.R // The single, exact compiled package resource R class

class BalochiInputMethod : InputMethodService() {

    private lateinit var keyboardView: View
    private lateinit var suggestionBar: LinearLayout
    private lateinit var clipboardBar: LinearLayout
    private var isNightMode: Boolean = false
    
    // Custom layout state: "balorabi", "balotin", "symbols1", "symbols2"
    private var keyboardLayoutMode: String = "balorabi" 
    private var isShiftActive: Boolean = false // Track Shift state for Balotin layout

    // Dynamic customization color states
    private var kbBgColor: Int = 0xFF0F172A.toInt()
    private var keyBgColor: Int = 0xFF1E293B.toInt()
    private var keyTextColor: Int = 0xFFFFFFFF.toInt()
    private var amiriTypeface: Typeface? = null

    // Handler and Runnable for Android Auto-Repeat Backspace on Long Press!
    private var backspaceHandler: Handler? = null
    private val backspaceRunnable = object : Runnable {
        override fun run() {
            val ic = currentInputConnection
            ic?.deleteSurroundingText(1, 0)
            playKeyPressSound(AudioManager.FX_KEYPRESS_DELETE) // Play delete click sound repeatedly
            backspaceHandler?.postDelayed(this, 100) // Repeat every 100 milliseconds!
        }
    }

    // Comprehensive dictionary strictly filtered (no ظطضصثقفغعخ)
    private val balorabiVocab = listOf(
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
    )

    private val balotinVocab = listOf(
        "Ars", "Àmàd", "Àzmàn", "Àsbàr", "Baròt", "Romb", "Cànk", "Do càpī", "Dywàl", "Dràj",
        "Ďung", "Ďal", "Ešk", "Èdàm", "Bèr", "Ispèt", "Ganš", "Gub", "Gwàrag", "Haik",
        "Hàl", "Hašt", "Kirr", "Kappagī", "Lahm", "Laškar", "Màdag", "Màr", "Nambèg", "Nihèpag",
        "Ustum", "Ustàz", "Òlàk", "Òšt", "Pattar", "Pit", "Poll", "Rung", "Ràhšòn", "Siyàh",
        "Sangat", "Suhl", "Šàšk", "Šaš", "Šahdarbarjàh", "Tal", "Talàr", "Ťak", "Ťràšò", "Hur",
        "Wail", "Wàhag", "Yal", "Zahèr", "Ziďď", "Zàl", "Žàng", "Bòž", "Balòc", "Balòcestàn", "Balòcī",
        "Salàm", "Vàlaik", "Čònai", "Man", "Vašaon", "Tà", "Han", "Ce", "Hàl", "Ent", "Vaš", "Salàmati", "Jòďī",
        "Haur", "Jambar", "Estin", "Estun", "Grand", "Goròk", "Tramp", "Tròngal", "Guàt", "Sangol", 
        "Sohr", "Bir", "Guàrag", "Hàr", "Kaur", "Šèp", "Luď", "Lahď", "Baččag", "Baččènag", 
        "Baččènòk", "Bačchetagèn", "Bačchèntag", "Baččòk", "Musàm", "Nimròc", "Waďènag", "Waďènòk", 
        "Jòďènag", "Jòďènòk", "Banènag", "Banènòk", "Banèntagèn", "Aď", "Šarr", "Šauk", "Zabardast"
    )

    // Long press mapping hints
    private val longPressMappings = mapOf(
        "ت" to listOf("ث", "ط"),
        "ج" to listOf("ح"),
        "چ" to listOf("خ"),
        "د" to listOf("ذ"),
        "س" to listOf("ص"),
        "ز" to listOf("ض", "ظ"),
        "ا" to listOf("ع", "آ", "أ", "إ"),
        "گ" to listOf("غ"),
        "پ" to listOf("ف"),
        "ک" to listOf("ق"),
        "ھ" to listOf("ہ", "هـ", "ح", "ه"), 
        "ء" to listOf("ع", "ءَ", "ءِ", "ءُ"),
        "و" to listOf("ۏ", "ؤ", "وْ", "وُ"),
        "ۏ" to listOf("و", "ؤ", "وْ", "وُ"),
        "ی" to listOf("ݔ", "ے", "یْ", "یٰ", "ئ"),
        "ن" to listOf("ں", "نٚ"),
        "ر" to listOf("ڑ"),
        "ژ" to listOf("ظ"),
        "۔" to listOf("ـ", "—", "-"), 
        "a" to listOf("á", "à", "æ"),
        "d" to listOf("ď"),
        "g" to listOf("ĝ"),
        "i" to listOf("í", "ì"),
        "r" to listOf("ř"),
        "s" to listOf("š"),
        "t" to listOf("ť"),
        "u" to listOf("ú", "ù"),
        "z" to listOf("ž")
    )

    override fun onCreateInputView(): View {
        val currentNightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
        isNightMode = currentNightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES

        // Inflate keyboard view
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        keyboardView = inflater.inflate(R.layout.keyboard_view, null)

        suggestionBar = keyboardView.findViewById(R.id.suggestion_bar)
        clipboardBar = keyboardView.findViewById(R.id.clipboard_bar)

        // Try loading the offline Amiri font compiled by Flutter dynamically!
        try {
            amiriTypeface = Typeface.createFromAsset(assets, "flutter_assets/assets/fonts/Amiri-Regular.ttf")
        } catch (e: Exception) {
            e.printStackTrace()
        }

        applyTheme()
        setupKeyboardLayout()
        updateClipboardSuggestions()
        updateWordPredictions("")

        return keyboardView
    }

    private fun applyTheme() {
        // Dynamic: Read customizable colors from Shared Preferences using getLong to prevent ClassCastException!
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        kbBgColor = prefs.getLong("flutter.kb_bg_color", if (isNightMode) 0xFF0F172A else 0xFFE2E8F0).toInt()
        keyBgColor = prefs.getLong("flutter.key_bg_color", if (isNightMode) 0xFF1E293B else 0xFFFFFFFF).toInt()
        keyTextColor = prefs.getLong("flutter.key_text_color", if (isNightMode) 0xFFFFFFFF else 0xFF111827).toInt()

        keyboardView.setBackgroundColor(kbBgColor)
    }

    // High-fidelity spanned text formatter (large main character in center, small red hint on top-right!)
    private fun getSpannedKeyText(mainKey: String): CharSequence {
        // If it's a technical key, just return plain icon/label
        if (mainKey == " " || mainKey == "SPACE" || mainKey == "BACKSPACE" || mainKey == "ENTER" || mainKey == "GLOBE" || mainKey == "SHIFT" || mainKey == "◀▶" || mainKey == "← 1/2" || mainKey == "2/2 →" || mainKey == "اب/ABC" || mainKey == "⌫" || mainKey == "⏎" || mainKey == "مان" || mainKey == "Màn") {
            return when (mainKey) {
                "SPACE", " " -> "␣"
                "BACKSPACE" -> "⌫"
                "ENTER" -> "⏎"
                "GLOBE" -> "🌐"
                "SHIFT" -> "⬆"
                else -> mainKey
            }
        }

        val hint = longPressMappings[mainKey]?.firstOrNull() ?: return mainKey
        val spanText = SpannableString("$mainKey $hint")
        
        // Large main key
        spanText.setSpan(AbsoluteSizeSpan(18, true), 0, mainKey.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(keyTextColor), 0, mainKey.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        
        // Small crimson red/purple alternative hint
        val hintStart = mainKey.length + 1
        spanText.setSpan(AbsoluteSizeSpan(10, true), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(0xFFDC2626.toInt()), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(RelativeSizeSpan(0.6f), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(SuperscriptSpan(), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        
        return spanText
    }

    private fun setupKeyboardLayout() {
        val layoutContainer = keyboardView.findViewById<LinearLayout>(R.id.keys_container)
        layoutContainer.removeAllViews()

        // Dynamic multi-mode layouts
        val rows = when (keyboardLayoutMode) {
            "balorabi" -> listOf(
                listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"),
                listOf("ے", "ی", "ڈ", "ٹ", "ۏ", "ء", "ھ", "ج", "چ", "ءِ"),
                listOf("ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"),
                listOf("◀▶", "ژ", "ز", "ر", "د", "و", "ک", "گ", "BACKSPACE"),
                listOf("؟۱۲۳", "GLOBE", "ZWNJ", "SPACE", "۔", "ENTER")
            )
            "balotin" -> listOf(
                listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
                listOf("À", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ť"),
                listOf("A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"),
                listOf("SHIFT", "Z", "Ž", "C", "È", "B", "N", "M", "BACKSPACE"),
                listOf("?123", "GLOBE", "SPACE", ".", "ENTER")
            )
            "symbols1" -> listOf(
                listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
                listOf("+", "×", "÷", "=", "٪", "^", "!", "@", "#", "$"),
                listOf("/", "\\", "~", "*", "(", ")", "-", "_", "|", "&"),
                listOf("2/2 →", "[", "]", "{", "}", "<", ">", "❂", "BACKSPACE"),
                listOf("اب/ABC", "SPACE", "ENTER")
            )
            else -> listOf( // "symbols2"
                listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"),
                listOf("،", "؟", "?", ".", ",", ":", ";", "\"", "'", "|"),
                listOf("❂", "Ꝃ", "★", "☆", "✦", "❖", "◈", "✿", "✛", "✜"),
                listOf("← 1/2", "⚔", "🌴", "🐫", "🏔", "☪", "✵", "✹", "BACKSPACE"),
                listOf("اب/ABC", "SPACE", "ENTER")
            )
        }

        val density = resources.displayMetrics.density
        val keyHeightPx = (45 * density).toInt() // COMPACT: comfortable 45dp height to match Flutter app!

        val isRtlMode = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2")

        for (row in rows) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                // Force RTL direction for Balorabi (Arabic) so keys flow naturally from right to left!
                layoutDirection = if (isRtlMode) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR
                
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            for (key in row) {
                val keyButton = Button(this).apply {
                    var displayKey = key
                    if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1 && key[0].isLetter()) {
                        displayKey = key.lowercase()
                    }
                    
                    text = getSpannedKeyText(displayKey)
                    setPadding(0, 0, 0, 0)
                    
                    // DYNAMIC HIGH-AESTHETIC STYLING (MATCHING FLUTTER EXACTLY!)
                    val keyDrawable = GradientDrawable().apply {
                        setColor(keyBgColor)
                        cornerRadius = 16f // 16px rounded corners matching simulator!
                        setStroke(1, 0x1A000000) 
                    }
                    background = keyDrawable
                    elevation = 4f 
                    
                    if (amiriTypeface != null) {
                        typeface = amiriTypeface
                    }
                    
                    // SPACEBAR WIDENING SUPPORT: Make spacebar button occupy exactly 40% of horizontal space!
                    val weight = if (key == " " || key == "SPACE") 3.0f else 1.0f
                    
                    layoutParams = LinearLayout.LayoutParams(0, keyHeightPx, weight).apply {
                        setMargins((2 * density).toInt(), (3 * density).toInt(), (2 * density).toInt(), (3 * density).toInt()) // Cozy identical margins!
                    }

                    // AUTO-REPEAT BACKSPACE: If key is BACKSPACE, apply the long-press auto-repeating touch listener!
                    if (key == "BACKSPACE") {
                        setOnTouchListener(object : View.OnTouchListener {
                            override fun onTouch(v: View, event: MotionEvent): Boolean {
                                when (event.action) {
                                    MotionEvent.ACTION_DOWN -> {
                                        // Delete immediately on press
                                        val ic = currentInputConnection
                                        ic?.deleteSurroundingText(1, 0)
                                        
                                        // Play standard keypress delete sound
                                        playKeyPressSound(AudioManager.FX_KEYPRESS_DELETE)
                                        
                                        // Start repeating timer after a 500ms initial holding delay
                                        if (backspaceHandler == null) {
                                            backspaceHandler = Handler(Looper.getMainLooper())
                                        }
                                        backspaceHandler?.postDelayed(backspaceRunnable, 500)
                                        return true
                                    }
                                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                                        // Stop repeating on lift
                                        backspaceHandler?.removeCallbacks(backspaceRunnable)
                                        return true
                                    }
                                }
                                return false
                            }
                        })
                    } else {
                        // Standard click listener for other keys
                        setOnClickListener { handleKeyPress(key) }
                        setOnLongClickListener { 
                            showLongPressPopup(this, key)
                            true 
                        }
                    }
                }
                rowLayout.addView(keyButton)
            }
            layoutContainer.addView(rowLayout)
        }
    }

    private fun isPunctuation(char: String): Boolean {
        val punc = listOf(" ", "\n", "،", "؟", "?", ".", ",", ":", ";", "\"", "'", "-", "_", "+", "×", "÷", "=", "۔", "ـ", "\u200C")
        return punc.contains(char)
    }

    // Play native system keypress sound effect if enabled in settings!
    private fun playKeyPressSound(effectType: Int) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val soundEnabled = prefs.getBoolean("flutter.kb_sound_enabled", true)
        if (soundEnabled) {
            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            am.playSoundEffect(effectType)
        }
    }

    private fun handleKeyPress(key: String) {
        val ic: InputConnection = currentInputConnection ?: return
        
        // Play appropriate keypress click sound natively!
        when (key) {
            "SPACE", " " -> playKeyPressSound(AudioManager.FX_KEYPRESS_SPACEBAR)
            "ENTER", "⏎" -> playKeyPressSound(AudioManager.FX_KEYPRESS_RETURN)
            else -> playKeyPressSound(AudioManager.FX_KEYPRESS_STANDARD)
        }

        when (key) {
            "SPACE", " " -> {
                ic.commitText(" ", 1)
                updateWordPredictions("")
            }
            "BACKSPACE", "⌫" -> {
                ic.deleteSurroundingText(1, 0)
                updateWordPredictions("")
            }
            "ENTER", "⏎", "مان", "Màn" -> {
                ic.commitText("\n", 1)
                updateWordPredictions("")
            }
            "GLOBE" -> {
                keyboardLayoutMode = if (keyboardLayoutMode == "balorabi") "balotin" else "balorabi"
                setupKeyboardLayout()
            }
            "ABC" -> {
                keyboardLayoutMode = "balotin"
                setupKeyboardLayout()
            }
            "اب ..." -> {
                keyboardLayoutMode = "balorabi"
                setupKeyboardLayout()
            }
            "؟۱۲۳", "?123" -> {
                keyboardLayoutMode = "symbols1"
                setupKeyboardLayout()
            }
            "2/2 →" -> {
                keyboardLayoutMode = "symbols2"
                setupKeyboardLayout()
            }
            "← 1/2" -> {
                keyboardLayoutMode = "symbols1"
                setupKeyboardLayout()
            }
            "اب/ABC" -> {
                keyboardLayoutMode = if (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2") "balorabi" else "balotin"
                setupKeyboardLayout()
            }
            "SHIFT", "⬆" -> {
                isShiftActive = !isShiftActive
                setupKeyboardLayout() 
            }
            "ZWNJ" -> {
                ic.commitText("\u200C", 1) // Commit Zero Width Non-Joiner!
            }
            else -> {
                var typedKey = key
                if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1) {
                    typedKey = key.lowercase()
                }

                val preceding = ic.getTextBeforeCursor(1, 0)
                if (preceding != null && preceding == "ے" && typedKey.isNotEmpty() && !isPunctuation(typedKey)) {
                    ic.deleteSurroundingText(1, 0)
                    ic.commitText("ݔ", 1)
                }
                
                ic.commitText(typedKey, 1)
                val currentWord = ic.getTextBeforeCursor(10, 0)?.split(" ")?.lastOrNull() ?: ""
                updateWordPredictions(currentWord.toString())
            }
        }
    }

    private fun showLongPressPopup(anchorView: View, key: String) {
        val alternatives = longPressMappings[key] ?: return
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val popupView = inflater.inflate(R.layout.popup_keyboard, null) as LinearLayout
        
        val popupWindow = PopupWindow(
            popupView,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            true
        )

        for (alt in alternatives) {
            val altButton = Button(this).apply {
                text = alt
                if (amiriTypeface != null) {
                    typeface = amiriTypeface
                }
                setOnClickListener {
                    val ic: InputConnection = currentInputConnection
                    ic.commitText(alt, 1)
                    popupWindow.dismiss()
                }
            }
            popupView.addView(altButton)
        }

        popupWindow.showAsDropDown(anchorView, 0, -anchorView.height - 100, Gravity.CENTER)
    }

    private fun updateWordPredictions(currentWord: String) {
        suggestionBar.removeAllViews()
        if (currentWord.isEmpty()) return

        val vocabList = if (keyboardLayoutMode == "balorabi") balorabiVocab else balotinVocab
        val predictions = vocabList.filter { it.startsWith(currentWord, ignoreCase = true) }.take(4)

        for (word in predictions) {
            val suggestionView = TextView(this).apply {
                text = word
                textSize = 16f
                if (amiriTypeface != null) {
                    typeface = amiriTypeface
                }
                setPadding(20, 10, 20, 10)
                setTextColor(keyTextColor)
                setOnClickListener {
                    replaceCurrentWord(currentWord, word)
                }
            }
            suggestionBar.addView(suggestionView)
        }
    }

    private fun replaceCurrentWord(oldWord: String, newWord: String) {
        val ic: InputConnection = currentInputConnection ?: return
        ic.deleteSurroundingText(oldWord.length, 0)
        ic.commitText("$newWord ", 1)
        updateWordPredictions("")
    }

    private fun updateClipboardSuggestions() {
        clipboardBar.removeAllViews()
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        if (clipboard.hasPrimaryClip() && (clipboard.primaryClipDescription?.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN) == true)) {
            val item = clipboard.primaryClip?.getItemAt(0)
            val clipText = item?.text?.toString() ?: return

            if (clipText.isNotEmpty()) {
                val clipView = TextView(this).apply {
                    text = "📋 " + if (clipText.length > 15) clipText.take(12) + "..." else clipText
                    textSize = 14f
                    if (amiriTypeface != null) {
                        typeface = amiriTypeface
                    }
                    setPadding(15, 10, 15, 10)
                    setTextColor(keyTextColor)
                    setOnClickListener {
                        val ic: InputConnection = currentInputConnection
                        ic.commitText(clipText, 1)
                    }
                }
                clipboardBar.addView(clipView)
            }
        }
    }
}
