chrome.browserAction.onClicked.addListener(
  function(tab) {
    console.log("WAS here");
    chrome.windows.create( {'url': 'popup.html',
                            'type': 'popup',
                            'width': 640,
                            'height': 480});

  });
