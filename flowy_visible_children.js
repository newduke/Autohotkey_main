(function copyVisibleChildren_2_6() {
    function toastMsg(str, sec, err) {
        WF.showMessage(str, err); setTimeout(WF.hideMessage, (sec || 2) * 1e3)
    }
    function setChildOPMLAndHide() {
        var ta = document.querySelector("textarea");
        if (ta && ta.value.length > 0) {
            if (IS_SEARCH) {
                var o = ta.value.replace(/<body>\s+<outline text=".*">/, "<body>").replace(/<\/outline>\s+<\/body>/, "</body>");
                ta.value = o
            } ta.select(); setTimeout(copyExport, 500); return
        } setTimeout(setChildOPMLAndHide, 300)
    }
    function copyExport() {
        const h1 = document.querySelector("h1"); const success = document.execCommand("copy");
        if (success) { h1.innerText = `Visible children copied!`; h1.style.color = "#008000"; setTimeout(WF.hideDialog, 1500) }
        else { h1.innerText = `Copy failed. Manually copy.`; h1.style.color = "#FF0000" }
    }
    function openOPML() {
        var radios = document.querySelectorAll("input[type='radio']"); if (radios.length > 0) {
            radios[2].click();
            setTimeout(setChildOPMLAndHide, 100); return
        } setTimeout(openOPML, 200)
    } window.getSelection().removeAllRanges();
    WF.setSelection([]); const current = WF.currentItem(); const IS_SEARCH = WF.currentSearchQuery() !== null;
    if (current.isMainDocumentRoot() && !IS_SEARCH) return void toastMsg("Only works from the Home page when search is active.", 7, true);
    const children = current.getVisibleChildren(); if (children.length === 0) return void toastMsg("No visible children found.", 3, true);
    WF.showExportDialog(IS_SEARCH ? [current] : children); openOPML()
})();


