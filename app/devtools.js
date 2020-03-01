function updateContent(){
  chrome.devtools.inspectedWindow.eval("getSelected($0)", { useContentScriptContext: true });
}

chrome.devtools.panels.elements.createSidebarPane(
    "Locatine Locator Helper",
    function(sidebar) {
        sidebar.setPage("locatine.html");
    }
);
chrome.devtools.panels.elements.onSelectionChanged.addListener(updateContent);
