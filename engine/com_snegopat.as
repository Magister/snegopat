﻿/* com_snegopat.as
    Реализует объект snegopat из SnegAPI.
*/
// Данные строки нужны только для среды разработки и вырезаются препроцессором
#pragma once
#include "../../all.h"

class Snegopat {
    //[helpstring("Получить активное текстовое окно")]
    ITextWindow&& activeTextWindow() {
        return activeTextWnd is null ? null : activeTextWnd.getComWrapper();
    }
    //[helpstring("Обработать строку шаблонов")]
    string parseTemplateString(const string& text, const string& name = "") {
        v8string wText = text;
        v8string wName = name.isEmpty() ? "Снегопат" : name;
        uint caret;
        v8string wResult;
        ITemplateProcessor&& tp;
        getTxtEdtService().getTemplateProcessor(tp);
        tp.processTemplate(wName, wText, wResult, caret, "");
        string result = wResult;
        if (caret <= result.length)
            result.insert(caret, symbCaret);
        return result;
    }
    // [helpstring("Показать список методов модуля")]
    bool showMethodsList() {
        IntelliSite&& ist = getIntelliSite();
        if (ist.isActive())
            ist.hide();
        if (activeTextWnd !is null && oneDesigner._windows.get_modalMode() == msNone) {
            ModuleTextProcessor&& mtp = cast<ModuleTextProcessor>(activeTextWnd.textDoc.tp);
            if (mtp !is null) {
                if (methodsDialog is null)
                    &&methodsDialog = MethodsDialog();
                TextPosition curPos;
                ITextEditor&& editor = activeTextWnd.ted;
                editor.getCaretPosition(curPos);
                int line = methodsDialog.show(mtp.moduleElements, curPos.line);
                if (line > 0) {
                    int len = activeTextWnd.textDoc.tm.getLineLength(line, false);
                    // сначала надо установить каретку на следующую строку, чтобы метод развернулся, если он был свёрнут
                    curPos.line = line + 1;
                    curPos.col = 1;
                    editor.setCaretPosition(curPos);
                    curPos.line = line;
                    editor.setCaretPosition(curPos);
                    editor.scrollToCaretPos();
                    editor.setSelection(curPos, TextPosition(line, len + 1), false);
                    editor.updateView();
                }
                return true;
            }
        }
        return false;
    }
    //[helpstring("Показать выпадающий список снегопата")]
    bool showSmartBox() {
        // При принудительном вызове списка снегопата надо всё перепарсить
        for (uint i = 0, im = textDocStorage.openedDocs.length; i < im; i++) {
            ModuleTextProcessor&& tp = cast<ModuleTextProcessor>(textDocStorage.openedDocs[i].tp);
            if (tp !is null)
                tp.lastMethodBeginLine = 0;
        }
        for (auto it = allModuleElements.begin(); it++;)
            it.value.parsed = false;

        IntelliSite&& isite = getIntelliSite();
        if (isite.isActive())
            isite.hide();
        if (activeTextWnd !is null) {
            ModuleTextProcessor&& tp = cast<ModuleTextProcessor>(activeTextWnd.textDoc.tp);
            if (tp !is null)
                tp.activate(activeTextWnd);
        }
        return true;
    }
    IV8Lexer&& parseSources(const string& strSource, uint startLine = 1) {
        return IV8Lexer(strSource, startLine);
    }
    OptionsEntry&& _optionEntries = optionList;
    void updateAllEditorsSettings() {
        getEventService().notify(eTxtEdtOptionChanged);
    }
    string getStockTextIndent() {
        bool bval;
        getProfileService().getBool("ModuleTextEditor/ReplaceTabOnInput", bval);
        if (bval) {
            int i;
            getProfileService().getInt("ModuleTextEditor/TabSize", i);
            return string(" ", i);
        } else
            return "\t";
    }
    /*
        [helpstring("Показать подсказку о параметрах метода")] HRESULT
    showParams(_ret VARIANT_BOOL* result);
        [helpstring("Листать подсказку о параметрах метода вперед")] HRESULT
    nextParams(_ret VARIANT_BOOL* result);
        [helpstring("Листать подсказку о параметрах метода назад")] HRESULT
    prevParams(_ret VARIANT_BOOL* result);
        [helpstring("Варианты в параметрах")] HRESULT
    paramsTypes(_ret SAFEARRAY(VARIANT)* result);
        [helpstring("Положение подсказки о параметрах")] HRESULT
    paramsPosition(_ret ISelection** result);
        [helpstring("Установить номер подсказки о параметрах")] HRESULT
    setParamType(_in long idx, _ret VARIANT_BOOL* result);
        [helpstring("Получить список приоритетных слов")] HRESULT
    getHotWords(_ret  SAFEARRAY(VARIANT)* result);
        [helpstring("Установить список приоритетных слов")] HRESULT
    setHotWords(_in  SAFEARRAY(VARIANT) words);
    prop_r(v8types, IDescriptionArray*, "Описание типов 1С из файла v8types.txt");
    meth(readTypeFile, "Добавить к описаниям типов типы из файла")(const string&path);
*/
};
