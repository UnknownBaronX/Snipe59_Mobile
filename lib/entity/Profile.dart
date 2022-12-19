import 'package:uuid/uuid.dart';

class Profile {
  bool activeTransfers = false;
  bool? autoBuyerActive;
  String? autoBuyerState;
  int? buyPrice;
  int? cardCount;
  bool cheapCard = false;
  String? cycleAmount;
  bool delayBuyNow = false;
  String? delayBuyNowTime;
  String? discordWebhookLink;
  String? filter;
  String? filterSearchAmount;
  bool filterSwitch = false;
  String? followUpAction;
  bool incrementMinBin = false;
  bool lastCard = false;
  String? listDuration;
  int? maxRating;
  String? minDeleteCount;
  int? minRating;
  bool notifyBotPaused = false;
  bool notifyBotStarted = false;
  bool notifyBotStopped = false;
  bool notifyCardBought = false;
  bool notifyCardVisible = false;
  bool notifyFilterSwitch = false;
  bool notifyMorePages = false;
  String? pauseFor;
  String? profileName;
  int? resetPrice;
  String? sellPrice;
  String? startAutobuyer;
  String? stopAfter;
  String? stopAutobuyer;
  String? unassignedValue;
  bool unsoldItems = false;
  String? uuid;
  bool isActive = false;
  String? waitTime;

  Profile.createProfile(int nb) {
    var uuidGen = Uuid();
    this.uuid = uuidGen.v4();
    this.profileName = "Profile " + nb.toString();
    this.lastCard = false;
    this.cardCount = 10;
    this.listDuration = "1H";
    this.waitTime = "7000-15000";
    this.cycleAmount = "10-15";
    this.pauseFor = "5-8S";
    this.stopAfter = "1-2H";
    this.unsoldItems = false;
    this.autoBuyerState = "STATE_STOPPED";
    this.delayBuyNow = false;
    this.delayBuyNowTime = "1S";
    this.activeTransfers = false;
    this.incrementMinBin = false;
    this.filterSwitch = false;
    this.filterSearchAmount = "10";
    this.minDeleteCount = "10";
    if (nb == 1) isActive = true;
  }

  Profile(
      {this.activeTransfers = false,
      this.autoBuyerActive,
      this.autoBuyerState,
      this.buyPrice,
      this.cardCount,
      this.cheapCard = false,
      this.cycleAmount,
      this.delayBuyNow = false,
      this.delayBuyNowTime,
      this.discordWebhookLink,
      this.filter,
      this.filterSearchAmount,
      this.filterSwitch = false,
      this.followUpAction,
      this.incrementMinBin = false,
      this.lastCard = false,
      this.listDuration,
      this.maxRating,
      this.minDeleteCount,
      this.minRating,
      this.notifyBotPaused = false,
      this.notifyBotStarted = false,
      this.notifyBotStopped = false,
      this.notifyCardBought = false,
      this.notifyCardVisible = false,
      this.notifyFilterSwitch = false,
      this.notifyMorePages = false,
      this.pauseFor,
      this.profileName,
      this.resetPrice,
      this.sellPrice,
      this.startAutobuyer,
      this.stopAfter,
      this.stopAutobuyer,
      this.unassignedValue,
      this.unsoldItems = false,
      this.uuid,
      this.waitTime,
      this.isActive = false});

  Profile.fromJson(Map<String, dynamic> json) {
    activeTransfers = json['activeTransfers'];
    autoBuyerActive = json['autoBuyerActive'];
    autoBuyerState = json['autoBuyerState'];
    buyPrice = json['buyPrice'];
    cardCount = json['cardCount'];
    cheapCard = json['cheapCard'];
    cycleAmount = json['cycleAmount'];
    delayBuyNow = json['delayBuyNow'];
    delayBuyNowTime = json['delayBuyNowTime'];
    discordWebhookLink = json['discordWebhookLink'];
    filter = json['filter'];
    filterSearchAmount = json['filterSearchAmount'];
    filterSwitch = json['filterSwitch'];
    followUpAction = json['followUpAction'];
    incrementMinBin = json['incrementMinBin'];
    lastCard = json['lastCard'];
    listDuration = json['listDuration'];
    maxRating = json['maxRating'];
    minDeleteCount = json['minDeleteCount'];
    minRating = json['minRating'];
    notifyBotPaused = json['notifyBotPaused'];
    notifyBotStarted = json['notifyBotStarted'];
    notifyBotStopped = json['notifyBotStopped'];
    notifyCardBought = json['notifyCardBought'];
    notifyCardVisible = json['notifyCardVisible'];
    notifyFilterSwitch = json['notifyFilterSwitch'];
    notifyMorePages = json['notifyMorePages'];
    pauseFor = json['pauseFor'];
    profileName = json['profileName'];
    resetPrice = json['resetPrice'];
    sellPrice = json['sellPrice'];
    startAutobuyer = json['startAutobuyer'];
    stopAfter = json['stopAfter'];
    stopAutobuyer = json['stopAutobuyer'];
    unassignedValue = json['unassignedValue'];
    unsoldItems = json['unsoldItems'];
    uuid = json['uuid'];
    waitTime = json['waitTime'];
    isActive = json['isActive'] ?? false;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activeTransfers'] = this.activeTransfers;
    data['autoBuyerActive'] = this.autoBuyerActive;
    data['autoBuyerState'] = this.autoBuyerState;
    data['buyPrice'] = this.buyPrice;
    data['cardCount'] = this.cardCount;
    data['cheapCard'] = this.cheapCard;
    data['cycleAmount'] = this.cycleAmount;
    data['delayBuyNow'] = this.delayBuyNow;
    data['delayBuyNowTime'] = this.delayBuyNowTime;
    data['discordWebhookLink'] = this.discordWebhookLink;
    data['filter'] = this.filter;
    data['filterSearchAmount'] = this.filterSearchAmount;
    data['filterSwitch'] = this.filterSwitch;
    data['followUpAction'] = this.followUpAction;
    data['incrementMinBin'] = this.incrementMinBin;
    data['lastCard'] = this.lastCard;
    data['listDuration'] = this.listDuration;
    data['maxRating'] = this.maxRating;
    data['minDeleteCount'] = this.minDeleteCount;
    data['minRating'] = this.minRating;
    data['notifyBotPaused'] = this.notifyBotPaused;
    data['notifyBotStarted'] = this.notifyBotStarted;
    data['notifyBotStopped'] = this.notifyBotStopped;
    data['notifyCardBought'] = this.notifyCardBought;
    data['notifyCardVisible'] = this.notifyCardVisible;
    data['notifyFilterSwitch'] = this.notifyFilterSwitch;
    data['notifyMorePages'] = this.notifyMorePages;
    data['pauseFor'] = this.pauseFor;
    data['profileName'] = this.profileName;
    data['resetPrice'] = this.resetPrice;
    data['sellPrice'] = this.sellPrice;
    data['startAutobuyer'] = this.startAutobuyer;
    data['stopAfter'] = this.stopAfter;
    data['stopAutobuyer'] = this.stopAutobuyer;
    data['unassignedValue'] = this.unassignedValue;
    data['unsoldItems'] = this.unsoldItems;
    data['uuid'] = this.uuid;
    data['waitTime'] = this.waitTime;
    data['isActive'] = this.isActive;
    return data;
  }
}
