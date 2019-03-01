chrome.browserAction.onClicked.addListener(
  function(tab) {
    console.log("WAS here");
    chrome.windows.create( {'url': 'popup.html',
                            'type': 'popup',
                            'width': 800,
                            'height': 600});

  });
