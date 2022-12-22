class ShowView{
  String? version;
  String? active;

  ShowView({this.version, this.active});

  ShowView.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    active = json['active'];
  }


}