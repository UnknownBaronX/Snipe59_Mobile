class FutsovereignItem {
  String? playerExternalId;
  String? playerCardTypeId;
  int? overall;
  String? position;
  String? playerFullName;
  int? currentPricePs4;
  int? currentPriceXbox;
  int? proPricePs4;
  int? proPriceXbox;
  int? average3Ps4;
  int? average3Xbox;
  String? createdAt;
  String? updatedAt;
  String? dataId;
  String? rarityId;
  String? rarityLabel;

  FutsovereignItem(
      {this.playerExternalId,
      this.playerCardTypeId,
      this.overall,
      this.position,
      this.playerFullName,
      this.currentPricePs4,
      this.currentPriceXbox,
      this.proPricePs4,
      this.proPriceXbox,
      this.average3Ps4,
      this.average3Xbox,
      this.createdAt,
      this.updatedAt,
      this.dataId,
      this.rarityId,
      this.rarityLabel});

  FutsovereignItem.fromJson(Map<String, dynamic> json) {
    playerExternalId = json['playerExternalId'];
    playerCardTypeId = json['playerCardTypeId'];
    overall = json['overall'];
    position = json['position'];
    playerFullName = json['playerFullName'];
    currentPricePs4 = json['currentPricePs4'];
    currentPriceXbox = json['currentPriceXbox'];
    proPricePs4 = json['proPricePs4'];
    proPriceXbox = json['proPriceXbox'];
    average3Ps4 = json['average3Ps4'];
    average3Xbox = json['average3Xbox'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    dataId = json['dataId'];
    rarityId = json['rarityId'];
    rarityLabel = json['rarityLabel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['playerExternalId'] = this.playerExternalId;
    data['playerCardTypeId'] = this.playerCardTypeId;
    data['overall'] = this.overall;
    data['position'] = this.position;
    data['playerFullName'] = this.playerFullName;
    data['currentPricePs4'] = this.currentPricePs4;
    data['currentPriceXbox'] = this.currentPriceXbox;
    data['proPricePs4'] = this.proPricePs4;
    data['proPriceXbox'] = this.proPriceXbox;
    data['average3Ps4'] = this.average3Ps4;
    data['average3Xbox'] = this.average3Xbox;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['dataId'] = this.dataId;
    data['rarityId'] = this.rarityId;
    data['rarityLabel'] = this.rarityLabel;
    return data;
  }
}
