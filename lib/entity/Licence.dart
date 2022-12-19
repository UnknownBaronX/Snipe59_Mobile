class Licence {
  bool? success;
  Data? data;

  Licence({this.success, this.data});

  Licence.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? orderId;
  int? productId;
  int? userId;
  String? licenseKey;
  String? expiresAt;
  int? validFor;
  int? source;
  int? status;
  int? timesActivated;
  int? timesActivatedMax;
  String? createdAt;
  int? createdBy;
  String? updatedAt;
  int? updatedBy;

  Data(
      {this.id,
        this.orderId,
        this.productId,
        this.userId,
        this.licenseKey,
        this.expiresAt,
        this.validFor,
        this.source,
        this.status,
        this.timesActivated,
        this.timesActivatedMax,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.updatedBy});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    productId = json['productId'];
    userId = json['userId'];
    licenseKey = json['licenseKey'];
    expiresAt = json['expiresAt'];
    validFor = json['validFor'];
    source = json['source'];
    status = json['status'];
    timesActivated = json['timesActivated'];
    timesActivatedMax = json['timesActivatedMax'];
    createdAt = json['createdAt'];
    createdBy = json['createdBy'];
    updatedAt = json['updatedAt'];
    updatedBy = json['updatedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderId'] = this.orderId;
    data['productId'] = this.productId;
    data['userId'] = this.userId;
    data['licenseKey'] = this.licenseKey;
    data['expiresAt'] = this.expiresAt;
    data['validFor'] = this.validFor;
    data['source'] = this.source;
    data['status'] = this.status;
    data['timesActivated'] = this.timesActivated;
    data['timesActivatedMax'] = this.timesActivatedMax;
    data['createdAt'] = this.createdAt;
    data['createdBy'] = this.createdBy;
    data['updatedAt'] = this.updatedAt;
    data['updatedBy'] = this.updatedBy;
    return data;
  }
}