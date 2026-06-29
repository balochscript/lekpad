package bc.lekpad.balochi

import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.inputmethodservice.InputMethodService
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
import android.provider.Settings
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

class BalochiInputMethod : InputMethodService() {

    private lateinit var keyboardView: View
    private var suggestionBar: LinearLayout? = null
    private var clipboardBar: LinearLayout? = null
    private var isNightMode: Boolean = false
    
    private var keyboardLayoutMode: String = "balorabi" 
    private var isShiftActive: Boolean = false

    private var kbBgColor: Int = 0xFF0F172A.toInt()
    private var keyBgColor: Int = 0xFF1E293B.toInt()
    private var keyTextColor: Int = 0xFFFFFFFF.toInt()
    private var amiriTypeface: Typeface? = null

    private var backspaceHandler: Handler? = null
    private val backspaceRunnable = object : Runnable {
        override fun run() {
            val ic = currentInputConnection
            ic?.deleteSurroundingText(1, 0)
            playKeyPressSound()
            backspaceHandler?.postDelayed(this, 50)
        }
    }

    private var soundPool: SoundPool? = null
    private var soundId: Int = -1
    private var soundVolume: Float = 0.5f

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
        "بچَّگ", "بچّنَگ", "بچّنۏک", "بچِّتگیں", "بچّنتگ", "بچّۏک", "مُسام", "نِمرۏچ", 
        "وَڈݔنَگ", "وَڈݔنۏک", "جۏڈݔنَگ", "جۏڈݔنۏک", "بَنݔنَگ", "بَنݔنۏک", "بَنݔنتگیں", "اَڈ", 
        "شَرر", "شؤک", "زَبَردَست", "مئی", "نن", "ھؤ", "چے", "کوئ", "کُجئ", "کجا", "کۏ", "کئ",
        "بیتَگ", "شُت", "آتک", "آتکَگ", "وَلا", "نامھُدا", "پوکو", "بگوَش", "ھُدایی", "مَھرنگ",
        "بݔکار", "دَزبَند", "دَزگوھار", "بۏگ", "مَٹ", "اوڈہ", "چُپت", "جاتیگ", "کَلمانٹ",
        "لُنڈ", "لَوَند", "چاپتال", "چَپورت", "ایماندار", "چاکَلݔٹ"
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
        "Baččènòk", "Bačchetagèn", "Baččèntag", "Baččòk", "Musàm", "Nimròc", "Waďènag", "Waďènòk", 
        "Jòďènag", "Jòďènòk", "Banènag", "Banènòk", "Banèntagèn", "Aď", "Šarr", "Šauk", "Zabardast",
        "Mai", "Nan", "Hau", "Cè", "Kuae", "Kojae", "Koja", "Kò", "Kae", "Bitag", "Šot", "Àtk",
        "Àtkag", "Walla", "Nàmhoda", "Poko", "Beguaš", "Hodayi", "Mahrang", "Bèkàr", "Dazband",
        "Dazguhar", "Bòg", "Mať", "Oďe", "Copt", "Jàtig", "Kalmànť", "Lonď", "Lawand", "Càptàl",
        "Capurt", "Imàndàr", "Càkalèť"
    )

    private val longPressMappings = mapOf(
        "ت" to listOf("ث", "ط", "ّ"),
        "ج" to listOf("ح"),
        "چ" to listOf("خ"),
        "د" to listOf("ذ"),
        "س" to listOf("ص"),
        "ز" to listOf("ض", "ظ"),
        "ا" to listOf("ع", "آ", "أ", "إ", "َ", "ِ", "ُ"),
        "گ" to listOf("غ"),
        "پ" to listOf("ف"),
        "ک" to listOf("ق"),
        "ھ" to listOf("ہ", "هـ", "ح", "ه"), 
        "ء" to listOf("ع", "ءَ", "ءِ", "ءُ"),
        "و" to listOf("ؤ", "وْ"),
        "ۏ" to listOf("ۇ", "وُ"),
        "ی" to listOf("ئی", "ئ", "ۓ"),
        "ے/ݔ" to listOf("ݔ", "یٚ"),
        "ن" to listOf("ں", "نٚ", "ْ"),
        "ر" to listOf("ڑ"),
        "ژ" to listOf("ظ"),
        "۔" to listOf("ـ", "—", "-"),
        "◀▶" to listOf("\u200C", "\u200D", "\u200B"),
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

    override fun onCreate() {
        super.onCreate()
        initSoundPool()
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            soundPool?.release()
        } catch (e: Exception) {}
        soundPool = null
    }

    private fun initSoundPool() {
        try {
            soundPool = SoundPool.Builder().setMaxStreams(1).build()
            soundId = soundPool?.load(this, R.raw.key_click, 1) ?: -1
        } catch (e: Exception) {
            soundId = -1
        }
    }

    override fun onCreateInputView(): View {
        val currentNightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
        isNightMode = currentNightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        keyboardView = inflater.inflate(R.layout.keyboard_view, null)

        try {
            suggestionBar = keyboardView.findViewById(R.id.suggestion_bar)
            clipboardBar = keyboardView.findViewById(R.id.clipboard_bar)
        } catch (e: Exception) {}

        try {
            amiriTypeface = Typeface.createFromAsset(assets, "flutter_assets/assets/fonts/Amiri-Regular.ttf")
        } catch (e: Exception) {}

        applyTheme()
        setupKeyboardLayout()
        updateClipboardSuggestions()
        updateWordPredictions("")

        return keyboardView
    }

    private fun applyTheme() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val kbBgHex = prefs.getString("flutter.kb_bg_color_hex", null)
            val keyBgHex = prefs.getString("flutter.key_bg_color_hex", null)
            val keyTextHex = prefs.getString("flutter.key_text_color_hex", null)
            
            kbBgColor = if (kbBgHex != null) android.graphics.Color.parseColor(kbBgHex) 
                        else if (isNightMode) 0xFF0F172A.toInt() else 0xFFE2E8F0.toInt()
            
            keyBgColor = if (keyBgHex != null) android.graphics.Color.parseColor(keyBgHex) 
                         else if (isNightMode) 0xFF1E293B.toInt() else 0xFFFFFFFF.toInt()
            
            keyTextColor = if (keyTextHex != null) android.graphics.Color.parseColor(keyTextHex) 
                           else if (isNightMode) 0xFFFFFFFF.toInt() else 0xFF111827.toInt()

            soundVolume = prefs.getFloat("flutter.kb_sound_volume", 0.5f)
        } catch (e: Exception) {
            kbBgColor = if (isNightMode) 0xFF0F172A.toInt() else 0xFFE2E8F0.toInt()
            keyBgColor = if (isNightMode) 0xFF1E293B.toInt() else 0xFFFFFFFF.toInt()
            keyTextColor = if (isNightMode) 0xFFFFFFFF.toInt() else 0xFF111827.toInt()
            soundVolume = 0.5f
        }
        
        keyboardView.setBackgroundColor(kbBgColor)
    }

    private fun getSpannedKeyText(mainKey: String): CharSequence {
        if (mainKey == " " || mainKey == "SPACE" || mainKey == "BACKSPACE" || mainKey == "ENTER" || mainKey == "GLOBE" || mainKey == "SHIFT" || mainKey == "◀▶" || mainKey == "← 1/2" || mainKey == "2/2 →" || mainKey == "اب/ABC" || mainKey == "⌫" || mainKey == "⏎" || mainKey == "مان" || mainKey == "Màn" || mainKey == "⚙️") {
            return when (mainKey) {
                "SPACE", " " -> "␣"
                "BACKSPACE" -> "⌫"
                "ENTER" -> "⏎"
                "GLOBE" -> "🌐"
                "SHIFT" -> "⬆"
                "⚙️" -> "⚙️"
                "◀▶" -> "◀▶"
                else -> mainKey
            }
        }

        val hint = longPressMappings[mainKey]?.firstOrNull() ?: return mainKey
        val spanText = SpannableString("$mainKey $hint")
        
        spanText.setSpan(AbsoluteSizeSpan(18, true), 0, mainKey.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(keyTextColor), 0, mainKey.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        
        val hintStart = mainKey.length + 1
        spanText.setSpan(AbsoluteSizeSpan(10, true), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(0xFFDC2626.toInt()), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(RelativeSizeSpan(0.6f), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(SuperscriptSpan(), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        
        return spanText
    }

    private fun setupKeyboardLayout() {
        val layoutContainer = keyboardView.findViewById<LinearLayout>(R.id.keys_container) ?: return
        layoutContainer.removeAllViews()

        val rows = when (keyboardLayoutMode) {
            "balorabi" -> listOf(
                listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"),
                listOf("ے/ݔ", "ڈ", "ٹ", "ۏ", "ء", "ھ", "ج", "چ", "ءِ"),
                listOf("ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"),
                listOf("⚙️", "ژ", "ز", "ر", "د", "و", "ک", "گ", "BACKSPACE"),
                listOf("؟۱۲۳", "GLOBE", "◀▶", "SPACE", "۔", "ENTER")
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
            else -> listOf(
                listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"),
                listOf("،", "؟", "?", ".", ",", ":", ";", "\"", "'", "|"),
                listOf("❂", "Ꝃ", "★", "☆", "✦", "❖", "◈", "✿", "✛", "✜"),
                listOf("← 1/2", "⚔", "🌴", "🐫", "🏔", "☪", "✵", "✹", "BACKSPACE"),
                listOf("اب/ABC", "SPACE", "ENTER")
            )
        }

        val density = resources.displayMetrics.density
        val keyHeightPx = (48 * density).toInt()
        val isRtlMode = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2")

        for (row in rows) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutDirection = if (isRtlMode) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR
                layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            }

            for (key in row) {
                val keyButton = Button(this).apply {
                    var displayKey = key
                    if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1 && key[0].isLetter()) {
                        displayKey = key.lowercase()
                    }
                    
                    text = getSpannedKeyText(displayKey)
                    setTextColor(keyTextColor)
                    setPadding(0, 0, 0, 0)
                    
                    val currentKeyBg = when (key) {
                        "BACKSPACE", "⌫" -> if (isNightMode) 0xFF7F1D1D.toInt() else 0xFFFEE2E2.toInt()
                        "ENTER", "⏎" -> if (isNightMode) 0xFF064E3B.toInt() else 0xFFD1FAE5.toInt()
                        "⚙️" -> if (isNightMode) 0xFF475569.toInt() else 0xFFE2E8F0.toInt()
                        else -> keyBgColor
                    }
                    
                    val keyDrawable = GradientDrawable().apply {
                        setColor(currentKeyBg)
                        cornerRadius = 8f
                        setStroke(1, 0x1A000000) 
                    }
                    background = keyDrawable
                    elevation = 2f 
                    if (amiriTypeface != null) typeface = amiriTypeface
                    
                    val weight = if (key == " " || key == "SPACE") 3.0f else 1.0f
                    layoutParams = LinearLayout.LayoutParams(0, keyHeightPx, weight).apply {
                        setMargins((2 * density).toInt(), (2 * density).toInt(), (2 * density).toInt(), (2 * density).toInt())
                    }

                    if (key == "BACKSPACE") {
                        setOnTouchListener { _, event ->
                            when (event.action) {
                                MotionEvent.ACTION_DOWN -> {
                                    currentInputConnection?.deleteSurroundingText(1, 0)
                                    playKeyPressSound()
                                    if (backspaceHandler == null) backspaceHandler = Handler(Looper.getMainLooper())
                                    backspaceHandler?.postDelayed(backspaceRunnable, 500)
                                    true
                                }
                                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                                    backspaceHandler?.removeCallbacks(backspaceRunnable)
                                    true
                                }
                                else -> false
                            }
                        }
                    } else {
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

    private fun playKeyPressSound() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val soundEnabled = prefs.getBoolean("flutter.kb_sound_enabled", true)
            if (soundEnabled && soundId != -1) {
                soundPool?.play(soundId, soundVolume, soundVolume, 1, 0, 1.0f)
            }
        } catch (e: Exception) {}
    }

    private fun handleKeyPress(key: String) {
        val ic: InputConnection = currentInputConnection ?: return
        playKeyPressSound()

        when (key) {
            "SPACE", " " -> { ic.commitText(" ", 1); updateWordPredictions("") }
            "BACKSPACE", "⌫" -> { ic.deleteSurroundingText(1, 0); updateWordPredictions("") }
            "ENTER", "⏎", "مان", "Màn" -> { ic.commitText("\n", 1); updateWordPredictions("") }
            "GLOBE" -> { keyboardLayoutMode = if (keyboardLayoutMode == "balorabi") "balotin" else "balorabi"; setupKeyboardLayout() }
            "⚙️" -> {
                try {
                    val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
                    startActivity(intent)
                } catch (e: Exception) {}
            }
            "؟۱۲۳", "?123" -> { keyboardLayoutMode = "symbols1"; setupKeyboardLayout() }
            "2/2 →" -> { keyboardLayoutMode = "symbols2"; setupKeyboardLayout() }
            "← 1/2" -> { keyboardLayoutMode = "symbols1"; setupKeyboardLayout() }
            "اب/ABC" -> { keyboardLayoutMode = if (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2") "balorabi" else "balotin"; setupKeyboardLayout() }
            "SHIFT", "⬆" -> { isShiftActive = !isShiftActive; setupKeyboardLayout() }
            "◀▶" -> { ic.commitText("\u200C", 1) }
            "ے/ݔ" -> {
                ic.commitText("ے", 1)
                val currentWord = ic.getTextBeforeCursor(20, 0)?.split(" ")?.lastOrNull() ?: ""
                updateWordPredictions(currentWord)
            }
            else -> {
                var typedKey = key
                if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1) typedKey = key.lowercase()

                val preceding = ic.getTextBeforeCursor(1, 0)
                if (preceding != null && preceding == "ے" && typedKey.isNotEmpty() && !isPunctuation(typedKey)) {
                    ic.deleteSurroundingText(1, 0)
                    ic.commitText("ݔ", 1)
                }
                
                ic.commitText(typedKey, 1)
                val currentWord = ic.getTextBeforeCursor(20, 0)?.split(" ")?.lastOrNull() ?: ""
                updateWordPredictions(currentWord)
            }
        }
    }

    private fun showLongPressPopup(anchorView: View, key: String) {
        val alternatives = longPressMappings[key] ?: return
        try {
            val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            val popupView = inflater.inflate(R.layout.popup_keyboard, null) as LinearLayout
            
            popupView.setBackgroundColor(keyBgColor)
            popupView.setPadding(16, 12, 16, 12)
            
            val popupWindow = PopupWindow(popupView, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, true)

            for (alt in alternatives) {
                val altButton = Button(this).apply {
                    text = alt
                    textSize = 20f
                    setTextColor(keyTextColor)
                    if (amiriTypeface != null) typeface = amiriTypeface
                    
                    val buttonDrawable = GradientDrawable().apply {
                        setColor(kbBgColor)
                        cornerRadius = 12f
                        setStroke(2, 0xFFD97706.toInt())
                    }
                    background = buttonDrawable
                    setPadding(24, 12, 24, 12)
                    
                    setOnClickListener {
                        currentInputConnection?.commitText(alt, 1)
                        playKeyPressSound()
                        popupWindow.dismiss()
                    }
                }
                popupView.addView(altButton)
            }
            popupWindow.showAsDropDown(anchorView, 0, -anchorView.height - 120, Gravity.CENTER)
        } catch (e: Exception) {}
    }

    private fun updateWordPredictions(currentWord: String) {
        suggestionBar?.removeAllViews()
        if (currentWord.isEmpty() || suggestionBar == null) return

        val vocabList = if (keyboardLayoutMode == "balorabi") balorabiVocab else balotinVocab
        val normalizedCurrentWord = currentWord.replace("ݔ", "ے")
        val predictions = vocabList.filter { 
            it.replace("ݔ", "ے").startsWith(normalizedCurrentWord, ignoreCase = true)
        }.take(4)

        for (word in predictions) {
            val suggestionView = TextView(this).apply {
                text = word
                textSize = 16f
                if (amiriTypeface != null) typeface = amiriTypeface
                setPadding(20, 10, 20, 10)
                setTextColor(keyTextColor)
                setOnClickListener { replaceCurrentWord(currentWord, word) }
            }
            suggestionBar?.addView(suggestionView)
        }
    }

    private fun replaceCurrentWord(oldWord: String, newWord: String) {
        val ic: InputConnection = currentInputConnection ?: return
        ic.deleteSurroundingText(oldWord.length, 0)
        ic.commitText("$newWord ", 1)
        playKeyPressSound()
        updateWordPredictions("")
    }

    private fun updateClipboardSuggestions() {
        clipboardBar?.removeAllViews()
        try {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            if (clipboard.hasPrimaryClip() && (clipboard.primaryClipDescription?.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN) == true)) {
                val clipText = clipboard.primaryClip?.getItemAt(0)?.text?.toString() ?: return

                if (clipText.isNotEmpty()) {
                    val clipView = TextView(this).apply {
                        text = "📋 " + if (clipText.length > 15) clipText.take(12) + "..." else clipText
                        textSize = 14f
                        if (amiriTypeface != null) typeface = amiriTypeface
                        setPadding(15, 10, 15, 10)
                        setTextColor(keyTextColor)
                        setOnClickListener {
                            currentInputConnection?.commitText(clipText, 1)
                            playKeyPressSound()
                        }
                    }
                    clipboardBar?.addView(clipView)
                }
            }
        } catch (e: Exception) {}
    }
}
