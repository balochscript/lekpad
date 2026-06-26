package com.example.balochi_keyboard

import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.inputmethodservice.InputMethodService
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView

class BalochiInputMethod : InputMethodService() {

    private lateinit var keyboardView: View
    private lateinit var suggestionBar: LinearLayout
    private lateinit var clipboardBar: LinearLayout
    private var isNightMode: Boolean = false
    private var isBalorabi: Boolean = true

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
        "Salàm", "Vàlaik", 'Čònai', 'Man', 'Vašaon', 'Tà', 'Han', 'Ce', 'Hàl', 'Ent', 'Vaš', 'Salàmati', 'Jòďī',
        "Haur", "Jambar", "Estin", "Estun", "Grand", "Goròk", "Tramp", "Tròngal", "Guàt", "Sangol", 
        "Sohr", "Bir", "Guàrag", "Hàr", "Kaur", "Šèp", "Luď", "Lahď", "Baččag", "Baččènag", 
        "Baččènòk", "Bačchetagèn", "Baččèntag", "Baččòk", "Musàm", "Nimròc", "Waďènag", "Waďènòk", 
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
        "هـ" to listOf("ھ", "ح", "ه"),
        "ء" to listOf("ع", "ءَ", "ءِ", "ءُ"),
        "و" to listOf("ۏ", "ؤ", "وْ", "وُ"),
        "ی" to listOf("ݔ", "ے", "یْ", "یٰ", "ئ"),
        "ن" to listOf("ں", "نٚ"),
        "ر" to listOf("ڑ"),
        "ژ" to listOf("ظ"),
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

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        keyboardView = inflater.inflate(R.layout.keyboard_view, null)

        suggestionBar = keyboardView.findViewById(R.id.suggestion_bar)
        clipboardBar = keyboardView.findViewById(R.id.clipboard_bar)

        applyTheme()
        setupKeyboardLayout()
        updateClipboardSuggestions()
        updateWordPredictions("")

        return keyboardView
    }

    private fun applyTheme() {
        val backgroundColor = if (isNightMode) 0xFF0F172A.toInt() else 0xFFE0F2FE.toInt()
        keyboardView.setBackgroundColor(backgroundColor)
    }

    private fun setupKeyboardLayout() {
        val layoutContainer = keyboardView.findViewById<LinearLayout>(R.id.keys_container)
        layoutContainer.removeAllViews()

        // Precise rows matching IMG_20260626_214608.png & Custom enter "مان" / "Màn"
        val rows = if (isBalorabi) {
            listOf(
                listOf("۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹", "۰"),
                listOf("ے", "ی", "ڈ", "ٹ", "و", "ء", "هـ", "ج", "چ", "ءِ"),
                listOf("ش", "س", "ی", "ب", "ل", "ا", "ت", "ن", "م", "پ"),
                listOf("◀▶", "ژ", "ز", "ر", "د", "و", "ک", "گ", "پاکے"),
                listOf("ツ", "ABC", "SPACE", "-", "مان")
            )
        } else {
            listOf(
                listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
                listOf("À", "W", "E", "R", 'T', 'Y', 'U', 'I', 'O', 'P', 'Ť'),
                listOf("A", "Š", "S", "D", "Ď", "G", "H", "J", "K", "L", "Ò"),
                listOf("⬆", "Z", "Ž", "C", "È", "B", "N", "M", "Pàk"),
                listOf("ツ Sym", "اب ...", "SPACE", ".", "Màn")
            )
        }

        for (row in rows) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            for (key in row) {
                val keyButton = Button(this).apply {
                    text = key
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1.0f).apply {
                        setMargins(2, 2, 2, 2)
                    }
                    setOnClickListener { handleKeyPress(key) }
                    setOnLongClickListener { 
                        showLongPressPopup(this, key)
                        true 
                    }
                }
                rowLayout.addView(keyButton)
            }
            layoutContainer.addView(rowLayout)
        }
    }

    private fun handleKeyPress(key: String) {
        val ic: InputConnection = currentInputConnection ?: return
        when (key) {
            "SPACE" -> {
                ic.commitText(" ", 1)
                updateWordPredictions("")
            }
            "پاکے", "Pàk" -> {
                ic.deleteSurroundingText(1, 0)
                updateWordPredictions("")
            }
            "مان", "Màn" -> {
                ic.commitText("\n", 1)
                updateWordPredictions("")
            }
            "ABC" -> {
                isBalorabi = false
                setupKeyboardLayout()
            }
            "اب ..." -> {
                isBalorabi = true
                setupKeyboardLayout()
            }
            else -> {
                ic.commitText(key, 1)
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

        val vocabList = if (isBalorabi) balorabiVocab else balotinVocab
        val predictions = vocabList.filter { it.startsWith(currentWord, ignoreCase = true) }.take(4)

        for (word in predictions) {
            val suggestionView = TextView(this).apply {
                text = word
                textSize = 16f
                setPadding(20, 10, 20, 10)
                setTextColor(if (isNightMode) 0xFFFFFFFF.toInt() else 0xFF000000.toInt())
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
                    setPadding(15, 10, 15, 10)
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
