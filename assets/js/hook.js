(function() {
   async function initScript() {
        var elements = document.getElementsByClassName("ut-tab-bar");

        if (elements.length > 0) {
            await sleep(1000);
            getProfiles();
            initSettingsButton();
            overrideStatusCheck();
            searchMarketOverride();

            //TODO PUT YOUR MAIN FUNCTION HERE
                window.onPageNavigation = new EAObservable();
                window.currentPage = '';
                disableMonitoring();
                quickListOpenOverride();
                playerViewPanelOverride();
                paginatedResultOverride();
                binPopUpOverride();
                overrideStyle();
                createCustomlog();
                initPlayerListEdit();
                $(document).on({
                    touchstart: function () {
                        $(nameDeleteFilter).addClass("hover");
                    },
                    touchend: function () {
                        $(nameDeleteFilter).removeClass("hover");
                        deleteFilter()
                    },
                }, nameDeleteFilter);
                
                $(document).on({
                    change: function () {
                        loadFilter()
                    }
                }, nameFilterDropdown);
                
                $(document).on({
                    touchend: function () {
                        setFilters();
                    },
                }, nameSelectedFilter);
                
                
                $(document).on({
                    touchstart: function () {
                        $(namePreserveChanges).addClass("hover");
                    },
                    touchend: function () {
                        $(namePreserveChanges).removeClass("hover");
                        console.log('saveDetails')
                        saveDetails()
                    }
                }, namePreserveChanges);

                futstarzApi = await getFUTstarzApi(); 
            //main();
        } else {
            setTimeout(initScript, 1000);
        }
    }


    function initSettingsButton() {

        JSUtils.inherits(
            UTMarketSearchFiltersViewController,
            UTMarketSearchFiltersViewController
        );
        const filterViewApper =
            UTMarketSearchFiltersViewController.prototype.viewDidAppear;
        const filterDealloc = UTMarketSearchFiltersViewController.prototype.dealloc;
        UTMarketSearchFiltersViewController.prototype.viewDidAppear = function(
            ...args
        ) {
            const result = filterViewApper.call(this, ...args);
            if (getAppMain()
                .getRootViewController()
                .getPresentedViewController()
                .getCurrentViewController()
                .getCurrentController() instanceof UTMarketSearchFiltersViewController) {
                const stdButton = new UTStandardButtonControl();
                stdButton.init();
                stdButton.addTarget(stdButton, () => {
                    if(window.autoBuySettings && window.autoBuySettings.autoBuyerActive){
                        stopAutoBuyer(false)
                        console.log(window.autoBuySettings.autoBuyerActive)
                    }
                    else{
                        window.flutter_inappwebview.callHandler('displaySettings');
                    }
                }, EventType.TAP);
                stdButton.getRootElement().classList.add("call-to-action");
                stdButton.getRootElement().classList.add("switchBtn");
                $(".ut-navigation-bar-view").addClass("futstar");
                $(".ut-navigation-bar-view").append($(stdButton.__root))
            }
            return result;
        }

        UTMarketSearchFiltersViewController.prototype.dealloc = function(...args) {
            $(".ut-navigation-bar-view").removeClass("futstar");
            $(".switchBtn").remove();
            return filterDealloc.call(this, ...args);
        };
    }

    function getProfiles() {
        window.flutter_inappwebview.callHandler('getProfiles').then(function(result) {
            window.autoBuySettingsAll = result;
            for (var r of result) {
                if (r.isActive) {
                    window.autoBuySettings = r;
                    window.currentProfile = r.uuid;
                }
            }
        });
    }

    function createCustomlog(){
        var iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        document.body.appendChild(iframe);
        window.console = iframe.contentWindow.console;
    }

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    function overrideStatusCheck() {
        NetworkErrorManager.checkCriticalStatus = function (e) {
            //IF AUTOBUYER ACTIVER
            if (window.autoBuySettings.autoBuyerActive) {
                console.log(e)
                if (e === UtasErrorCode.ACCOUNT_BANNED || e === UtasErrorCode.CAPTCHA_REQUIRED || e === HttpStatusCode.UNAUTHORIZED) {
                    softbanDetected = true
                    sendUINotificationNegative('Captcha triggered.')
                    discordWebhook('Stopped', "Captcha triggered!", '')
                    stopAutoBuyer(false)
                } else if (e === 512 || e === 521 || e === 426 || e === 429) {
                    sendUINotificationNegative('Softban')
                    discordWebhook('Paused', "Softbanned", '')
                } else if (e == 401 && e == false) {
                    wentBack = true
                    searchInitiated = false
                } if ((e == 461 || e == 426 || e == 478 || 403) && wentBack == false) {
                    sendUINotificationNegative('Bid status changed, auction data will be updated.')
                    if (autoBuySettings.notifyCardVisible) {
                        discordWebhook('Seen', '', `**${attemptedPlayer._staticData.name.trim()}** (${attemptedPlayer.rating}) - **Price:** ${attemptedPlayer._auction.buyNowPrice} - **Profit:** ${autoBuySettings.sellPrice * 0.95 - attemptedPlayer._auction.buyNowPrice} `)
                    }
                    sessionState.seenCards++
                    wentBack = true
                    searchInitiated = false
                }
            }

            //DONT TOUCH THE RETURN
            return e === UtasErrorCode.LOGGED_IN_ON_CONSOLE || e === UtasErrorCode.LOGGED_IN_ON_CONSOLE_LEGACY || e === UtasErrorCode.ACCOUNT_BANNED || e === UtasErrorCode.CAPTCHA_REQUIRED || e === HttpStatusCode.UNAUTHORIZED || e === UtasErrorCode.UNRECOVERABLE || e === HttpStatusCode.SERVER_ERROR
        }
    }

    window.addEventListener("ReloadProfileEvent", (event) => {
        getProfiles();
    }, false);

    initScript();
})();