//TODO COPY YOUR SCRIPT HERE
var autoBuySettings;
var autoBuySettingsAll
var wentBack = false
var currentProfile;
var sessionState = {
    'botStartTime': '',
    'purchasedCardCount': 0,
    'seenCards': 0,
    'currentPage': '',
    'searchInterval': '',
    'searchCount': 0,
    'previousPause': 0,
    'soldItems': "-",
    'unsoldItems': "-",
    'activeTransfers': "-",
    'availableItems': "-",
    'coins': "-",
    'fullList': false,
    'coinsNumber': 0,
    'profit': 0,
    'transactions': [],
    'purchases': 0
}






var filterSearchAmount = 0;
var currentProfileIndex = 0;

var timerPause = false;
var pauseIntervalId = false;
var requestIntervalId = false;

var filter = {
    'player': '',
    'profit': '',
    'quality': '',
    'rarity': '',
    'position': '',
    'chemistry_style': '',
    'nationality': '',
    'league': '',
    'club': '',
    'licensekey': '',
    'min_bid': '',
    'max_bid': '',
    'min_buy_now': '',
    'max_buy_now': '',
    'searchCount': '',
    'seenCards': '',
    'purchasedCards': ''


}
function createButton(text, callBack, customClass) {
    const stdButton = new UTStandardButtonControl();
    stdButton.init();
    stdButton.addTarget(stdButton, callBack, EventType.TAP);
    stdButton.setText(text);

    if (customClass) {
        const classes = customClass.split(" ");
        for (let cl of classes) stdButton.getRootElement().classList.add(cl);
    }

    return stdButton;
};

async function switchFilterIfRequired(botStarted) {
    const autoBuySettingsFiltered = await autoBuySettingsAll.filter(x => x.filterSwitch === true)

    if (autoBuySettingsFiltered.length <= 1 || (autoBuySettings.filterSearchAmount >= filterSearchAmount && botStarted == false)) {
        filterSearchAmount++;
        return false;
    }


    if (currentProfileIndex == (autoBuySettingsFiltered.length - 1)) {


        autoBuySettings = autoBuySettingsFiltered[0]
        //autoBuySettings.autoBuyerActive = true
        currentProfileIndex = 0
        filterSearchAmount = 0
        await switchFilter()


    } else if (currentProfileIndex < (autoBuySettingsFiltered.length - 1)) {


        autoBuySettings = autoBuySettingsFiltered[currentProfileIndex + 1]
        currentProfileIndex = currentProfileIndex + 1
        //autoBuySettings.autoBuyerActive = true
        filterSearchAmount = 0
        await switchFilter()


    }
}


async function switchFilter() {
    let currentFilter = {};

    currentFilter.searchCriteria = {criteria: getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria};
    currentFilter = JSON.stringify(currentFilter)
    searchArray = filters;
    let settingsJson = searchArray[autoBuySettings.filter]

    if (!settingsJson) {
        return;
    }

    if (currentFilter == settingsJson) {
        return;
    }
    settingsJson = JSON.parse(settingsJson);

    let savedCriteria = settingsJson.searchCriteria || {};
    if (autoBuySettings.notifyFilterSwitch) {
        discordWebhook('Info', '', autoBuySettings.filter)

    }

    await Object.assign(getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria, savedCriteria.criteria);
    getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().viewDidAppear()
    await $(`select[name=filters] option[value="${autoBuySettings.filter}"]`).attr("selected", true);
    return

}


// document.addEventListener('snipe', async function (e) {
//     if(window.currentPage !== 'UTMarketSearchFiltersViewController'){
//     let market = document.querySelector('.icon-transfer')
//     tapElement(market)
//     await timeout(1000)
//     let transferHub = document.querySelector('.ut-tile-transfer-market')
//     tapElement(transferHub)
// }

// await timeout(1000)
//     if (document.querySelectorAll('.ea-filter-bar-item-view.selected')[0].innerHTML !== 'Players'){
//         tapElement(document.querySelectorAll('.ea-filter-bar-item-view')[0])
//     }
//     getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.maxBuy = autoBuySettings.buyPrice
//     getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.maskedDefId = parseInt(e.detail[0])
//     getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.rarities  = [parseInt(e.detail[1])]
//     getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().viewDidAppear()


// })




var attemptedPlayer;


document.addEventListener('initialAutoBuySettings', function (e) {
    autoBuySettingsAll = e.detail;
    autoBuySettings = autoBuySettingsAll.find(x => x.uuid === currentProfile)
    setMaxUnassignedCount();
    quickListOpenOverride();
})

var filters;
document.addEventListener('currentFilters', function (e) {
    filters = e.detail;
})


document.addEventListener('statusUpdate', async function (e) {

    if (autoBuySettings.autoBuyerActive == false) {
        return
    }

    const statusCode = e.detail;
    if ((statusCode == "461" || statusCode == "426" || statusCode == "478") && wentBack == false) {

        sendUINotificationNegative('Bid status changed, auction data will be updated.')
        if (autoBuySettings.notifyCardVisible) {
            discordWebhook('Seen', '', `**${attemptedPlayer._staticData.name.trim()}** (${attemptedPlayer.rating}) - **Price:** ${attemptedPlayer._auction.buyNowPrice} - **Profit:** ${autoBuySettings.sellPrice * 0.95 - attemptedPlayer._auction.buyNowPrice} `)
        }
        sessionState.seenCards++
        wentBack = true
        searchInitiated = false
    } else if (statusCode == "401" && wentBack == false) {
        wentBack = true
        searchInitiated = false

    } else if (statusCode == "458" || statusCode == "459") {
        softbanDetected = true
        sendUINotificationNegative('Captcha triggered.')
        discordWebhook('Stopped', "Captcha triggered!", '')
        stopAutoBuyer(false)
        alert('Captcha triggered, please solve it and restart the bot.')
    } else if (statusCode == "521" || statusCode == "512" || statusCode == "429") {
        sendUINotificationNegative('Purschase softban')
        let waitTime = convertRangeToSeconds(autoBuySettings.pauseFor) * 1000
        discordWebhook('Paused', "Purchase Softban! Waiting for " + (waitTime / 1000) + ' Seconds', '')
        await timeout(convertRangeToSeconds(autoBuySettings.waitTime) * 1000)
    }
})





let stopAfter, pauseCycle;
let interval = null;
let passInterval = null;
var triggerGoBack = 0;
var softbanDetected = false;


function appendTransactions(val) {
    const currentStats = sessionState;
    currentStats["transactions"] = currentStats["transactions"] || [];
    currentStats["transactions"].push(val);
    sessionState = currentStats
};

function numberWithCommas(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

async function saveFilterCriteria() {
    let shortController = await getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel
    if (shortController.playerData !== null) {
        filter.player = await shortController.playerData.lastName + ', ' + await shortController.playerData.firstName + ' (' + shortController.playerData.rating + ')'
    }
    if (document.querySelectorAll('.ea-filter-bar-item-view.selected')[0].innerHTML == 'Players') {
        filter.position = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[2].innerText
        filter.chemistry_style = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[3].innerText
        filter.nationality = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[4].innerText
        filter.league = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[5].innerText
        filter.club = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[6].innerText
    }
    filter.quality = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[0].innerText
    filter.rarity = await document.querySelectorAll('.inline-list-select.ut-search-filter-control .label')[1].innerText


    filter.profit = sessionState.profit
    filter.seenCards = sessionState.seenCards
    filter.purchasedCards = sessionState.purchasedCardCount
    filter.searchCount = sessionState.searchCount



    filter.min_bid = await getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.minBid
    filter.max_bid = await getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.maxBid
    filter.min_buy_now = await getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.minBuy
    filter.max_buy_now = await getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria.maxBuy
}




function disableMonitoring() {
    window.EASFCApp.prototype.onPause = () => {
    };
    window.EASFCApp.prototype.onResume = () => {
    };
    window.services.PIN.isEnabled = () => false;
    window.services.PIN.isEnabledByUser = () => false;
    window.services.PIN.isEnabledByConfig = () => false;
    window.services.PIN.enabled = false;
    window.TelemetryManager.trackEvent = () => {
    };
    window.TelemetryManager.trackPage = () => {
    };
}

var futstarzApi;


function sendPinEvents(pageId) {
    services.PIN.sendData(PINEventType.PAGE_VIEW, {
        type: PIN_PAGEVIEW_EVT_TYPE,
        pgid: pageId,
    });
};

var isPageTitle = (title) => {
    var currentPageTitle = document.querySelector('h1.title').innerText;

    return currentPageTitle === title;
}

function setMaxUnassignedCount() {
    if (autoBuySettings == undefined || autoBuySettings == '' || autoBuySettings == null) {
        MAX_NEW_ITEMS = 5;
        return
    } else if (autoBuySettings.unassignedValue) {
        MAX_NEW_ITEMS = autoBuySettings.unassignedValue;
    }
};


var searchInitiated = false
//MAIN FUNCTION START | STOP | PAUSE
async function startAutoBuyer(isResume) {
    const isActive = autoBuySettings.autoBuyerActive;
    if (isActive) {
        discordWebhook('Info', 'active', 'active')
        return;
    }
    sendUINotification(isResume ? "Autobuyer Resumed" : "Autobuyer Started");
    if (isResume) {
        if ((window.currentPage === 'UTMarketSearchResultsViewController' || window.currentPage == 'ItemDetailsViewController')
            && !isPageTitle('TRANSFER LIST') && !isPageTitle("UNASSIGNED") && !isPageTitle("MY CLUB PLAYERS")) goBack()
    }
    autoBuySettings.autoBuyerActive = true;
    autoBuySettingsAll.map(a => a.autoBuyerActive = true);

    autoBuySettings.autoBuyerState = "STATE_ACTIVE";
    autoBuySettingsAll.map(a => a.autoBuyerState = "STATE_ACTIVE");


    if (!isResume) {
        sessionState.botStartTime = new Date();
        sessionState.purchasedCardCount = 0;
        sessionState.currentPage = 1;
        filterSearchAmount = 0;
        await switchFilterIfRequired(true)


    }
    //let srchTmWithContext = searchTransferMarket.bind(this);
    stopBotIfRequired();
    wentBack = false

    if (window.currentPage === "UTMarketSearchFiltersViewController") await searchMarket();
    searchInitiated = true


    let operationInProgress = false;
    const isBuyerActive = autoBuySettings.autoBuyerActive;

    if (isBuyerActive && !operationInProgress) {
        if (autoBuySettings.autoBuyerActive) {
            interval = setRandomInterval(async function () {
                if (searchInitiated == true) {
                    return;
                }

                passInterval = await pauseBotIfRequired();
                stopBotIfRequired();

                if ((window.currentPage === 'UTMarketSearchResultsViewController' || window.currentPage == 'ItemDetailsViewController')
                    && !isPageTitle('TRANSFER LIST') && !isPageTitle("UNASSIGNED") && !isPageTitle("MY CLUB PLAYERS")) {
                    goBack()
                }
                waitForElement('.ut-number-input-control').then(async function () {
                    await timeout(1)

                    operationInProgress = true;

                    if (autoBuySettings.incrementMinBin) {
                        if (parseInt(document.querySelectorAll('.ut-number-input-control')[2].value.replace(/,/g, "")) >= parseInt(autoBuySettings.resetPrice)
                            && window.currentPage == "UTMarketSearchFiltersViewController") {
                            let resetMinBuy = getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria
                            resetMinBuy.minBuy = 0
                            Object.assign(getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria, resetMinBuy);
                            getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().viewDidAppear()

                        } else {
                            await incrementBinMin();
                        }
                    }
                    if (!autoBuySettings.incrementMinBin) {
                        if (parseInt(document.querySelector('.ut-number-input-control').value.replace(/,/g, "")) >= parseInt(autoBuySettings.resetPrice)
                            && window.currentPage == "UTMarketSearchFiltersViewController") {
                            let clearField = document.querySelector('.flat.camel-case')

                            tapElement(clearField)
                        } else {
                            await incrementBidMin();
                        }
                    }

                    //await switchFilterIfRequired(false)

                    searchInitiated = true
                    wentBack = false
                    sendPinEvents("Hub - Transfers");
                    await transferListUtil(
                        autoBuySettings.unsoldItems,
                        autoBuySettings.minDeleteCount
                    );

                    if (window.currentPage === "UTMarketSearchFiltersViewController") await searchMarket();
                    operationInProgress = false;
                }
                )

            }, ...getRangeValue(autoBuySettings.waitTime));
        }

    }
}

async function stopBotIfRequired() {
    const purchasedCardCount = sessionState.purchasedCardCount;
    const cardsToBuy = autoBuySettings.cardCount;

    let test2 = 1
    if (purchasedCardCount >= 1 &&  test2 > 2) {
        sendUINotification(`Autobuyer stopped | Testversion purchase count reached`);
        if (autoBuySettings.notifyBotStopped) {
            displayStopAlert();
            discordWebhook('Stopped', 'Testversion purchase count reached', '')
        }
        stopAfter = null;
        stopAutoBuyer(false);
        resetSessionStats()
        return
    }

    const botStartTime = sessionState.botStartTime.getTime();
    let time = stopAfter || convertRangeToSeconds(autoBuySettings.stopAfter);
    if (!stopAfter) {
        stopAfter = time;
    }
    //let sendDetailedNotification = buyerSetting["idDetailedNotification"];
    let currentTime = new Date().getTime();
    let timeElapsed = (currentTime - botStartTime) / 1000 >= time;
    const isSelling = false;
    const isTransferListFull =
        isSelling &&
        window.repositories.Item &&
        window.repositories.Item.transfer.length >=
        repositories.Item.pileSizes._collection[5];
    if (
        isTransferListFull ||
        timeElapsed ||
        (cardsToBuy && purchasedCardCount >= cardsToBuy)
    ) {

        const message = timeElapsed
            ? "Time elapsed"
            : isTransferListFull
                ? "Transfer list is full"
                : "Max purchases count reached";

        sendUINotification(`Autobuyer stopped | ${message}`);
        if (autoBuySettings.notifyBotStopped) {
            displayStopAlert();
            discordWebhook('Stopped', message, '')
        }
        stopAfter = null;
        stopAutoBuyer(false);
        resetSessionStats()

    }
};


async function pauseBotIfRequired() {
    const isBuyerActive = autoBuySettings.autoBuyerActive;
    if (!isBuyerActive) return;
    const pauseFor = convertRangeToSeconds(autoBuySettings.pauseFor) * 1000;
    const cycleAmount =
        pauseCycle || getRandNumberInRange(autoBuySettings.cycleAmount);
    if (!pauseCycle) {
        pauseCycle = cycleAmount;
    }
    console.log("Pause : " + pauseCycle);
    const {searchCount, previousPause} = sessionState;
    if (searchCount && !((searchCount - previousPause) % cycleAmount)) {
        sessionState.previousPause = searchCount;
        stopAutoBuyer(true);


        if (autoBuySettings.notifyBotPaused) {
            discordWebhook('Paused', `Pause Cyle. Pausing for ${pauseFor / 1000} Seconds.`, '')
        }

        sendUINotification(`Pausing Autobuyer for ${pauseFor / 1000} Seconds.`)
        resetRequestTimer();
        timerPause = createTimeout(new Date().getTime(), pauseFor, true);
        pauseProcessor();
        return setTimeout(function () {
            pauseCycle = getRandNumberInRange(autoBuySettings.cycleAmount);
            resetTimer();
            startAutoBuyer(true)
        }, pauseFor);
    }
};


async function postFilter() {
    document.dispatchEvent(new CustomEvent('postFilter', {detail: JSON.stringify(filter)}));
}


//HELPER FUNCTIONS
function getRandNumberInRange(range) {
    const rangeVal = getRangeValue(range);
    if (rangeVal.length >= 2) {
        return getRandNum(rangeVal[0], rangeVal[1]);
    }
    return rangeVal[0] || 0;
};


function getRandNum(min, max) {
    return Math.round(Math.random() * (max - min) + min);
}

async function stopAutoBuyer(isPaused) {
    console.trace();
    interval && interval.clear();
    if (!isPaused && passInterval) {
        clearTimeout(passInterval);
    }

    const state = autoBuySettings.autoBuyerState;
    if (
        (isPaused && state === "STATE_PAUSED") || (!isPaused && state === "STATE_STOPPED")) {
        return;
    }

    autoBuySettingsAll.map(a => a.autoBuyerActive = false)
    autoBuySettings.autoBuyerActive = false
    sessionState.searchInterval.end = Date.now()
    isPaused ? autoBuySettings.autoBuyerState = 'STATE_PAUSED' : autoBuySettings.autoBuyerState = 'STATE_STOPPED'
    isPaused ? autoBuySettingsAll.map(a => a.autoBuyerState = 'STATE_PAUSED') : autoBuySettingsAll.map(a => a.autoBuyerState = 'STATE_STOPPED');
    sendUINotification(isPaused ? "Autobuyer Paused" : "Autobuyer Stopped");
    if (!isPaused) {
        resetTimer();
        resetRequestTimer();
    }
};

function convertRangeToSeconds(val) {
    if (val) {
        val = val + "";
        let valInterval = val[val.length - 1].toUpperCase();
        let valInTime = getRandWaitTime(val.substring(0, val.length - 1)) / 1000;
        let multipler = valInterval === "M" ? 60 : valInterval === "H" ? 3600 : 1;
        if (valInTime) {
            valInTime = valInTime * multipler;
        }
        return valInTime;
    }
    return 0;
};

function setRandomInterval(intervalFunction, start, end) {
    let timeout;
    let isCleared = false;

    function runInterval() {
        if (isCleared) return;
        const searchInterval = {
            start: Date.now(),
        };
        function timeoutFunction() {
            intervalFunction();
            runInterval();
        };

        const delay =
            parseFloat((Math.random() * (end - start) + start).toFixed(1));
        searchInterval.end = searchInterval.start + delay;
        sessionState.searchInterval = searchInterval
        //requestProcessor();
        timeout = setTimeout(timeoutFunction, delay);
    };

    runInterval();

    return {
        clear() {
            isCleared = true;
            clearTimeout(timeout);
        },
    };
};


function getRangeValue(range) {
    if (range) {
        return (range + "").split("-").map((a) => parseInt(a));
    }
    return [];
};

const sendUINotification = function (message, notificationType) {
    notificationType = notificationType || UINotificationType.POSITIVE;
    services.Notification.queue([message, notificationType]);
};

const sendUINotificationNegative = function (message, notificationType) {
    notificationType = notificationType || UINotificationType.NEGATIVE;
    services.Notification.queue([message, notificationType]);
};

function getRandWaitTime(range) {
    if (range) {
        const [start, end] = range.split("-").map((a) => parseInt(a));
        return Math.round(Math.random() * (end - start) + start) * 1000;
    }
    return 0;
};
function promisifyTimeOut(cb, wait) {
    return new Promise((resolve) => {
        setTimeout(function () {
            cb();
            resolve();
        }, 1000);
    });
};

async function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function wait(seconds = 1) {
    const rndFactor = Math.floor(Math.random());
    await new Promise((resolve) =>
        setTimeout(resolve, (rndFactor + seconds) * 1000)
    );
};
var observer;

function waitForElement(selector) {
    return new Promise(function (resolve, reject) {
        var element = document.querySelector(selector);
        if (element) {
            resolve(element);
            return;
        }
        observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                var nodes = Array.from(mutation.addedNodes);
                for (var node of nodes) {
                    if (node.matches && node.matches(selector)) {
                        observer.disconnect();
                        resolve(node);
                    }
                }
                ;
            });
        });
        observer.observe(document.documentElement, {
            childList: true,
            subtree: true
        });
    });
}


function waitForElementClass(selector, player) {
    return new Promise(function (resolve, reject) {
        var element = document.getElementsByClassName(selector)[0];
        if (element) {
            resolve(element);
            return;
        }
        observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                var nodes = Array.from(mutation.addedNodes);
                for (var node of nodes) {
                    if (node.matches && node.matches(selector)) {
                        observer.disconnect();
                        resolve(node);
                        return player;
                    }
                }
                ;
            });
        });
        observer.observe(document.documentElement, {
            childList: true,
            subtree: true
        });
    });
}


function waitForElementClassNameChange(selector) {
    return new Promise(function (resolve, reject) {
        var elemToObserve = document.querySelector(selector);
        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.attributeName == "class") {
                    observer.disconnect();
                    return;
                }
            });
        })
        observer.observe(elemToObserve, {
            attributes: true
        });
    });
}

function getSellBidPrice(bin) {
    if (bin <= 1000) {
        return bin - 50;
    }

    if (bin > 1000 && bin <= 10000) {
        return bin - 100;
    }

    if (bin > 10000 && bin <= 50000) {
        return bin - 250;
    }

    if (bin > 50000 && bin <= 100000) {
        return bin - 500;
    }

    return bin - 1000;
};



function checkRating(cardRating, permittedRatingMin, permittedRatingMax) {
    return cardRating >= permittedRatingMin && cardRating <= permittedRatingMax;
}


function formatString(str, len) {
    if (str.length <= len) {
        str += " ".repeat(len - str.length);
    }
    return str;
}

var editedPlayerCollection;
async function isEligableToBuy(playerCollection) {
    editedPlayerCollection = playerCollection;

    for (let i = 0; i < editedPlayerCollection.length && autoBuySettings.autoBuyerActive; i++) {
        editedPlayerCollection[i].index = i;
    }
    editedPlayerCollection = await sortPlayers(editedPlayerCollection, "expires", true)

    if (autoBuySettings.lastCard) {
        editedPlayerCollection = await sortPlayers(editedPlayerCollection, "expires", false)

    }
    if (autoBuySettings.cheapCard) {
        editedPlayerCollection = await sortPlayers(editedPlayerCollection, "", true)
    }

    for (let i = 0; i < editedPlayerCollection.length && autoBuySettings.autoBuyerActive; i++) {
        let player = editedPlayerCollection[i]
        let auction = player._auction
        let playerRating = parseInt(player.rating)
        let buyNowPrice = auction.buyNowPrice;
        let minRating = autoBuySettings.minRating
        let maxRating = autoBuySettings.maxRating
        let maxPurchases = autoBuySettings.cardCount;
        let playerName = formatString(player._staticData.name, 15);
        const shouldCheckRating = minRating || maxRating
        const isValidRating = !shouldCheckRating || checkRating(playerRating, minRating, maxRating)

        const userCoins = services.User.getUser().coins.amount;
        if (userCoins < buyNowPrice) {
            continue;
        }

        if (!isValidRating) {
            continue;
        }

        if (sessionState.purchases >= maxPurchases) {
            sendUINotification("Number of purchases reached")
            stopAutoBuyer(false)
            resetSessionStats()

        }


        if (buyNowPrice <= autoBuySettings.buyPrice || autoBuySettings.buyPrice == '1') {
            buyPlayer(player, buyNowPrice)
            attemptedPlayer = player
            return player;
        }
    }
    searchInitiated = false
    return 2

}

//WEBAPP FUNCTIONS
async function buyPlayer(player, price) {
    services.Item.bid(player, price).observe(
        this,
        async function (sender, data) {
            if (data.success) {
                if (triggerGoBack == 0) {
                    triggerGoBack++;
                    let sellPrice = autoBuySettings.sellPrice
                    if (autoBuySettings.notifyCardBought) {
                        discordWebhook('Bought', '', `**${player._staticData.name.trim()}** (${player.rating}) - **Price:** ${player._auction.buyNowPrice} - **Profit:** ${sellPrice * 0.95 - player._auction.buyNowPrice}`)
                    }


                    appendTransactions(`[${new Date().toLocaleTimeString()}] **${player._staticData.name.trim()}** (${player.rating}) - **Price:** ${player._auction.buyNowPrice} - **Profit:** ${sellPrice * 0.95 - player._auction.buyNowPrice}\n`)

                    const shouldList = sellPrice && !isNaN(sellPrice)
                    if (shouldList) {
                        sessionState.profit = sessionState.profit + (sellPrice * 0.95 - player._auction.buyNowPrice)
                        updateProfits();
                    }

                    if (autoBuySettings.delayBuyNow) {
                        await timeout(convertRangeToSeconds(autoBuySettings.pauseFor) * 1000)
                    }


                    if (sellPrice < 0 || autoBuySettings.followUpAction == 'sendToTransferlist') {
                        await services.Item.move(player, ItemPile.TRANSFER);
                        sendUINotification("Card Won - Sent to Transferlist")
                    } else if (autoBuySettings.followUpAction == 'sendToTransfermarket' && shouldList) {
                        await sellWonItem(player, getSellBidPrice(sellPrice), parseInt(sellPrice), autoBuySettings.waitTime)
                    } else if (autoBuySettings.followUpAction == 'sendToClub') {
                        await services.Item.move(player, ItemPile.CLUB);
                        sendUINotification("Card Won - Sent to Club")
                    } else {
                        sendUINotification("Card Won - Keeping Unassigned")
                    }


                    sessionState.purchasedCardCount += 1
                    searchInitiated = false

                }

            }else{
                NetworkErrorManager.checkCriticalStatus(data.status)
            }

        }
    )


}

function roundUpToNearest100(num) {
    return Math.ceil(num / 100) * 100;
}

async function sortPlayers(playerList, sortBy, sortOrder) {
    let sortFunc = (a) => a._auction.buyNowPrice;
    if (sortBy === "bid") {
        sortFunc = (a) => a._auction.currentBid || a._auction.startingBid;
    } else if (sortBy === "rating") {
        sortFunc = (a) => parseInt(a.rating);
    } else if (sortBy === "expires") {
        sortFunc = (a) => parseInt(a._auction.expires);
    }
    playerList.sort((a, b) => {
        const sortAValue = sortFunc(a);
        const sortBValue = sortFunc(b);
        return !sortOrder ? sortBValue - sortAValue : sortAValue - sortBValue;
    });
    return playerList;
};

async function sellWonItem(player, bidPrice, sellPrice, waitRange) {
    player.clearAuction();
    await promisifyTimeOut(function () {
        services.Item.list(player, bidPrice, sellPrice, convertToSeconds(autoBuySettings.listDuration || "1H") || 3600);
        sendUINotification("Card Won - Listed on Transfermarket")
    }, getRandWaitTime(waitRange));
}

function binPopUpOverride(){
    const popupConfirm = utils.PopupManager.showConfirmation;
    const popupAlert = utils.PopupManager.showAlert;

    utils.PopupManager.showConfirmation = function (e, t, i, o) {
        if (
            e.title === utils.PopupManager.Confirmations.CONFIRM_BUY_NOW.title
        ) {
            i();
            return;
        }

        popupConfirm.call(this, e, t, i, o);
    };
};


function convertToSeconds(val) {
    if (val) {
        let valInterval = val[val.length - 1].toUpperCase();
        let valInTime = parseInt(val.substring(0, val.length - 1));
        let multipler = valInterval === "M" ? 60 : valInterval === "H" ? 3600 : 1;
        if (valInTime) {
            valInTime = valInTime * multipler;
        }
        return valInTime;
    }
    return 0;
};

async function waitUntilElementExits(domquery, maxtime) {
    const delay = (ms) => new Promise(res => setTimeout(res, ms));
    for (let i = 0; i < maxtime; i = i + 50) {
        await delay(50);
        let elm = document.getElementsByName(domquery);
        if (elm && document.readyState == 'complete') {
            return true;
        } else {
            return false
        }
    }
}

async function checkForDom() {
    if (document.body && document.head && document.querySelector('.no-results-icon')) {
        if (triggerGoBack == 0) {
            triggerGoBack++;
            searchInitiated = false
            return;
        }
    } else {
        requestIdleCallback(checkForDom);
    }
}


var triggerGoBack;

//GENERAL
async function initPlayerListEdit() {
    UTNavigationController.prototype.willPush = async function(t) {
        if (t) {
            let player = false;
            window.onPageNavigation.notify(t.className);
            window.currentPage = t.className;
            if (window.currentPage === 'UTMarketSearchResultsViewController' && autoBuySettings.autoBuyerActive && searchInitiated == true) {
                sessionState.searchCount++;
                triggerGoBack = 0
                var onDataChange = window.getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().onDataChange
                
                onDataChange.observe(this, async function () {
                    const playerCollection = window.getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._paginationViewModel.paginationList._collection

                    if (playerCollection.length == 20 && !sessionState.fullList && sessionState.searchCount < 2) {
                        if (autoBuySettings.notifyMorePages) {
                            discordWebhook('Warn', '', '')
                        }
                        let confirmAction = confirm("Filter has a full player page. Are you sure you want to proceed?")
                        if (confirmAction) {
                            sessionState.fullList = true
                        } else {
                            stopAutoBuyer()
                        }
                    }
                    await timeout(1)

                    checkForDom()


                    player = await isEligableToBuy(playerCollection)
                    if (player != 2) {


                    } else if (player == 2) {
                        searchInitiated = false
                    }

                })
            } else if (window.currentPage === "UTMarketSearchFiltersViewController") {
                window.services.Item.marketRepository.isCacheExpired = () => true;
                if ($('.search-prices').first().length) {
                    if (!$(namePreserveChanges).length) {
                        appendDiv()
                    }

                } else {
                    setTimeout(function () {
                        if (!$(namePreserveChanges).length) {
                            appendDiv()
                        }
                    }, 1)
                }

            } else if (window.currentPage === "UTUnassignedItemsSplitViewController") {
                document.dispatchEvent(new CustomEvent('GetPlayerList', {
                    detail: ""
                }));
                playerViewPanelOverride();
            } else if (window.currentPage === "ItemDetailsViewController" && !isPageTitle("UNASSIGNED") && !isPageTitle("MY CLUB PLAYERS")) {
                playerViewPanelOverride();
            }
            //Stop if captcha site loads up
            else if (window.currentPage !== undefined && window.currentPage !== "UTFunCaptchaViewController") {
                document.dispatchEvent(new CustomEvent('EmptyPlayerList', {
                    detail: "getCurrentControllerSBP()"
                }));
            }
        }
    }
}

function transferListUtil(relistUnsold, minSoldCount) {
    sendPinEvents("Transfer List - List View");
    return new Promise((resolve) => {
        services.Item.requestTransferItems().observe(
            this,
            async function (t, response) {
                let soldItems = response.response.items.filter(function (item) {
                    return item.getAuctionData().isSold();
                }).length;


                const unsoldItems = response.response.items.filter(function (item) {
                    return (
                        !item.getAuctionData().isSold() && item.getAuctionData().isExpired()
                    );
                }).length;

                const shouldClearSold = soldItems >= minSoldCount;

                if (unsoldItems && relistUnsold) {
                    services.Item.relistExpiredAuctions().observe(
                        this,
                        function (t, listResponse) {
                            !shouldClearSold &&
                            UTTransferListViewController.prototype.refreshList();
                        }
                    );
                }
                if (shouldClearSold) {
                    UTTransferListViewController.prototype._clearSold();
                }
                resolve();
            }
        );
    });
};

function updateUserCredits() {
    return new Promise((resolve) => {
        services.User.requestCurrencies().observe(this, function (sender, data) {
            resolve();
        });
    });
};


function getCurrentControllerSBP() {
    return getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().className;
}

function getCurrentNameSBP() {
    return getCurrentUserSBP().getSelectedPersona().name
}

function getCurrentCoinsSBP() {
    return getCurrentUserSBP().coins.amount
}

function getCurrentUserSBP() {
    return services.User.getUser();
}


/**
 * //##################################################################################################################################
 * //#                                           Adds keyboard shortcuts to FUT Web App                                               #
 * //##################################################################################################################################
 */
async function searchMarket() {
    await saveFilterCriteria()
    var searchButton = document.querySelectorAll('button.btn-standard.call-to-action')
    //find element where innerText is "Search"
    searchButton = Array.from(searchButton).find(element => element.innerText === "Search");

    let curentController = window.currentPage;
    if (curentController == 'UTMarketSearchFiltersViewController') {
        await tapElement(searchButton);
        return
    }
    return
}

async function buyNow(){
    await timeout(1)
    var buyNowButton = document.querySelector('.btn-standard.buyButton.currency-coins');
    if (!buyNowButton) {
        return;
    }
    await tapElement(buyNowButton);
    await timeout(1)
    var buyNowok = document.querySelector("body > div.view-modal-container.form-modal > section > div > div > button:nth-child(1)")
    await tapElement(buyNowok)
    return
}
function quickSell() {
    try {
        const quickSellButton = document.querySelectorAll('.ut-navigation-container-view .ui-layout-right')[0].getElementsByClassName('ut-button-group')[1].lastElementChild
        tapElement(quickSellButton);
    } catch (error) {
        return;
    }
}
function listontransfermarket() {
    try {
        const rightSection = document.querySelectorAll('.ut-navigation-container-view .ui-layout-right')[0]
        const listontransfermarket = rightSection.getElementsByClassName('btn-standard call-to-action')[0]
        tapElement(listontransfermarket);
    } catch (error) {
        return;
    }
}

async function goBack() {
    const backButton = document.getElementsByClassName('ut-navigation-button-control')[0];
    await tapElement(backButton);
    return
}
async function inputMinBinDecrease() {
    try {
        const inputMinBinDecrease = document.getElementsByClassName('btn-standard decrement-value')[2];
        tapElement(inputMinBinDecrease);
    } catch (error) {
        return;
    }
}
async function clearBIN() {
    try {
        const clearBIN = document.getElementsByClassName('flat camel-case')[1];
        tapElement(clearBIN);
    } catch (error) {
        return;
    }
}
async function inputMaxBinDecrease() {
    try {
        const inputMaxBinDecrease = document.getElementsByClassName('btn-standard decrement-value')[3];
        tapElement(inputMaxBinDecrease);
    } catch (error) {
        return;
    }
}
/**
 * Change selected item on search results
 */
async function move(event) {
    try {
        const isDown = event.keyCode === 40;
        var itemList;
        if (document.querySelector('.ut-pinned-list > ul')) {
            itemList = document.querySelector('.ut-pinned-list > ul')
        } else if (document.querySelector('.sectioned-item-list > ul')) {
            itemList = document
        }
        const items = Array.from(itemList.getElementsByClassName('listFUTItem'));
        let currentIndex = items.findIndex((item) => {
            return item.className.indexOf('selected') > -1;
        });
        if (isDown && currentIndex + 1 <= items.length) {
            const div = items[++currentIndex].getElementsByClassName('has-tap-callback')[0];
            tapElement(div);
        } else if (!isDown && currentIndex - 1 >= 0) {
            const div = items[--currentIndex].getElementsByClassName('has-tap-callback')[0];
            tapElement(div);
        }
    } catch (error) {
        return;
    }
}
/**
 * Increment  minimum bid price
 */
async function incrementBidMin() {
    try {
        var incrementBidMin = document.getElementsByClassName('btn-standard increment-value')[0];
        await tapElement(incrementBidMin);
        return
    } catch (error) {
        return;
    }
}
/**
 * Increment  maximum bid price
 */
async function incrementBidMax() {
    try {
        var incrementBidMax = document.getElementsByClassName('btn-standard increment-value')[1];
        tapElement(incrementBidMax);
    } catch (error) {
        return;
    }
}
/**
 * Increment maximum bin price
 */
async function incrementBinMax() {
    try {
        var incrementBinMax = document.getElementsByClassName('btn-standard increment-value')[3];
        tapElement(incrementBinMax);
    } catch (error) {
        return;
    }
}
/**
 * Increment minimum bin price
 */
async function incrementBinMin() {
    try {
        var incrementBinMin = document.getElementsByClassName('btn-standard increment-value')[2];
        tapElement(incrementBinMin);
    } catch (error) {
        return;
    }
}
/**
 * Switch to next page at Transfermarket
 */
function nextSide() {
    if (!isPageTitle("SEARCH RESULTS")) {
        return;
    }
    var nextSide = document.querySelector('.flat.pagination.next');
    tapElement(nextSide);
}
/**
 * Switch to previous page at Transfermarket
 */
function prevSide() {
    if (!isPageTitle("SEARCH RESULTS")) {
        return;
    }
    var prevSide = document.querySelector('.flat.pagination.prev');
    tapElement(prevSide);
}
/**
 * Clear the minimum bid price.
 */
async function clearBidPrice() {
    var clearBtn = document.querySelector('.search-price-header > .flat.camel-case');
    tapElement(clearBtn);
}
/**
 * Check if current page title is equal to provided value
 */
async function isPageTitle(title) {
    var currentPageTitle = document.querySelector('h1.title').innerText;
    return currentPageTitle === title;
}

async function transferMarketOverview() {
    var iconTransfer = document.querySelector('.icon-transfer');
    tapElement(iconTransfer);
}

async function searchTransferMarket() {
    const searchmarket = document.querySelector('.ut-tile-transfer-market')
    tapElement(searchmarket)
}



/**
 * Simulates a tap/click on an element.
 */
async function tapElement(element) {
    sendTouchEvent(element, 'touchstart');
    sendTouchEvent(element, 'touchend');
}
/**
 * Dispatches a touch event on the element.
 * https://stackoverflow.com/a/42447620
 */
async function sendTouchEvent(element, eventType) {
    try {
        var touchObj = new Touch({
            identifier: 'Keyboard shortcuts should be supported natively without an extension!',
            target: element,
            clientX: 0,
            clientY: 0,
            radiusX: 2.5,
            radiusY: 2.5,
            rotationAngle: 10,
            force: 0.5
        });
        var touchEvent = new TouchEvent(eventType, {
            cancelable: true,
            bubbles: true,
            touches: [touchObj],
            targetTouches: [touchObj],
            changedTouches: [touchObj],
            shiftKey: true
        });
        element.dispatchEvent(touchEvent);
    } catch {

    }

}
//WEBAPP CHANGES
function generateAfterTaxInfo() {
    return $(`<div  class="buttonInfoLabel hasPriceBanding">
	<span class="spinnerLabel">${("After Tax:")}</span>
	<span id="saleAfterTax" class="currency-coins bandingLabel">${(
        "price"
    )} 10,000</span>

	
  </div>`);
};
function generateProfitTaxInfo() {
    return $(`<div  class="buttonInfoLabel hasPriceBanding">
	<span class="spinnerLabel">${("Profit:")}</span>
	<span id="profitAfterTax" class="currency-coins bandingLabel">${(
        "price"
    )} 1000</span>

	
  </div>`);
};
function generateUserCoinsAfterSale() {
    return $(`<div  class="buttonInfoLabel hasPriceBanding">
	<span class="spinnerLabel">${("Coins After Sale:")}</span>
	<span id="coinsAfterSale" class="currency-coins bandingLabel">${(
        "price"
    )} 100,000</span>

	
  </div>`);
};


var panelGenerated = false
function playerViewPanelOverride() {
    const calcTaxPrice = (buyPrice, buyPrice2) => {
        
        const userCoins = services.User.getUser().coins.amount;
        const priceAfterTax = (buyPrice * 0.95).toLocaleString();
        const profitAfterTax = (buyPrice * 0.95 - buyPrice2).toLocaleString();
        const coinsAfterSale = (buyPrice * 0.95 + userCoins).toLocaleString();

        $("#saleAfterTax").html(`${priceAfterTax}`);
        $("#profitAfterTax").html(` ${profitAfterTax}`);
        $("#coinsAfterSale").html(` ${coinsAfterSale}`);

    };


    const buyPriceChanged = UTQuickListPanelView.prototype.onBuyPriceChanged;
    const quickListPanelGenerate = UTQuickListPanelView.prototype._generate;
    const auctionActionPanelGenerate =
        UTDefaultActionPanelView.prototype._generate;

    const quickPanelRenderView =
        UTQuickListPanelViewController.prototype.renderView;

    UTQuickListPanelView.prototype.onBuyPriceChanged = function (e, t, i) {
        buyPriceChanged.call(this, e, t, i);
        calcTaxPrice(this._buyNowNumericStepper.getValue(), $('.currency-coins.subContent')[0] == undefined ? 0 : parseInt($('.currency-coins.subContent')[0].innerText.replaceAll(',', '')));
    };

    if (!panelGenerated) {
        UTQuickListPanelView.prototype._generate = function (...args) {
            if (!this._generated) {
                quickListPanelGenerate.call(this, ...args);
                generateUserCoinsAfterSale().insertAfter($(this._buyNowNumericStepper.__root));
                generateProfitTaxInfo().insertAfter($(this._buyNowNumericStepper.__root));
                generateAfterTaxInfo().insertAfter($(this._buyNowNumericStepper.__root));


            }
        };
        UTDefaultActionPanelView.prototype._generate = function (...args) {
            if (!this._generated) {
                auctionActionPanelGenerate.call(this, ...args);
            }
        }
        panelGenerated = true
    }

    UTQuickListPanelViewController.prototype.renderView = function () {
        quickPanelRenderView.call(this);
        let e = this.getView();
    };


};

function quickListOpenOverride() {
    const quickListOpen = UTQuickListPanelViewController.prototype._onOpen;
    UTQuickListPanelViewController.prototype._onOpen = function (...args) {
    try{
        services.User.maxAllowedAuctions = autoBuySettings.activeTransfers ? 100 : 30;
    }catch{
        services.User.maxAllowedAuctions = 30;
    }
        return quickListOpen.call(this, ...args);
    };
};


async function discordWebhook(autobuyerStatus, autobuyerReasonStopPause, playerInfo) {
    let embeddedText
    if (autobuyerStatus == 'Paused') {
        embeddedText = {
            "content": null,
            "embeds": [
                {
                    "title": `AutoBuyer ${autobuyerStatus}`,
                    "color": 13571606,
                    "fields": [
                        {
                            "name": "Reason:",
                            "value": `[${new Date().toLocaleTimeString()}] ${autobuyerReasonStopPause}`
                        }
                    ]
                }
            ],
            "username": "Snipe59",
            "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
            "attachments": []
        }
    } else if (autobuyerStatus == "Stopped") {
        embeddedText = {
            "content": null,
            "embeds": [
                {
                    "title": `Autobuyer Stopped`,
                    "description": `Reason: ${autobuyerReasonStopPause} `,
                    "color": 133968,
                    "fields": [
                        {
                            "name": "Coin Balance",
                            "value": (numberWithCommas(services.User.getUser().coins.amount)).toString(),
                            "inline": true
                        },
                        {
                            "name": "Profit",
                            "value": sessionState.profit < 1 ? '0' : (numberWithCommas(sessionState.profit)).toString()
                        },
                        {
                            "name": "Run Time:",
                            "value": (Math.round((Date.now() - sessionState.botStartTime) / 60000).toFixed(2) + "M").toString()
                        },
                        {
                            "name": "SearchCount",
                            "value": (sessionState.searchCount).toString()
                        },
                        {
                            "name": "Purchased Cards",
                            "value": (sessionState.purchasedCardCount).toString()
                        },
                        {
                            "name": "Transactions",
                            "value": sessionState.transactions.length == 0 ? '-' : (sessionState.transactions).toString().replace(/,/g, "")

                        }
                    ]
                }
            ],
            "username": "Snipe59",
            "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
            "attachments": []
        }
    } else if (autobuyerStatus == 'Seen') {
        {
            embeddedText = {
                "content": null,
                "embeds": [
                    {
                        "title": `Card ${autobuyerStatus}`,
                        "description": `[${new Date().toLocaleTimeString()}] ` + playerInfo,
                        "color": 11857973
                    }
                ],
                "username": "Snipe59",
                "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
                "attachments": []
            }
        }
    } else if (autobuyerStatus == 'Bought') {
        {
            embeddedText = {
                "content": null,
                "embeds": [
                    {
                        "title": `Card ${autobuyerStatus}`,
                        "description": `[${new Date().toLocaleTimeString()}] ` + playerInfo,
                        "color": 1404164
                    }
                ],
                "username": "Snipe59",
                "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
                "attachments": []
            }
        }
    } else if (autobuyerStatus == 'Started') {
        {
            embeddedText = {
                "content": null,
                "embeds": [
                    {
                        "title": `Autobuyer Started`,
                        "color": 133968,
                        "fields": [
                            {
                                "name": "Coin Balance",
                                "value": (numberWithCommas(services.User.getUser().coins.amount)).toString(),
                                "inline": true
                            },
                            {
                                "name": "Run Time:",
                                "value": autoBuySettings.stopAfter,
                                "inline": true
                            }
                        ]
                    }

                ],
                "username": "Snipe59",
                "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
                "attachments": []
            }
        }
    } else if (autobuyerStatus == 'Info') {

        {
            embeddedText = {
                "content": null,
                "embeds": [
                    {
                        "title": `Filter Switched`,
                        "description": `[${new Date().toLocaleTimeString()}] ` + 'Current Filter is: ' + playerInfo,
                        "color": 11857973
                    }
                ],
                "username": "Snipe59",
                "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
                "attachments": []
            }
        }
    } else if (autobuyerStatus == 'Warn') {

        {
            embeddedText = {
                "content": null,
                "embeds": [
                    {
                        "title": `More Than 1 Page`,
                        "description": `[${new Date().toLocaleTimeString()}] ` + 'Current Filter has more than 1 Page',
                        "color": 133968
                    }
                ],
                "username": "Snipe59",
                "avatar_url": "http://i.epvpimg.com/ZQ2efab.png",
                "attachments": []
            }
        }
    }

    let request = new XMLHttpRequest();
    request.open("POST", autoBuySettings.discordWebhookLink);
    request.setRequestHeader('Content-type', 'application/json');

    request.send(JSON.stringify(embeddedText));
}

function displayStopAlert() {
    var newLine = "\r\n"
    var msg = "Profit: " + numberWithCommas(sessionState.profit)
    msg += newLine;
    msg += "Run Time: " + (Math.round((Date.now() - sessionState.botStartTime) / 60000).toFixed(2) + "M").toString();
    msg += newLine;
    msg += "Searchcount: " + (sessionState.searchCount).toString();
    msg += newLine;
    msg += "Purchased Cards: " + (sessionState.purchasedCardCount).toString();
    msg += newLine;
    msg += "Seen Cards: " + (sessionState.seenCards).toString();
    msg += newLine;
    msg += "Transactions: " + (sessionState.transactions.length == 0 ? '-' : (sessionState.transactions).toString().replace(/,/g, ""));
    alert(msg);
}

const restartWebapp = function() {
    location.reload()
}



/**
 * //##################################################################################################################################
 * //#                                           FILTER                                 #
 * //##################################################################################################################################
 */

window.controllerInstance = null;
window.test = function () {
    UTMarketSearchFiltersViewController.call(this);
    window.controllerInstance = this;
    this._jsClassName = "test";
};


function makeid(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

var nameFilterDropdown = '#elem_' + makeid(15),
    nameSelectedFilter = '#elem_' + makeid(15),
    nameSelectFilterCount = '#elem_' + makeid(15),
    nameDeleteFilter = '#elem_' + makeid(15),
    nameDeleteFilter = '#elem_' + makeid(15),
namePreserveChanges = '#elem_' + makeid(15);

window.loadFilter = function () {
    var filterName = $('select[name=filters] option').filter(':selected').val();
    loadFilterByName(filterName);
};

window.notify = function (message, notificationType) {
    notificationType = notificationType || UINotificationType.POSITIVE;
    services.Notification.queue([message, notificationType])
};

window.deleteFilter = function () {
    var filterName = $('select[name=filters] option').filter(':selected').val();
    if (filterName != 'Choose filter to load') {
        $(nameFilterDropdown + ` option[value="${filterName}"]`).remove();
        $(nameSelectedFilter + ` option[value="${filterName}"]`).remove();
        jQuery(nameSelectedFilter).find('option').attr("selected", false);
        window.setFilters();
        jQuery(nameFilterDropdown).prop('selectedIndex', 0);
        var defaultCriteria = '{"searchCriteria":{"criteria":{"_acquiredDate":"","_category":"any","_position":"any","_sort":"desc","_type":"player","_untradeables":"","_zone":-1,"club":-1,"count":21,"defId":[],"excludeDefIds":[],"isExactSearch":false,"league":-1,"level":"any","maskedDefId":0,"maxBid":0,"maxBuy":0,"minBid":0,"minBuy":0,"nation":-1,"offset":0,"playStyle":-1,"rarities":[],"sortBy":"value","subtypes":[]}}}'
        defaultCriteria = JSON.parse(defaultCriteria)
        let defaultCriteriaJson = defaultCriteria.searchCriteria
        Object.assign(getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria, defaultCriteriaJson.criteria);
        //window.controllerInstance.viewDidAppear();
        getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().viewDidAppear()
        window.notify(getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController())
        //GM_deleteValue(filterName);

        let filterArray = JSON.parse(localStorage.getItem('filterArray'));
        console.log(filterArray)
        delete filterArray[filterName]
        localStorage.setItem('filterArray', JSON.stringify(filterArray));
        console.log(filterArray)
        //TODO SEND FILTER NAME TO FLUTTER
        window.flutter_inappwebview.callHandler('deleteFilterName', filterName);
        window.notify("Changes saved successfully");
    }
};


window.loadFilterByName = function (filterName) {
    let searchArray = JSON.parse(localStorage.getItem('filterArray'))
    console.log(searchArray)

    let settingsJson = searchArray[filterName]

    if (!settingsJson) {
        return;
    }

    let savedCriteria = settingsJson.searchCriteria || {};

    if (!jQuery.isEmptyObject(savedCriteria)) {
        console.log("savedCriteria")
        Object.assign(getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria, savedCriteria.criteria);
    }

    getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController().viewDidAppear()
    console.log("viewDidAppear")
}

window.setFilters = function () {
    console.log("setFilters")
    window.selectedFilters = $('select[name=selectedFilters]').val() || [];
    if (window.selectedFilters.length) {
        console.log("filter selected")
        $(nameSelectFilterCount).text('(' + window.selectedFilters.length + ') Filter Selected');
    } else {
        console.log("no filter selected")
        $(nameSelectFilterCount).text('No Filter Selected');
    }
}

//add a listener to the document to listen for the event


window.saveDetails = function () {

    $(namePreserveChanges).addClass("active");

    setTimeout(function () {

        let settingsJson = {};
        settingsJson.searchCriteria = {criteria: getAppMain().getRootViewController().getPresentedViewController().getCurrentViewController().getCurrentController()._viewmodel.searchCriteria};
        var currentFilterName = $('select[name=filters] option').filter(':selected').val();
        if (currentFilterName === 'Choose filter to load') {
            currentFilterName = undefined;
        }
        var filterName = prompt("Enter a name for this filter", currentFilterName);

        if (filterName) {
            filterName = filterName.toUpperCase();
            window.checkAndOption(nameFilterDropdown, filterName);
            window.checkAndOption(nameSelectedFilter, filterName);

            $(`select[name=filters] option[value="${filterName}"]`).attr("selected", true);
            //GM_setValue(filterName, JSON.stringify(settingsJson));
            //detail: { 'detail1': "something", detail2: "something else" }}

            console.log('filterName', filterName)
              //check if filterArray exists at localStorage
              if (localStorage.getItem('filterArray') === null) {
                filterArray = {}
                localStorage.setItem('filterArray', JSON.stringify(filterArray)) }
            
            filterArray = JSON.parse(localStorage.getItem('filterArray'))
            filterArray[filterName] = settingsJson
            console.log('filterArray ', JSON.stringify(filterArray))

            localStorage.setItem('filterArray', JSON.stringify(filterArray));
            $(namePreserveChanges).removeClass("active");
            //TODO SEND FILTER NAME TO FLUTTER
            window.flutter_inappwebview.callHandler('addFilterName', filterName);
            window.notify("Changes saved successfully");
        } else {
            $(namePreserveChanges).removeClass("active");
            window.notify("Filter Name Required", UINotificationType.NEGATIVE);
            //TODO: Add notification
        }
    }, 1);
}


window.checkAndOption = function (dropdownSelector, optionName) {
    let exist = false;
    $(`${dropdownSelector} option`).each(function () {
        if (this.value === optionName) {
            exist = true;
            return false;
        }
    });

    if (!exist) {
        $(dropdownSelector).append($('<option></option>').attr('value', optionName).text(optionName));
    }
}


function appendDiv() {
    $('.ut-item-search-view').first().prepend(
        '<div style="width:100%;display: flex;">' +
        '<div class="button-container">' +
        '<select id="' + nameFilterDropdown.substring(1) + '" name="filters" style="width:100%;padding: 10px;font-family: UltimateTeamCondensed,sans-serif;font-size: 1.6em;color: #e2dde2;text-transform: uppercase;background-color: #171826;"></select>' +
        '</div>' +
        '<div style=margin-top: 1%;" class="button-container">' +
        '<button style="width:25%" class="btn-standard call-to-action" id="' + nameDeleteFilter.substring(1) + '">Delete Filter</button>' +
        '<button style="width:25%" class="btn-standard call-to-action" id="' + namePreserveChanges.substring(1) + '">Save Filter</button>' +
        '</div> </div>');

    let dropdown = $(nameFilterDropdown);
    let filterdropdown = $(nameSelectedFilter);
    $(nameFilterDropdown).empty()
    $(nameSelectedFilter).empty()


    dropdown.append('<option selected="true" disabled>Choose filter to load</option>');
    dropdown.prop('selectedIndex', 0);

        var filterArray = JSON.parse(localStorage.getItem('filterArray'));
        console.log(filterArray);
        if (filterArray) {

            for (var i = 0; i < Object.keys(filterArray).length; i++) {
                dropdown.append($('<option></option>').attr('value', Object.keys(filterArray)[i]).text(Object.keys(filterArray)[i]));
                filterdropdown.append($('<option></option>').attr('value', Object.keys(filterArray)[i]).text(Object.keys(filterArray)[i]));
            }
        }


    

    

}

function resetSessionStats() {
    if (autoBuySettings.autoBuyerState = 'STATE_STOPPED') {
        if ((sessionState.profit > 1000 || sessionState.profit < -10000) && sessionState.searchCount > 5) {
            postFilter()
        }
    }
    sessionState = {
        'botStartTime': '',
        'purchasedCardCount': 0,
        'seenCards': 0,
        'currentPage': '',
        'searchInterval': '',
        'searchCount': 0,
        'previousPause': 0,
        'soldItems': "-",
        'unsoldItems': "-",
        'activeTransfers': "-",
        'availableItems': "-",
        'coins': "-",
        'coinsNumber': 0,
        'profit': 0,
        'transactions': [],
        'purchases': 0,
        'fullList': false
    }
    updateProfits();
}

//CLUB HIDE NAME + PROFITS

function updateProfits() {
    $(".profits-value").text(services.Localization.localizeNumber(parseInt(sessionState.profit)));
}





function createTimeout(time, interval, fired) {
    return {
        fired: fired,
        interval: interval,
        start: time,
        end: time + interval,
    };
};

function getTimerProgress(timer) {
    if (!timer) return 0;
    let time = new Date().getTime();
    return (Math.max(0, timer.end - time) / (timer.end - timer.start)) * 100;
};

function pauseProcessor() {
    pauseIntervalId = setInterval(function () {
        if (timerPause) {
            const width = getTimerProgress(timerPause);
            console.log("width : " + width);
            $(".pauseProgress").css("width", 100 - width);
            $(".pauseProgress").css("background", "#121212");
        }
    }, 100);
};
function requestProcessor() {
    requestIntervalId = setInterval(function () {
        if (sessionState.searchInterval && !timerPause) {
            console.log("requestProcessor")
            const width = getTimerProgress(sessionState.searchInterval);
            console.log("width : " + width);
            $(".pauseProgress").css("width", 100 - width);
            $(".pauseProgress").css("background-color", "#ef6405");
        }
    }, 100);

}

function paginatedResultOverride() {
    const paginatedRenderList = UTPaginatedItemListView.prototype._renderItems;
    const setSectionHeader = UTSectionedItemListView.prototype.setHeader;

    UTPaginatedItemListView.prototype._renderItems = function (...args) {
        const result = paginatedRenderList.call(this, args);
        appendCardPrice(

            this.listRows.map(({
                __root,
                __auction,
                data
            }) => ({
                __root,
                __auction,
                data,
            })),
            "club"
        );
        return result;

    };

    UTSectionedItemListView.prototype.setHeader = function (
        section,
        text,
        ...args
    ) {
        const result = setSectionHeader.call(this, section, text, ...args);
        appendSectionPrices({
            listRows: this.listRows.map(({
                __root,
                __auction,
                data
            }) => ({
                __root,
                __auction,
                data,
            })),
            headerElement: $(this._header.__root),
            sectionHeader: text,
        });
        return result;
    };

}

function resetTimer() {
    timerPause = false;
    if (pauseIntervalId)
        clearInterval(pauseIntervalId);
    $(".pauseProgress").css("width", 0);
}
function resetRequestTimer() {
    if (requestIntervalId)
        clearInterval(requestIntervalId);
    $(".pauseProgress").css("width", 0);
}

//call function every 2min
setInterval(async function () {
    futstarzApi = await  getFUTstarzApi();
}, 120000);


async function getFUTstarzApi() {
    const ms = Date.now();
    let url;
        url = 'https://futsovereign.com/futsovereign/dixeam/player/get_futstarz?url=dealfinder2110&ms='

    const futstarzApi = await fetch(url + {
        ms
    })
        .then(response => response.json())
        .then(data => data);
    return futstarzApi;
}

var platform = 'ps';

async function getPlayerPriceFromFutstarz(playerId) {
    const playerPrice = await futstarzApi.find((player) => player.playerExternalId === playerId.toString());
    //if not found
    if (!playerPrice) {
        return 0;
    }
    platform = 'ps';

        if (platform == 'ps') {
            return playerPrice.currentPricePs4
        } else {
            return playerPrice.currentPriceXbox
        }
    
}


async function getPricesForCards(cards) {
    const prices = new Map();

    for (const card of cards) {
        if (!card.definitionId) {
            continue;
        }
        const price = await getPlayerPriceFromFutstarz(card.definitionId);
        if (price) {
            prices.set(`${card.definitionId}`, price);
        } else {
            prices.set(`${card.definitionId}`, 'NaN');
        }
    }
    return prices;
}

function checkAndAppendMarginIndicator(rootElement, bin, bid, price) {
    const margin = price * 0.90;
    if (
        (bin && margin > bin) ||
        (bin && margin > bid)
    ) {
        rootElement.addClass("futstarzLessPrice");
    }

}


async function appendCardPrice(listRows, section) {
    const cards = [];
    const isFromPacks = section === "packs";
    const sectionAuctionData = listRows[0].data.getAuctionData();


    const isSelectable = !isFromPacks &&
        section !== "club" &&
        !sectionAuctionData.isSold() &&
        !sectionAuctionData.isActiveTrade() &&
        !sectionAuctionData.isOutbid();

    for (const {
        data
    }
        of listRows) {
        cards.push(data);
    }
    const dataSource = ' FUTstarz Price';
    const prices = await getPricesForCards(cards);
    let totalFutstarzPrice = 0;
    let totalBid = 0;
    let totalBin = 0;

    for (const {
        __auction,
        data,
        __root
    }
        of listRows) {

        const auctionElement = $(__auction);
        const rootElement = $(__root);
        const {
            definitionId,
            _auction: auctionData,
            lastSalePrice,
        } = data;
        const cardPrice = prices.get(`${definitionId.toString()}`);
        if (cardPrice === undefined) {
            continue;
        }
        if (auctionElement.attr("style")) {
            auctionElement.removeAttr("style");
            auctionElement.addClass("hideauction");
        }

        const bidPrice = auctionData.currentBid || auctionData.startingBid;
        totalBid += bidPrice;
        totalBin += auctionData.buyNowPrice;
        totalFutstarzPrice += cardPrice || 0;
        appendPrice(
            dataSource.toUpperCase(),
            auctionElement,
            cardPrice,
            auctionData._tradeState === "inactive" &&
                !rootElement.hasClass("has-action") ?
                lastSalePrice :
                0
        );
        checkAndAppendMarginIndicator(
            rootElement,
            auctionData.buyNowPrice,
            bidPrice,
            cardPrice
        );
    }
    return {
        totalBid,
        totalBin,
        totalFutstarzPrice
    };
};


function appendPriceInfo(label, auctionElement, price, selector, percentDiff) {
    const color =
        percentDiff < 0 ? "orangered" : percentDiff > 0 ? "lime" : "darksalmon";
    auctionElement.prepend(`<div class="auctionValue ${selector} priceFutstarz">
                    <span class="label">${label} ${percentDiff !== undefined
            ? `<info style='color: ${color}'>(${percentDiff.toFixed(2)}%)</info>`
            : ""
        }</span>
                    <span class="currency-coins value">${price ? price.toLocaleString() : "---"
        }</span>             
                  </div>`);
};

function appendPrice(dataSource, auctionElement, price, boughtFor){
    let percentDiff = undefined;
    const element = $("<div class='priceFutstarz auctionValue priceholder'></div>");
    auctionElement.find(".priceFutstarz").remove();
    if (boughtFor) {
        percentDiff = getPercentDiff(price * 0.95, boughtFor);
        appendPriceInfo(
            services.Localization.localize("infopanel.label.prevBoughtPrice"),
            element,
            boughtFor,
            "boughtFor"
        );
    }

    appendPriceInfo(dataSource, element, price, "priceFutstarzsel", percentDiff);
    auctionElement.prepend(element);
};

async function appendSectionPrices(sectionData) {
    const dataSource = "FUTstarz Price";
    if (sectionData.listRows.length) {
        appendCardPrice(sectionData.listRows, sectionData.sectionHeader);
    }
};




    function getPercentDiff(number1, number2) {
        return ((number1 - number2) / ((number1 + number2) / 2)) * 100;
    }


function overrideStyle() {
    const style = document.createElement("style");
    style.innerText = `
    .player-stats-data-component ul { 
      display: grid;   
      grid-template-columns: 1fr 1fr 1fr; 
      grid-template-rows: 1fr; 
      width: 78px; 
    }
    .SearchResults.ui-layout-left>.paginated-item-list>ul{
      display: grid;
      grid-template-columns: 1fr 1fr;
      grid-template-rows: repeat(25,1fr);
    }

    .ut-split-view {
      padding: 0;
    }
    .ui-layout-left .listFUTItem .auction{
      top: 3% !important;      
      width: 37% !important;
      right: .5rem;
    }
    .auction.show {
      display: block !important;
    }
    .auction.show .auctionValue,
    .auction.show .auction-state{
      display: none !important;
    }
    .auction.show .priceFutstarz{
      display: block !important;
    }
    .SearchResults.ui-layout-left .listFUTItem.futbinLessPrice .rowContent,
    .phone .SearchResults .listFUTItem.futbinLessPrice .rowContent{
      background-color: blue;
      animation: 4s infinite glow;
    }
    .SearchResults.ui-layout-left .listFUTItem.hideResult,
    .phone .SearchResults .listFUTItem.hideResult{
     display :none;
    }
    .SearchResults.ui-layout-left .listFUTItem.expired .rowContent, 
    .phone .SearchResults .listFUTItem.expired .rowContent,
    .SearchResults.ui-layout-left .listFUTItem.highest-bid .rowContent, 
    .phone .SearchResults .listFUTItem.highest-bid .rowContent,
    .SearchResults.ui-layout-left .listFUTItem.outbid .rowContent, 
    .phone .SearchResults .listFUTItem.outbid .rowContent,
    .SearchResults.ui-layout-left .listFUTItem.won .rowContent
    .phone .SearchResults .listFUTItem.won .rowContent{
      background-color: #0d0f26;
      animation: none !important;
    }
    @keyframes glow {
      33% {
        background-color: red;
      }
      66% {
        background-color: blue;
      }
      100% {
        background-color: purple;
      }
    }
    @media (min-width: 1281px) {
      .ut-split-view .ut-content {
        max-width: 100%;
        max-height: 100%;
      }
    }
    @media (min-width: 1600px) {
      .SearchResults.ui-layout-left>.paginated-item-list>ul {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        grid-template-rows: repeat(17,1fr);
      }
    }
    .downloadClub {
      background-color: #7e42f5;
      border-color: transparent;
      color: #29ffc9;
      margin-right: 10px;      
      margin-left: 10px;
    }
    .ut-list-header-action {
      display: flex
    }
    .SearchResults.ui-layout-left .listFUTItem .show-duplicate,
    .phone .SearchResults .listFUTItem .show-duplicate {
      right: auto !important;
      left: 15px!important;
      display: block;
    }
    .ui-layout-right .priceFutstarz{
      display:none;
    }
    .futBinFill { 
      display: flex; 
      justify-content: space-evenly;
    }
    .futBinId {
      flex-basis: 50%;
    }
    .phone .listFUTItem .auction>.auction-state, 
    .phone .listFUTItem .auction>.auctionStartPrice, 
    .phone .listFUTItem .auction>.auctionValue {
      flex: 1 1 28%;
      overflow: hidden;
    }
    html[dir=ltr]
    .phone .listFUTItem .auction {
      right: 0px;
    }
    html[dir=ltr] 
    .listFUTItem .auction.show {
      left: auto
    }
    .phone .auction.show {
      right: 2rem !important;
    }
    .enhancer-option-header {
      display: flex;
      justify-content: center;
      margin-top: 20px;
    } 
    .phone .settings-field  {
      width: 100% !important;
      padding: 0px 10px;
      display: flex;
      justify-content: center;
      align-items: center;
      flex-direction: column;
    }
    .settings-field .ut-toggle-cell-view {
      justify-content: space-between;
      margin: 0px 10px;
    }
    .hide {
      display: none;
    }
    .hideauction .auctionValue,
    .hideauction .auction-state {
      display: none;
    } 
    .hideauction .priceFutstarz,
    .auction.hideauction,
    .show {
      display: unset !important;
      float: right;
    }
    .relistFut {
      margin-right: 10px;
      display: none;
    }
    .button--loading .button__text {
      visibility: hidden;
      opacity: 0;
    }
    .button-spinner {
      position: relative;
    }
    .button--loading::after {
      content: "";
      position: absolute;
      width: 16px;
      height: 16px;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      margin: auto;
      border: 4px solid transparent;
      border-top-color: #29ffc9;
      border-radius: 50%;
      animation: button-loading-spinner 1s ease infinite;
    }
    .ui-layout-right .enhancer-option-header,
    .ui-layout-right .settings-field {
      display: none;
    }
    
    @keyframes button-loading-spinner {
      from {
        transform: rotate(0turn);
      }
    
      to {
        transform: rotate(1turn);
      }
    }
    .enhancer-settings-wrapper {
      display: flex; 
      flex-wrap: wrap; 
      margin-top: 20px;
      box-shadow: 0 1rem 3em rgb(0 0 0 / 40%);
      background-color: #2a323d;
      max-width: 1200px;
    }
    .enhancer-settings-header {
      display: flex;
      justify-content: center;
      margin: 20px;
      width: 100%;
    }
    .enhancer-save-btn {
      display: flex;
      justify-content: center;
      align-items: center;
      flex: 1;
      margin: 15px;
    }
    .flex-half{
      flex: 0.5;
    }
    .settings-field {
      margin-top: 15px;
      margin-bottom: 15px;
      width: 50% !important;
      padding: 10px;
    }
    .settings-field .info{
      text-align: center;
    }
    .phone .settings-field .info,
    .phone .settings-field .buttonInfo{ 
      width:85%
    }
    .numericInput:invalid {
      color: red;
      border: 1px solid;
    }
    input[type="number"]{
      padding: 0 .5em;
      border-radius: 0;
      background-color: #262c38;
      border: 1px solid #4ee6eb;
      box-sizing: border-box;
      color: #4ee6eb;
      font-family: UltimateTeam,sans-serif;
      font-size: 1em;
      height: 2.8em;
      opacity: 1;
      width: 100%;
    }
    input[type=number] {
      -moz-appearance: textfield;
    }
    .phone .ut-store-reveal-modal-list-view--wallet {
      flex: unset;
    }
    .price-totals {
      border-top: 1px solid #4ee6eb;
      display: flex;
      justify-content: flex-end;
      height: 35px;
      align-items: center;
    }
    .phone .hideauction .priceFutstarz{
      float: right; 
    }
    .fut-bin-buy {
      margin-top: 15px;
      margin-bottom: 15px;
    }
    .sbc-players-list {
      width: 100%;
      padding: 10px;
      font-family: UltimateTeamCondensed, sans-serif;
      font-size: 1.6em;
      color: #e2dde2;
      text-transform: uppercase;
      background-color: #171826;
    }
    .packOpen {
      margin-left: 0.5rem;
      flex-basis: 50% !important;
    }
    .phone .packOpen {
      flex-basis: 100% !important;
    }
    .squad-fut-bin {
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .sbcSolutions {
      margin-bottom: 10px;
      display: flex;
      justify-content: center;
      align-items: center;
      flex-direction: column;
      gap: 10px;
    }
    .relist {
      margin-left: 10px;
    }
    .phone .clubAction {
      font-family: UltimateTeam-Icons,sans-serif;
      padding: 0 0.5rem 0 1rem;
      font-size: 0;
    }
    .phone .downloadClub::before {
      font-size: 1.3rem;
      content: '\\E001'
    }
    .phone .transferpile::before {
      font-size: 1.3rem;
      content: '\\E073'
    }
    small {
      white-space: break-spaces;
    }
    .ut-navigation-bar-view .view-navbar-currency-coins {
      cursor: pointer;
      position: relative;
    }
    .ut-navigation-bar-view .view-navbar-currency-coins::before {
      font-family: UltimateTeam-Icons,sans-serif;
      font-style: normal;
      font-variant: normal;
      font-weight: 400;
      text-decoration: none;
      text-transform: none;
      background-color: #f8eede;
      color: #243962;
      display: block;
      font-size: .5rem;
      line-height: .5rem;
      padding: 0.2rem;
      order: 1;
    }
    .ut-navigation-bar-view .view-navbar-currency-coins:before {
      margin-left: 3px;
      content: "\\E06A";
    }
    .price-filter .ut-toggle-cell-view--label{
      font-size: 19px;
    }
    .autoBuyMin {
      width: 100% !important;
    }
    .autoBuyMin .ut-toggle-cell-view {
      justify-content: flex-start;
    }
    .player-select {
     position: absolute;
      z-index: 20;
    }
    div.player-select {
      width:75px;
      height:75px;
     }
     .boughtFor.priceFutstarz{
      margin-right: 15px;
     }
     .phone .priceholder{
       display: flex !important;
       flex-direction: column-reverse;
    }
    .phone .ut-section-header-view.relistsection {
      flex-direction: row;
      flex-wrap: wrap;
    }
    .relistwrapper{
      display: flex;
    }
    .phone .relistwrapper{
      width: 100%;
      justify-content: flex-end;
      margin-top: 8px;
    }
    .btnAverage {
      height: unset !important;
      align-items: flex-start !important;
      line-height: unset !important;
    }
    .follow {
      background: #000000;
      text-transform: uppercase;
      letter-spacing: 3px;
      padding: 4px;
      width: 190px;
      position: fixed;
      right: -160px;
      z-index: 1000;
      font: normal normal 10px Arial;
      -webkit-transition: all .25s ease;
      -moz-transition: all .25s ease;
      -ms-transition: all .25s ease;
      -o-transition: all .25s ease;
      transition: all .25s ease;
    }   
    .follow:hover {
      right: 0;
    }
    .playerOverview .preferredPosition{
      font-size:9px;
      border-radius:50%;
      margin-bottom:5px;
      background: cornflowerblue;
    }    
    .follow a {
      color: #fff !important;
      text-decoration: none;
      text-align: center;
      line-height: 43px!important;
      vertical-align: top!important;
    }`;
  document.head.appendChild(style);
};

function searchMarketOverride() {
    JSUtils.inherits(UTMarketSearchFiltersViewController, UTMarketSearchFiltersViewController)

    const initTM =
        UTMarketSearchFiltersViewController.prototype.init;

    UTMarketSearchFiltersViewController.prototype.init = function () {
        initTM.call(this);
        let view = this.getView();
        let root = $(view.__root);
        const btnContainer = root.find(".button-container");
        const createButtonWithContext = createButton.bind(this);
        const startBtn = createButtonWithContext(
            "START",
            function () {
                if (window.autoBuySettings && window.autoBuySettings.autoBuyerState !== 'STATE_ACTIVE') {
                            window.autoBuySettings.autoBuyerActive = false
                            autoBuySettingsAll.map(a => a.autoBuyerActive = false);
                            startAutoBuyer();


                } else {
                    searchMarket()
                }
            }, '');
        btnContainer.append($(startBtn.__root));

    };
}

// function () {
//     if (autoBuySettings.autoBuyerState !== 'STATE_ACTIVE') {
//         autoBuySettings.autoBuyerActive = false
//         autoBuySettingsAll.map(a => a.autoBuyerActive = false);
//         if (autoBuySettings.notifyBotStarted) {
//             discordWebhook('Started', '', '')
//         }
//         startAutoBuyer();
//     } else {
//         searchMarket()
//     }
// }

