package bc.lekpad.balochi

import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.media.SoundPool
import android.os.Handler
import android.os.Looper
import android.text.Spannable
import android.text.SpannableString
import android.text.TextUtils
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.text.style.SuperscriptSpan
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class BalochiInputMethod : InputMethodService() {

    private lateinit var keyboardView: View
    private var suggestionBar: LinearLayout? = null
    private var keysContainer: LinearLayout? = null
    private var clipboardFullView: LinearLayout? = null
    private var clipboardListContainer: LinearLayout? = null
    private var isNightMode: Boolean = false
    
    private var keyboardLayoutMode: String = "balorabi" 
    private var isShiftActive: Boolean = false

    private var kbBgColor: Int = 0xFF0F172A.toInt()
    private var keyBgColor: Int = 0xFF1E293B.toInt()
    private var keyTextColor: Int = 0xFFFFFFFF.toInt()
    private var amiriTypeface: Typeface? = null
    private var isSoundEnabled: Boolean = true
    private var soundVolume: Float = 0.5f

    private var backspaceHandler: Handler? = null
    private val backspaceRunnable = object : Runnable {
        override fun run() {
            val ic = currentInputConnection
            val selectedText = ic?.getSelectedText(0)
            if (TextUtils.isEmpty(selectedText)) {
                ic?.deleteSurroundingText(1, 0)
            } else {
                ic?.commitText("", 1)
            }
            playKeyPressSound()
            backspaceHandler?.postDelayed(this, 50)
        }
    }

    private var soundPool: SoundPool? = null
    private var soundId: Int = -1

    private lateinit var clipboardManager: ClipboardManager
    private val MAX_CLIPBOARD_ITEMS = 40
    private val CLIPBOARD_EXPIRY_MS = TimeUnit.HOURS.toMillis(24)

    private val clipboardListener = ClipboardManager.OnPrimaryClipChangedListener {
        checkAndSaveClipboard()
    }

    private val balorabiVocab = listOf("اَرس", "آماد", "آسمان", "آسبار", "بَرۏت", "رُمب", "چانٚک", "دو چاپی", "دیوال", "دراج", "ڈُنگ", "ڈَل", "اِشک", "اݔدام", "بݔر", "اِسبݔت", "گَنش", "گُب", "گوارَگ", "ھئیک", "ھال", "ھَشت", "کِرر", "کَپپَگی", "لَھم", "لَشکَر", "مادَگ", "مار", "نَمیبگ", "نِھݔپَگ", "اُستُم", "اُستاز", "اۏلاک", "اۏشت", "پَتتَر", "پِت", "پُلل", "رُنگ", "راھشۏن", "سیاہ", "سَنگَت", "سُھل", "شاشک", "شَش", "شَھدَربرجاہ", "تَل", "تَلار", "ٹاک", "ٹراشو", "ھور", "وئیل", "واھَگ", "یَل", "زَھیر", "زِڈڈ", "زال", "ژانگ", "بوژ", "بلۏچ", "بلۏچستان", "بلۏچی", "سَلام", "والِک", "چونَے", "چونے", "مَن", "وشوں", "تَو", "هَں", "چہ", "هال", "اِنت", "وَش", "سَلامتے", "جۏڑی", "هَور", "جمبر", "استین", "استون", "گرند", "گُرۏک", "ترَمپ", "ترۏنگل", "گوات", "سَنگُل", "سُهر", "بیر", "گوارَگ", "هار", "کَور", "شݔپ", "لوڈ", "لَهڈ", "بچَّگ", "بچّنَگ", "بچّنۏک", "بچِّتگیں", "بچّنتگ", "بچّۏک", "مُسام", "نِمرۏچ", "وَڈݔنَگ", "وَڈݔنۏک", "جۏڈݔنَگ", "جۏڈݔنۏک", "بَنݔنَگ", "بَنݔنۏک", "بَنݔنتگیں", "اَڈ", "شَرر", "شؤک", "زَبَردَست", "مئی", "نن", "ھؤ", "چے", "کوئ", "کُجئ", "کجا", "کۏ", "کئ", "بیتَگ", "شُت", "آتک", "آتکَگ", "وَلا", "نامھُدا", "پوکو", "بگوَش", "ھُدایی", "مَھرنگ", "بݔکار", "دَزبَند", "دَزگوھار", "بۏگ", "مَٹ", "اوڈہ", "چُپت", "جاتیگ", "کَلمانٹ", "لُنڈ", "لَوَند", "چاپتال", "چَپورت", "ایماندار", "چاکَلݔٹ")
    private val balotinVocab = listOf("Ars", "Àmàd", "Àzmàn", "Àsbàr", "Baròt", "Romb", "Cànk", "Do càpī", "Dywàl", "Dràj", "Ďung", "Ďal", "Ešk", "Èdàm", "Bèr", "Ispèt", "Ganš", "Gub", "Gwàrag", "Haik", "Hàl", "Hašt", "Kirr", "Kappagī", "Lahm", "Laškar", "Màdag", "Màr", "Nambèg", "Nihèpag", "Ustum", "Ustàz", "Òlàk", "Òšt", "Pattar", "Pit", "Poll", "Rung", "Ràhšòn", "Siyàh", "Sangat", "Suhl", "Šàšk", "Šaš", "Šahdarbarjàh", "Tal", "Talàr", "Ťak", "Ťràšò", "Hur", "Wail", "Wàhag", "Yal", "Zahèr", "Ziďď", "Zàl", "Žàng", "Bòž", "Balòc", "Balòcestàn", "Balòcī", "Salàm", "Vàlaik", "Čònai", "Man", "Vašaon", "Tà", "Han", "Ce", "Hàl", "Ent", "Vaš", "Salàmati", "Jòďī", "Haur", "Jambar", "Estin", "Estun", "Grand", "Goròk", "Tramp", "Tròngal", "Guàt", "Sangol", "Sohr", "Bir", "Guàrag", "Hàr", "Kaur", "Šèp", "Luď", "Lahď", "Baččag", "Baččènag", "Baččènòk", "Bačchetagèn", "Baččèntag", "Baččòk", "Musàm", "Nimròc", "Waďènag", "Waďènòk", "Jòďènag", "Jòďènòk", "Banènag", "Banènòk", "Banèntagèn", "Aď", "Šarr", "Šauk", "Zabardast", "Mai", "Nan", "Hau", "Cè", "Kuae", "Kojae", "Koja", "Kò", "Kae", "Bitag", "Šot", "Àtk", "Àtkag", "Walla", "Nàmhoda", "Poko", "Beguaš", "Hodayi", "Mahrang", "Bèkàr", "Dazband", "Dazguhar", "Bòg", "Mať", "Oďe", "Copt", "Jàtig", "Kalmànť", "Lonď", "Lawand", "Càptàl", "Capurt", "Imàndàr", "Càkalèť")
    
    private val longPressMappings = mapOf(
        "ت" to listOf("ث", "ط"), 
        "ج" to listOf("ح"), 
        "چ" to listOf("خ", "ځ"), 
        "د" to listOf("ذ"), 
        "س" to listOf("ص"),
        "ز" to listOf("ض", "ظ"), 
        "ا" to listOf("آ", "أ", "إ", "َ", "ِ", "ُ", "ّ", "ْ", "ٚ", "ٝ"), 
        "گ" to listOf("غ"), 
        "پ" to listOf("ف"), 
        "ک" to listOf("ق"), 
        "ھ" to listOf("ہ", "هـ", "ه", "ة", "ۀ"), 
        "ء" to listOf("ع", "ءَ", "ءِ", "ءُ"),
        "و" to listOf("ؤ", "ۆ", "ۇ"), 
        "ۏ" to listOf("وُ"), 
        "ی" to listOf("ئ", "ي", "ۓ", "ئی"), 
        "ے/ݔ" to listOf("یٚ"),
        "ن" to listOf("ں", "نٚ", "ڻ"), 
        "ر" to listOf("ڑ"), 
        "ل" to listOf("ڷ", "ڵ"), 
        "۔" to listOf("ـ", "—", "-"),
        "◀▶" to listOf("\u200C", "\u200D", "\u200B"), 
        "a" to listOf("á", "æ", "â", "ä"), 
        "e" to listOf("é", "ê", "ë"),
        "g" to listOf("ĝ"), 
        "i" to listOf("í", "ì", "î", "ï"), 
        "o" to listOf("ó", "ô", "ö"),
        "r" to listOf("ř"), 
        "u" to listOf("ú", "ù", "û", "ü")
    )

    override fun onCreate() {
        super.onCreate()
        clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboardManager.addPrimaryClipChangedListener(clipboardListener)
        initSoundPool()
    }

    private fun checkAndSaveClipboard() {
        try {
            if (clipboardManager.hasPrimaryClip()) {
                val item = clipboardManager.primaryClip?.getItemAt(0)
                val text = item?.coerceToText(this)?.toString()
                if (!text.isNullOrBlank()) {
                    saveToClipboardHistory(text)
                    if (clipboardFullView?.visibility == View.VISIBLE) {
                        populateClipboardFullView()
                    }
                }
            }
        } catch (e: Exception) {}
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        checkAndSaveClipboard()
        applyTheme()
        setupKeyboardLayout()
        updateWordPredictions("")
        closeClipboardView()
    }

    override fun onDestroy() {
        super.onDestroy()
        clipboardManager.removePrimaryClipChangedListener(clipboardListener)
        soundPool?.release()
        soundPool = null
    }

    private fun initSoundPool() {
        try {
            soundPool = SoundPool.Builder().setMaxStreams(1).build()
            soundId = soundPool?.load(this, R.raw.key_click, 1) ?: -1
        } catch (e: Exception) {}
    }

    override fun onCreateInputView(): View {
        val currentNightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
        isNightMode = currentNightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        keyboardView = inflater.inflate(R.layout.keyboard_view, null)

        suggestionBar = keyboardView.findViewById(R.id.suggestion_bar)
        keysContainer = keyboardView.findViewById(R.id.keys_container)
        clipboardFullView = keyboardView.findViewById(R.id.clipboard_full_view)
        clipboardListContainer = keyboardView.findViewById(R.id.clipboard_list_container)

        keyboardView.findViewById<TextView>(R.id.btn_open_clipboard)?.setOnClickListener {
            toggleClipboardView()
        }
        keyboardView.findViewById<TextView>(R.id.btn_close_clipboard)?.setOnClickListener {
            closeClipboardView()
        }

        try { amiriTypeface = Typeface.createFromAsset(assets, "flutter_assets/assets/fonts/Amiri-Regular.ttf") } catch (e: Exception) {}

        applyTheme()
        setupKeyboardLayout()
        updateWordPredictions("")
        return keyboardView
    }

    private fun applyTheme() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val kbBgHex = prefs.getString("flutter.kb_bg_color_hex", null)
            val keyBgHex = prefs.getString("flutter.key_bg_color_hex", null)
            val keyTextHex = prefs.getString("flutter.key_text_color_hex", null)
            
            kbBgColor = if (kbBgHex != null) android.graphics.Color.parseColor(kbBgHex) else if (isNightMode) 0xFF0F172A.toInt() else 0xFFE2E8F0.toInt()
            keyBgColor = if (keyBgHex != null) android.graphics.Color.parseColor(keyBgHex) else if (isNightMode) 0xFF1E293B.toInt() else 0xFFFFFFFF.toInt()
            keyTextColor = if (keyTextHex != null) android.graphics.Color.parseColor(keyTextHex) else if (isNightMode) 0xFFFFFFFF.toInt() else 0xFF111827.toInt()

            isSoundEnabled = prefs.getBoolean("flutter.kb_sound_enabled", true)
            
            val volPref = prefs.all["flutter.kb_sound_volume"]
            soundVolume = when (volPref) {
                is Double -> volPref.toFloat()
                is Float -> volPref
                is String -> volPref.toFloatOrNull() ?: 0.5f
                else -> 0.5f
            }
        } catch (e: Exception) {}
        
        keyboardView.setBackgroundColor(kbBgColor)
        clipboardFullView?.setBackgroundColor(kbBgColor)
        keyboardView.findViewById<TextView>(R.id.btn_open_clipboard)?.setTextColor(keyTextColor)
    }

    private fun playKeyPressSound() {
        if (!isSoundEnabled) return
        try {
            if (soundId != -1) {
                soundPool?.play(soundId, soundVolume, soundVolume, 1, 0, 1.0f)
            } else {
                (getSystemService(Context.AUDIO_SERVICE) as AudioManager).playSoundEffect(AudioManager.FX_KEYPRESS_STANDARD, soundVolume)
            }
        } catch (e: Exception) {}
    }

    private fun setupKeyboardLayout() {
        keysContainer?.removeAllViews()
        val density = resources.displayMetrics.density
        val keyHeightPx = (48 * density).toInt()

        val rows = getRowsForMode()
        val isRtlMode = (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2")

        for (row in rows) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutDirection = if (isRtlMode) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR
                layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            }

            for (key in row) {
                val keyView = TextView(this).apply {
                    var displayKey = key
                    if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1 && key[0].isLetter()) {
                        displayKey = key.lowercase()
                    }
                    
                    text = getSpannedKeyText(displayKey)
                    setTextColor(keyTextColor)
                    gravity = Gravity.CENTER
                    setPadding(0, 0, 0, 0)
                    includeFontPadding = false
                    minWidth = 0
                    minHeight = 0
                    
                    val currentKeyBg = when (key) {
                        "BACKSPACE", "⌫" -> if (isNightMode) 0xFF7F1D1D.toInt() else 0xFFFEE2E2.toInt()
                        "ENTER", "⏎", "مان", "Màn" -> if (isNightMode) 0xFF064E3B.toInt() else 0xFFD1FAE5.toInt()
                        "⚙️" -> if (isNightMode) 0xFF475569.toInt() else 0xFFE2E8F0.toInt()
                        "SPACE", " " -> if (isNightMode) 0xFF334155.toInt() else 0xFFCBD5E1.toInt()
                        else -> keyBgColor
                    }
                    
                    background = GradientDrawable().apply {
                        setColor(currentKeyBg)
                        cornerRadius = 8f
                        setStroke(1, 0x1A000000) 
                    }
                    elevation = 2f 
                    if (amiriTypeface != null) typeface = amiriTypeface
                    
                    layoutParams = LinearLayout.LayoutParams(0, keyHeightPx, if (key == " " || key == "SPACE") 3.0f else 1.0f).apply {
                        setMargins((2 * density).toInt(), (3 * density).toInt(), (2 * density).toInt(), (3 * density).toInt())
                    }

                    if (key == "BACKSPACE") {
                        setOnTouchListener { _, event ->
                            when (event.action) {
                                MotionEvent.ACTION_DOWN -> {
                                    val ic = currentInputConnection
                                    val selectedText = ic?.getSelectedText(0)
                                    if (TextUtils.isEmpty(selectedText)) {
                                        ic?.deleteSurroundingText(1, 0)
                                    } else {
                                        ic?.commitText("", 1)
                                    }
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
                        setOnLongClickListener { showLongPressPopup(this, key); true }
                    }
                }
                rowLayout.addView(keyView)
            }
            keysContainer?.addView(rowLayout)
        }
    }

    private fun handleKeyPress(key: String) {
        val ic: InputConnection = currentInputConnection ?: return
        playKeyPressSound()

        when (key) {
            "SPACE", " " -> { ic.commitText(" ", 1); updateWordPredictions("") }
            "BACKSPACE", "⌫" -> { 
                val selectedText = ic.getSelectedText(0)
                if (TextUtils.isEmpty(selectedText)) {
                    ic.deleteSurroundingText(1, 0)
                } else {
                    ic.commitText("", 1)
                }
                updateWordPredictions("") 
            }
            "ENTER", "⏎", "مان", "Màn" -> { ic.commitText("\n", 1); updateWordPredictions("") }
            "GLOBE" -> { keyboardLayoutMode = if (keyboardLayoutMode == "balorabi") "balotin" else "balorabi"; setupKeyboardLayout() }
            "⚙️" -> { 
                try { 
                    val intent = packageManager.getLaunchIntentForPackage(packageName)
                    if (intent != null) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                        startActivity(intent)
                    }
                } catch (e: Exception) {} 
            }
            "؟۱۲۳", "?123" -> { keyboardLayoutMode = "symbols1"; setupKeyboardLayout() }
            "2/2 →" -> { keyboardLayoutMode = "symbols2"; setupKeyboardLayout() }
            "← 1/2" -> { keyboardLayoutMode = "symbols1"; setupKeyboardLayout() }
            "اب/ABC" -> { keyboardLayoutMode = if (keyboardLayoutMode == "balorabi" || keyboardLayoutMode == "symbols2") "balorabi" else "balotin"; setupKeyboardLayout() }
            "SHIFT", "⬆" -> { isShiftActive = !isShiftActive; setupKeyboardLayout() }
            "◀▶" -> { ic.commitText("\u200C", 1) }
            "ے/ݔ" -> { ic.commitText("ے", 1); updateWordPredictions(ic.getTextBeforeCursor(20, 0)?.split(" ")?.lastOrNull() ?: "") }
            else -> {
                var typedKey = key
                if (keyboardLayoutMode == "balotin" && !isShiftActive && key.length == 1) typedKey = key.lowercase()

                val preceding = ic.getTextBeforeCursor(1, 0)
                if (preceding == "ے" && typedKey.isNotEmpty() && !listOf(" ", "\n", "،", "؟", "?", ".", ",", ":", ";", "-", "_").contains(typedKey)) {
                    ic.deleteSurroundingText(1, 0)
                    ic.commitText("ݔ", 1)
                }
                ic.commitText(typedKey, 1)
                updateWordPredictions(ic.getTextBeforeCursor(20, 0)?.split(" ")?.lastOrNull() ?: "")
            }
        }
    }

    private fun updateWordPredictions(currentWord: String) {
        suggestionBar?.removeAllViews()
        if (currentWord.isEmpty() || currentWord.isBlank()) return

        val vocabList = if (keyboardLayoutMode == "balorabi") balorabiVocab else balotinVocab
        val normalized = currentWord.replace("ݔ", "ے")
        val predictions = vocabList.filter { it.replace("ݔ", "ے").startsWith(normalized, ignoreCase = true) }.take(5)

        for (word in predictions) {
            val suggestionView = TextView(this).apply {
                text = word
                textSize = 18f
                if (amiriTypeface != null) typeface = amiriTypeface
                setPadding(24, 8, 24, 8)
                setTextColor(keyTextColor)
                setOnClickListener { 
                    val ic = currentInputConnection
                    ic?.deleteSurroundingText(currentWord.length, 0)
                    ic?.commitText("$word ", 1)
                    playKeyPressSound()
                    updateWordPredictions("")
                }
            }
            suggestionBar?.addView(suggestionView)
        }
    }

    private fun toggleClipboardView() {
        if (clipboardFullView?.visibility == View.GONE) {
            keysContainer?.visibility = View.GONE
            clipboardFullView?.visibility = View.VISIBLE
            populateClipboardFullView()
        } else {
            closeClipboardView()
        }
    }

    private fun closeClipboardView() {
        clipboardFullView?.visibility = View.GONE
        keysContainer?.visibility = View.VISIBLE
    }

    private fun saveToClipboardHistory(newText: String) {
        try {
            val prefs = getSharedPreferences("BalochiClipboard", Context.MODE_PRIVATE)
            val historyJson = prefs.getString("history", "[]")
            val array = JSONArray(historyJson)
            val currentTime = System.currentTimeMillis()
            
            val newArray = JSONArray()
            val newItem = JSONObject().apply {
                put("text", newText)
                put("time", currentTime)
            }
            newArray.put(newItem)
            
            var count = 1
            for (i in 0 until array.length()) {
                if (count >= MAX_CLIPBOARD_ITEMS) break
                val item = array.getJSONObject(i)
                val text = item.getString("text")
                val time = item.getLong("time")
                
                if (text != newText && (currentTime - time) < CLIPBOARD_EXPIRY_MS) {
                    newArray.put(item)
                    count++
                }
            }
            prefs.edit().putString("history", newArray.toString()).apply()
        } catch (e: Exception) {}
    }

    private fun populateClipboardFullView() {
        clipboardListContainer?.removeAllViews()
        try {
            val prefs = getSharedPreferences("BalochiClipboard", Context.MODE_PRIVATE)
            val historyJson = prefs.getString("history", "[]")
            val array = JSONArray(historyJson)
            
            if (array.length() == 0) {
                clipboardListContainer?.addView(TextView(this).apply {
                    text = "No clipboard history yet."
                    setPadding(16, 32, 16, 32)
                    gravity = Gravity.CENTER
                    setTextColor(keyTextColor)
                })
                return
            }

            for (i in 0 until array.length()) {
                val item = array.getJSONObject(i)
                val clipText = item.getString("text")
                
                val clipView = TextView(this).apply {
                    text = clipText
                    textSize = 16f
                    maxLines = 2
                    ellipsize = TextUtils.TruncateAt.END
                    if (amiriTypeface != null) typeface = amiriTypeface
                    setPadding(24, 24, 24, 24)
                    setTextColor(keyTextColor)
                    
                    background = GradientDrawable().apply {
                        setColor(keyBgColor)
                        cornerRadius = 12f
                    }
                    
                    layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { setMargins(0, 0, 0, 16) }
                    
                    setOnClickListener {
                        currentInputConnection?.commitText(clipText, 1)
                        playKeyPressSound()
                        closeClipboardView()
                    }
                }
                clipboardListContainer?.addView(clipView)
            }
        } catch (e: Exception) {}
    }

    private fun getSpannedKeyText(mainKey: String): CharSequence {
        var displayLabel = mainKey
        when (mainKey) {
            "SPACE", " " -> return "␣"
            "BACKSPACE" -> return "⌫"
            "ENTER" -> return "⏎"
            "GLOBE" -> return "🌐"
            "SHIFT" -> return "⬆"
        }

        val lookupKey = mainKey.lowercase()
        val hintRaw = longPressMappings[mainKey]?.firstOrNull() ?: longPressMappings[lookupKey]?.firstOrNull() ?: return displayLabel
        
        var hint = hintRaw
        if (keyboardLayoutMode == "balotin" && isShiftActive) {
            hint = hintRaw.uppercase()
        }

        var displayHint = hint
        when (hint) {
            "َ" -> displayHint = "◌َ"
            "ِ" -> displayHint = "◌ِ"
            "ُ" -> displayHint = "◌ُ"
            "ّ" -> displayHint = "◌ّ"
            "ٚ" -> displayHint = "◌ٚ"
            "ْ" -> displayHint = "◌ْ"
            "ٝ" -> displayHint = "◌ٝ"
        }

        val spanText = SpannableString("$displayLabel $displayHint")
        spanText.setSpan(AbsoluteSizeSpan(18, true), 0, displayLabel.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(keyTextColor), 0, displayLabel.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        val hintStart = displayLabel.length + 1
        spanText.setSpan(AbsoluteSizeSpan(10, true), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(ForegroundColorSpan(0xFFDC2626.toInt()), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(RelativeSizeSpan(0.6f), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        spanText.setSpan(SuperscriptSpan(), hintStart, spanText.length, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        return spanText
    }

    private fun getRowsForMode() = when (keyboardLayoutMode) {
        "balorabi" -> listOf(listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"), listOf("ے/ݔ", "ڈ", "ٹ", "ۏ", "ء", "ھ", "ج", "چ", "ءِ"), listOf("ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"), listOf("⚙️", "ژ", "ز", "ر", "د", "و", "ک", "گ", "BACKSPACE"), listOf("؟۱۲۳", "GLOBE", "◀▶", "SPACE", "۔", "ENTER"))
        "balotin" -> listOf(listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"), listOf("À", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ť"), listOf("A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"), listOf("SHIFT", "Z", "Ž", "C", "È", "B", "N", "M", "BACKSPACE"), listOf("?123", "GLOBE", "SPACE", ".", "ENTER"))
        "symbols1" -> listOf(listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"), listOf("+", "×", "÷", "=", "٪", "^", "!", "@", "#", "$"), listOf("/", "\\", "~", "*", "(", ")", "-", "_", "|", "&"), listOf("2/2 →", "[", "]", "{", "}", "<", ">", "❂", "BACKSPACE"), listOf("اب/ABC", "SPACE", "ENTER"))
        else -> listOf(listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"), listOf("،", "؟", "?", ".", ",", ":", ";", "\"", "'", "|"), listOf("❂", "Ꝃ", "★", "☆", "✦", "❖", "◈", "✿", "✛", "✜"), listOf("← 1/2", "⚔", "🌴", "🐫", "🏔", "☪", "✵", "✹", "BACKSPACE"), listOf("اب/ABC", "SPACE", "ENTER"))
    }

    private fun showLongPressPopup(anchorView: View, originalKey: String) {
        val lookupKey = originalKey.lowercase()
        var alternatives = longPressMappings[originalKey] ?: longPressMappings[lookupKey] ?: return
        
        if (keyboardLayoutMode == "balotin" && isShiftActive) {
            alternatives = alternatives.map { it.uppercase() }
        }

        try {
            val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            val popupRoot = inflater.inflate(R.layout.popup_keyboard, null) as HorizontalScrollView
            val popupContainer = popupRoot.findViewById<LinearLayout>(R.id.popup_container)
            
            popupRoot.background = GradientDrawable().apply {
                setColor(keyBgColor)
                cornerRadius = 24f
                setStroke(2, 0xFFD97706.toInt()) 
            }
            
            val popupWindow = PopupWindow(popupRoot, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, true)
            popupWindow.elevation = 8f

            val density = resources.displayMetrics.density
            
            for (alt in alternatives) {
                popupContainer.addView(TextView(this).apply {
                    var displayAlt = alt
                    when(alt) {
                        "َ" -> displayAlt = "◌َ"
                        "ِ" -> displayAlt = "◌ِ"
                        "ُ" -> displayAlt = "◌ُ"
                        "ّ" -> displayAlt = "◌ّ"
                        "ٚ" -> displayAlt = "◌ٚ"
                        "ْ" -> displayAlt = "◌ْ"
                        "ٝ" -> displayAlt = "◌ٝ"
                    }
                    text = displayAlt
                    textSize = 24f
                    setTextColor(keyTextColor)
                    gravity = Gravity.CENTER
                    if (amiriTypeface != null) typeface = amiriTypeface
                    
                    background = GradientDrawable().apply { 
                        setColor(kbBgColor)
                        cornerRadius = 16f 
                    }
                    
                    setPadding((16 * density).toInt(), (8 * density).toInt(), (16 * density).toInt(), (8 * density).toInt())
                    
                    layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { 
                        setMargins((4 * density).toInt(), 0, (4 * density).toInt(), 0) 
                    }
                    
                    setOnClickListener { 
                        currentInputConnection?.commitText(alt, 1)
                        playKeyPressSound()
                        popupWindow.dismiss() 
                    }
                })
            }
            
            popupRoot.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED)
            val popupWidth = popupRoot.measuredWidth
            val xOffset = (anchorView.width - popupWidth) / 2
            
            popupWindow.showAsDropDown(anchorView, xOffset, -anchorView.height - (65 * density).toInt(), Gravity.NO_GRAVITY)
        } catch (e: Exception) {}
    }
}
