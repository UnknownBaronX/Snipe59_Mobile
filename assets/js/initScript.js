  let count = 0;
  async function initScript() {
    var elements = document.getElementsByClassName("ut-tab-bar");

    if (elements.length > 0) {
         var user = services.User.getUser();
         window.flutter_inappwebview.callHandler('injectScript', "true");

    } else {
        setTimeout(initScript, 1000);
    }
}

initScript();