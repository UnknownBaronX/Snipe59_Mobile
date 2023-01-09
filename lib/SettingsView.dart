import 'package:custom_check_box/custom_check_box.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snipe59/WebappView.dart';
import 'package:snipe59/client/ProfileBloc.dart';
import 'package:snipe59/client/ProfileState.dart';
import 'package:snipe59/entity/ItemDropdown.dart';
import 'package:snipe59/entity/Profile.dart';
import 'package:snipe59/field/BeautyTextfield.dart';

import 'client/ProfileEvent.dart';

typedef void OnValueChanged(String value);

class SettingsView extends StatelessWidget {
  // This widget is the root of your application.
  final OnProfileSaved onSave;
  final OnHideSettings onHide;

  const SettingsView({Key? key, required this.onSave, required this.onHide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsViewPage(onSave: onSave, onHide: onHide);
  }
}

class SettingsViewPage extends StatefulWidget {
  final OnProfileSaved onSave;
  final OnHideSettings onHide;

  const SettingsViewPage(
      {super.key, required this.onSave, required this.onHide});

  @override
  _SettingsViewPageState createState() =>
      _SettingsViewPageState(onSave, onHide);
}

class _SettingsViewPageState extends State<SettingsViewPage> {
  final OnProfileSaved onSave;
  final OnHideSettings onHide;

  late ProfileBloc _profileBloc;

  late Profile? profile = null;
  late String selectedProfile;
  late List<Profile> profileList;
  late List<String>? filterList;

  late List<ItemDropdown> profiles;
  late BuySellPanel buyPanel;
  late SearchPanel searchPanel;
  late MiscPanel miscPanel;
  late Notificationpanel notificationpanel;
  late FilterPanel filterPanel;
  late Padding List_Criteria;
  late List<SettingsPanel> items;
  Key _refreshKey = UniqueKey();
  Key _listKey = UniqueKey();

  _SettingsViewPageState(this.onSave, this.onHide);

  @override
  void initState() {
    super.initState();
    _profileBloc = context.read<ProfileBloc>();
    _profileBloc.add(LoadProfiles());
  }

  void initProfilesList(List<Profile> profileList, List<String>? filterList) {
    Profile? activeProfile = null;
    this.profileList = profileList;
    this.filterList = filterList;
    this.profiles = List.empty(growable: true);
    for (var p in profileList) {
      this.profiles.add(ItemDropdown(label: p.profileName!, value: p.uuid!));
      if (p.isActive) activeProfile = p;
    }
    if (profile == null) {
      this.profile = activeProfile ?? profileList.first;
      this.selectedProfile = profile!.uuid!;
    }
    initProfileView();
    setState(() {
      _listKey = UniqueKey();
    });
  }

  void initProfileView() {
    buyPanel = BuySellPanel(profile!);
    searchPanel = SearchPanel(profile!);
    miscPanel = MiscPanel(profile!);
    notificationpanel = Notificationpanel(profile!);
    filterPanel = FilterPanel(profile!, this.filterList);

    items = <SettingsPanel>[
      SettingsPanel(
          true, // isExpanded ?
          'Buy/Sell', // header
          buyPanel),
      SettingsPanel(
          true, // isExpanded ?
          'Search', // header
          searchPanel),
      SettingsPanel(
          true, // isExpanded ?
          'Misc', // header
          miscPanel),
      SettingsPanel(
          true, // isExpanded ?
          'Notifications', // header
          notificationpanel),
      SettingsPanel(
          true, // isExpanded ?
          'Filter', // header
          filterPanel)
    ];
  }

  save() {
    String? errorBuy = buyPanel.save(profile!);
    if (errorBuy != null) {
      showSnackbarError(errorBuy);
    }
    String? errorPanel = searchPanel.save(profile!);
    if (errorPanel != null) {
      showSnackbarError(errorPanel);
    }
    String? errorMisc = miscPanel.save(profile!);
    if (errorMisc != null) {
      showSnackbarError(errorMisc);
    }
    notificationpanel.save(profile!);
    filterPanel.save(profile!);
    if (errorBuy == null && errorPanel == null && errorMisc == null)
      _profileBloc.add(SaveProfile(profile: profile!));
  }

  showSnackbarError(String err) {
    ScaffoldMessenger.of(context).clearSnackBars();
    var snackBar = SnackBar(
      content: Text(
        err,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 8),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showSnackbarSuccess(String err) {
    ScaffoldMessenger.of(context).clearSnackBars();

    var snackBar = SnackBar(
      content: Text(
        err,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _launch() {
    onHide.call();
  }

  _makeActive() {
    _profileBloc.add(SetActive(profile: profile!));
    profile!.isActive = true;
  }

  _createProfile() {
    _profileBloc.add(const CreateProfile());
  }

  _deleteProfile() {
    profile = null;
    _profileBloc.add(DeleteProfile(profileId: this.selectedProfile));
  }

  _onChangedProfile(String profile) {
    for (var p in this.profileList) {
      if (p.uuid == profile) {
        this.profile = p;
        this.selectedProfile = profile;
        break;
      }
    }
    setState(() {
      _refreshKey = UniqueKey();
    });

    initProfileView();
  }

  @override
  Widget build(BuildContext context) {
    List_Criteria = Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 300,
            child: Image.asset("assets/SnipeLogo.png"),
          ),
          BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileStateListSuccess) {
                initProfilesList(state.profileList, state.filterList);
              } else if (state is ProfileStateReload) {
                onSave.call();
                showSnackbarSuccess("Settings saved");
              }
            },
            builder: (context, state) {
              if (state is ProfileStateListSuccess ||
                  state is ProfileStateReload) {
                return Expanded(
                    child: Column(
                  key: _listKey,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    DropDownCustom(
                        title: "Profile",
                        items: this.profiles,
                        displayTitle: false,
                        profile: this.profile,
                        selectedValue: this.selectedProfile,
                        onValueChanged: _onChangedProfile),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _createProfile,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.blueAccent,
                                        Colors.blueAccent,
                                        Colors.blueAccent,
                                      ])),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Create',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          profile!.isActive
                              ? Container()
                              : GestureDetector(
                                  onTap: _makeActive,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.greenAccent,
                                              Colors.greenAccent,
                                              Colors.greenAccent,
                                            ])),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'Active',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                          GestureDetector(
                            onTap: _deleteProfile,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.redAccent,
                                        Colors.redAccent,
                                        Colors.redAccent,
                                      ])),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ListView(
                        key: _refreshKey,
                        children: items.map((SettingsPanel i) {
                          return ExpandablePanel(
                            controller: ExpandableController(
                                initialExpanded: i.isExpanded),
                            theme: ExpandableThemeData(
                              iconColor: Colors.white,
                            ),
                            header: Text(
                              i.header,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            expanded: i.body,
                            collapsed: Container(),
                          );
                        }).toList(),
                      ),
                    )),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _launch,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF1D1B28),
                                      Color(0xFF1D1B28),
                                      Color(0xFF1D1B28),
                                    ])),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Go Back',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: GestureDetector(
                              onTap: save,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF8A2387),
                                          Color(0xFFE94057),
                                          Color(0xFFF27121),
                                        ])),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ));
              } else if (state is ProfileStateLoading) {
                return Text(
                  "Loading profile list",
                  style: TextStyle(color: Colors.white),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );

    return Container(
        decoration: const BoxDecoration(color: const Color(0xFF1D1B28)),
        child:
            List_Criteria); // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class SettingsPanel {
  bool isExpanded;
  final String header;
  final Widget body;

  SettingsPanel(this.isExpanded, this.header, this.body);
}

class BuySellPanel extends StatelessWidget {
  late Profile profile;
  late CheckBoxCustom checkCheap;
  late CheckBoxCustom checkLast;
  late DropDownCustom followupAction;

  TextEditingController _buyPriceController = TextEditingController();
  TextEditingController _nbCardController = TextEditingController();
  TextEditingController _resetPriceController = TextEditingController();
  TextEditingController _sellPriceController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  BuySellPanel(Profile p) {
    this.profile = p;
    _buyPriceController.text = p.buyPrice != null ? p.buyPrice.toString() : "";
    _resetPriceController.text =
        p.resetPrice != null ? p.resetPrice.toString() : "";
    _sellPriceController.text =
        p.sellPrice != null ? p.sellPrice.toString() : "";
    _durationController.text =
        p.listDuration != null ? p.listDuration.toString() : "";
    _nbCardController.text = p.cardCount.toString();
    this.checkCheap = CheckBoxCustom(
      title: "Select cheapest card on list",
      value: profile.cheapCard,
    );
    this.checkLast = CheckBoxCustom(
        title: "Select last card on list", value: profile.lastCard);
    this.followupAction = DropDownCustom(
      title: "Follow up action",
      profile: profile,
      selectedValue: profile.followUpAction,
      items: [
        ItemDropdown(label: "None (Unassigned)", value: "unassigned"),
        ItemDropdown(
            label: "List on Transfermarket", value: "sendToTransfermarket"),
        ItemDropdown(
            label: "Send to Transferlist", value: "sendToTransferlist"),
        ItemDropdown(label: "Store in Club", value: "sendToClub")
      ],
    );
  }

  reload(Profile p) {
    profile = p;
    _buyPriceController.text = p.buyPrice != null ? p.buyPrice.toString() : "";
    _resetPriceController.text =
        p.resetPrice != null ? p.resetPrice.toString() : "";
    _sellPriceController.text =
        p.sellPrice != null ? p.sellPrice.toString() : "";
    _durationController.text =
        p.listDuration != null ? p.listDuration.toString() : "";
    _nbCardController.text = p.cardCount.toString();
    checkCheap.reload(p.cheapCard);
    checkLast.reload(p.lastCard);
    followupAction.selectedValue = p.followUpAction;
  }

  String? save(Profile profile) {
    profile.buyPrice = _buyPriceController.value.text.isNotEmpty
        ? int.parse(_buyPriceController.value.text.toString())
        : null;
    profile.cardCount = _nbCardController.value.text.isNotEmpty
        ? int.parse(_nbCardController.value.text.toString())
        : 10;
    profile.resetPrice = _resetPriceController.value.text.isNotEmpty
        ? int.parse(_resetPriceController.value.text.toString())
        : null;
    profile.sellPrice = _sellPriceController.value.text.isNotEmpty
        ? _sellPriceController.value.text.toString()
        : null;
    profile.listDuration = _durationController.value.text.isNotEmpty
        ? _durationController.value.text.toString()
        : "1H";
    profile.followUpAction = followupAction.selectedValue;
    profile.cheapCard = checkCheap.value;
    profile.lastCard = checkLast.value;

    if (profile.followUpAction == null) {
      return "Please choose 'Follow Up' Action";
    }

    if (!profile.listDuration!.contains('H')) {
      return "Time interval (H) is missing at 'List Duration'";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFieldCustom(
                  title: "Buy price", controller: _buyPriceController),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                  title: "Nb. card to buy", controller: _nbCardController),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                  title: "Reset price", controller: _resetPriceController),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this.followupAction,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Sell price",
                controller: _sellPriceController,
                subtitle: "Ranged or single value (eg. 1500 or 1500-2000)",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "List duration",
                controller: _durationController,
                subtitle: "List duration when Listing (eg. 1H)",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: checkLast,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: checkCheap,
            ),
          ],
        ));
  }
}

class SearchPanel extends StatelessWidget {
  late Profile profile;
  TextEditingController _minRatingController = TextEditingController();
  TextEditingController _maxRatingController = TextEditingController();
  TextEditingController _waitTimeController = TextEditingController();
  TextEditingController _pauseController = TextEditingController();
  TextEditingController _pauseForController = TextEditingController();
  TextEditingController _stopAfterController = TextEditingController();

  SearchPanel(Profile p) {
    this.profile = p;
    _minRatingController.text =
        p.minRating != null ? p.minRating.toString() : "";
    _maxRatingController.text =
        p.maxRating != null ? p.maxRating.toString() : "";
    _waitTimeController.text = p.waitTime != null ? p.waitTime.toString() : "";
    _pauseController.text =
        p.cycleAmount != null ? p.cycleAmount.toString() : "";
    _pauseForController.text = p.pauseFor != null ? p.pauseFor.toString() : "";
    _stopAfterController.text =
        p.stopAfter != null ? p.stopAfter.toString() : "";
  }

  String? save(Profile profile) {
    profile.minRating = _minRatingController.value.text.isNotEmpty
        ? int.parse(_minRatingController.value.text.toString())
        : null;
    profile.maxRating = _maxRatingController.value.text.isNotEmpty
        ? int.parse(_maxRatingController.value.text.toString())
        : null;
    profile.waitTime = _waitTimeController.value.text.isNotEmpty
        ? _waitTimeController.value.text.toString()
        : profile.waitTime;
    profile.cycleAmount = _pauseController.value.text.isNotEmpty
        ? _pauseController.value.text.toString()
        : profile.cycleAmount;
    profile.pauseFor = _pauseForController.value.text.isNotEmpty
        ? _pauseForController.value.text.toString().toUpperCase()
        : profile.pauseFor;
    profile.stopAfter = _stopAfterController.value.text.isNotEmpty
        ? _stopAfterController.value.text.toString()
        : profile.stopAfter;

    if (!(profile.pauseFor!.contains('H') ||
        profile.pauseFor!.contains('S') ||
        profile.pauseFor!.contains('M'))) {
      return "Time interval (S/M/H) is missing at 'Pause for' ";
    }

    if (!(profile.stopAfter!.contains('H') ||
        profile.stopAfter!.contains('S') ||
        profile.stopAfter!.contains('M'))) {
      return "Time interval (S/M/H) is missing at 'Stop after' ";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFieldCustom(
                title: "Min rating",
                controller: _minRatingController,
                subtitle: "Minimum Player Rating",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Max rating",
                controller: _maxRatingController,
                subtitle: "Maximum Player Rating",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Wait time",
                controller: _waitTimeController,
                subtitle: "Random millisecond rage (eg. 7000-15000)",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Pause cycle",
                controller: _pauseController,
                subtitle:
                    "No. of searches performed before triggering Pause (eg. 10-15)",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Pause for",
                controller: _pauseForController,
                subtitle:
                    "S for Seconds, M for Minutes, H for hours (Eg. 5-8S)",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Stop after",
                controller: _stopAfterController,
                subtitle:
                    "S for Seconds, M for Minutes, H for hours (Eg. 1-2H)",
              ),
            ),
          ],
        ));
  }
}

class MiscPanel extends StatelessWidget {
  late Profile profile;

  TextEditingController _clearSoldController = TextEditingController();
  TextEditingController _nbUnassignedControler = TextEditingController();
  TextEditingController _delayBuyNowController = TextEditingController();
  late CheckBoxCustom relistUnsold;
  late CheckBoxCustom extendNumber;
  late CheckBoxCustom incrementMinBin;
  late CheckBoxCustom delay;

  MiscPanel(Profile p) {
    this.profile = p;

    this.relistUnsold = CheckBoxCustom(
      title: "Relist unsold items",
      value: profile.unsoldItems,
    );

    this.extendNumber = CheckBoxCustom(
      title: "Extend number of listing items",
      value: profile.activeTransfers,
      subtitle: "Active Transfer number is set to 100",
    );

    this.incrementMinBin = CheckBoxCustom(
      title: "Increment min Buy instead of min Bid",
      value: profile.incrementMinBin,
    );
    this.delay = CheckBoxCustom(
      title: "Add Delay after a card was bought",
      value: profile.delayBuyNow,
    );
    _nbUnassignedControler.text =
        p.unassignedValue != null ? p.unassignedValue.toString() : "";
    _clearSoldController.text =
        p.minDeleteCount != null ? p.minDeleteCount.toString() : "";
    _delayBuyNowController.text =
        p.delayBuyNowTime != null ? p.delayBuyNowTime.toString() : "";
  }

  String? save(Profile profile) {
    profile.unsoldItems = relistUnsold.value;
    profile.activeTransfers = extendNumber.value;
    profile.delayBuyNow = delay.value;
    profile.incrementMinBin = incrementMinBin.value;
    profile.unassignedValue = _nbUnassignedControler.value.text.isNotEmpty
        ? _nbUnassignedControler.value.text.toString()
        : profile.unassignedValue;
    profile.minDeleteCount = _clearSoldController.value.text.isNotEmpty
        ? _clearSoldController.value.text.toString()
        : profile.minDeleteCount;
    profile.delayBuyNowTime = _delayBuyNowController.value.text.isNotEmpty
        ? _delayBuyNowController.value.text.toString()
        : profile.delayBuyNowTime;

    if (!(profile.delayBuyNowTime!.contains('H') ||
            profile.delayBuyNowTime!.contains('S') ||
            profile.delayBuyNowTime!.contains('M')) &&
        profile.delayBuyNow) {
      return "Time interval (S/M/H) is missing at 'Buy Now delay' ";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: this.relistUnsold,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this.extendNumber,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this.incrementMinBin,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Number of Unassigned Items",
                controller: _nbUnassignedControler,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Clear sold count",
                controller: _clearSoldController,
                subtitle: "Clear sold Items when a specific count reached",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this.delay,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                title: "Buy Now Delay",
                controller: _delayBuyNowController,
                subtitle: "S for Seconds, M for Minutes, H for hours Eg. 1S",
              ),
            ),
          ],
        ));
  }
}

class Notificationpanel extends StatelessWidget {
  late Profile profile;
  TextEditingController _discordController = TextEditingController();
  late CheckBoxCustom _cardBought;
  late CheckBoxCustom _cardAppeared;
  late CheckBoxCustom _filterSwitched;
  late CheckBoxCustom _botStart;
  late CheckBoxCustom _botStop;
  late CheckBoxCustom _botPause;
  late CheckBoxCustom _multiplePage;

  Notificationpanel(Profile p) {
    this.profile = p;
    _discordController.text =
        p.discordWebhookLink != null ? p.discordWebhookLink.toString() : "";
    this._cardBought = CheckBoxCustom(
      title: "Card bought",
      subtitle: "Notify when card been bought.",
      value: profile.notifyCardBought,
    );
    this._cardAppeared = CheckBoxCustom(
      title: "Card appeared",
      subtitle: "Notify when a card was visible but couldn't be bought.",
      value: profile.notifyCardVisible,
    );

    this._filterSwitched = CheckBoxCustom(
      title: "Filter switched",
      subtitle: "Notify when a the filter hase been swicthed.",
      value: profile.notifyFilterSwitch,
    );

    this._botStart = CheckBoxCustom(
      title: "Bot start",
      subtitle: "Notify when Bot started.",
      value: profile.notifyBotStarted,
    );
    this._botPause = CheckBoxCustom(
      title: "Bot paused",
      subtitle: "Notify when Bot paused.",
      value: profile.notifyBotPaused,
    );
    this._botStop = CheckBoxCustom(
      title: "Bot stopped",
      subtitle: "Notify when Bot stopped.",
      value: profile.notifyBotStopped,
    );
    this._multiplePage = CheckBoxCustom(
      title: "Search has multiple Pages",
      subtitle: "Notify when a search has more than Page",
      value: profile.notifyMorePages,
    );
  }

  save(Profile profile) {
    profile.notifyCardBought = _cardBought.value;
    profile.notifyBotPaused = _botPause.value;
    profile.notifyBotStopped = _botStop.value;
    profile.notifyBotStarted = _botStart.value;
    profile.notifyCardVisible = _cardAppeared.value;
    profile.notifyFilterSwitch = _filterSwitched.value;
    profile.notifyMorePages = _multiplePage.value;
    profile.discordWebhookLink = _discordController.value.text.isNotEmpty
        ? _discordController.value.text.toString()
        : profile.discordWebhookLink;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextFieldCustom(
                title: "Discord Webhooklink",
                controller: _discordController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._cardBought,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._cardAppeared,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._filterSwitched,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._botStart,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: _botPause,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._botStop,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._multiplePage,
            ),
          ],
        ));
  }
}

class FilterPanel extends StatelessWidget {
  late Profile profile;

  TextEditingController _nbSearchFilterControler = TextEditingController();
  late CheckBoxCustom _switchFilter;
  late DropDownCustom _filterList;

  FilterPanel(Profile p, List<String>? filterList) {
    this.profile = p;

    this._switchFilter = CheckBoxCustom(
      title: "Switch Filter",
      value: profile.filterSwitch,
    );
    List<ItemDropdown> items = List.empty(growable: true);
    if (filterList != null) {
      for (String s in filterList) {
        var item = ItemDropdown(label: s, value: s);
        items.add(item);
      }
    }

    this._filterList = DropDownCustom(
      title: "Filter",
      selectedValue: profile.filter,
      items: items,
    );
    _nbSearchFilterControler.text =
        p.filterSearchAmount != null ? p.filterSearchAmount.toString() : "";
  }

  save(Profile profile) {
    profile.filterSwitch = _switchFilter.value;
    profile.filter = _filterList.selectedValue;
    profile.filterSearchAmount = _nbSearchFilterControler.value.text.isNotEmpty
        ? _nbSearchFilterControler.value.text.toString()
        : profile.filterSearchAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: this._filterList,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: this._switchFilter,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: TextFieldCustom(
                controller: _nbSearchFilterControler,
                title: "Number of searches for each filter",
                subtitle:
                    "Count of searches performed before switching to another filter",
              ),
            ),
          ],
        ));
  }
}

class TextFieldCustom extends StatelessWidget {
  TextFieldCustom(
      {super.key,
      required this.title,
      required this.controller,
      this.subtitle = null});

  final String title;
  String? subtitle;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  color: const Color(0xFF00FFFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle != null
                  ? Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Container()
            ],
          ),
        )),
        BeautyTextfield(
            width: 200,
            height: 60,
            placeholder: "",
            inputType: TextInputType.text,
            accentColor: const Color(0xFF202230),
            fontStyle: FontStyle.normal,
            wordSpacing: 0,
            //Not Focused Color
            textColor: Colors.white,
            //Text Color
            backgroundColor: const Color(0xFF202230),
            //Not Focused Color
            controller: controller),
      ],
    );
  }
}

class CheckBoxCustom extends StatefulWidget {
  CheckBoxCustom(
      {super.key,
      required this.title,
      required this.value,
      this.profile = null,
      this.subtitle = null});

  final String title;
  final Profile? profile;
  String? subtitle;
  bool value;

  reload(value) {
    this.value = value;
  }

  @override
  _CheckBoxCustomState createState() => _CheckBoxCustomState();
}

class _CheckBoxCustomState extends State<CheckBoxCustom> {
  bool shouldCheck = false;

  @override
  void initState() {
    super.initState();
    shouldCheck = widget.value;
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16.0,
                  color: const Color(0xFF00FFFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              widget.subtitle != null
                  ? Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        CustomCheckBox(
          value: shouldCheck,
          shouldShowBorder: true,
          borderColor: const Color(0xFF95A3BC),
          uncheckedFillColor: const Color(0xFF202230),
          checkedIconColor: const Color(0xffee786c),
          checkedFillColor: const Color(0xFF202230),
          uncheckedIconColor: const Color(0xFF202230),
          borderRadius: 5,
          borderWidth: 1,
          checkBoxSize: 32,
          onChanged: (val) {
            setState(() {
              shouldCheck = val;
              widget.value = val;
            });
          },
        ),
      ],
    );
  }
}

class DropDownCustom extends StatefulWidget {
  DropDownCustom(
      {super.key,
      required this.title,
      required this.selectedValue,
      this.profile = null,
      this.displayTitle = true,
      this.items = null,
      this.subtitle = null,
      this.onValueChanged = null});

  final String title;
  final Profile? profile;
  final bool displayTitle;
  List<ItemDropdown>? items;
  String? subtitle;
  String? selectedValue;
  final OnValueChanged? onValueChanged;

  @override
  _DropDownCustomState createState() => _DropDownCustomState();
}

class _DropDownCustomState extends State<DropDownCustom> {
  String? selectedValue = "";

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        widget.displayTitle
            ? Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: const Color(0xFF00FFFF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    widget.subtitle != null
                        ? Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Container()
                  ],
                ),
              )
            : Container(),
        DropdownButtonHideUnderline(
            child: DropdownButton2(
          isExpanded: true,
          hint: Row(
            children: const [
              Expanded(
                child: Text(
                  'Select Item',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.normal,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: widget.items!
              .map((item) => DropdownMenuItem<String>(
                    value: item.value,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
              widget.selectedValue = value as String;
              if (widget.onValueChanged != null) {
                widget.onValueChanged!(selectedValue!);
              }
            });
          },
          icon: const Icon(
            Icons.arrow_forward_ios_outlined,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.grey,
          buttonHeight: 60,
          buttonWidth: widget.displayTitle
              ? 200
              : (MediaQuery.of(context).size.width - 20),
          buttonPadding: const EdgeInsets.only(left: 14, right: 14),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black26,
            ),
            color: const Color(0xFF202230),
          ),
          itemHeight: 60,
          dropdownMaxHeight: 400,
          dropdownWidth: widget.displayTitle
              ? 200
              : (MediaQuery.of(context).size.width - 20),
          dropdownPadding: null,
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF202230),
          ),
          dropdownElevation: 8,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6,
          scrollbarAlwaysShow: true,
          offset: const Offset(0, -5),
        ))
      ],
    );
  }
}
