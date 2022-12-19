import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:snipe59/client/FutsovereignBloc.dart';
import 'package:snipe59/client/FutsovereignEvent.dart';
import 'package:snipe59/client/FutsovereignState.dart';
import 'dart:developer' as developer;

import 'package:snipe59/entity/FutsovereignItem.dart';

class PricesView extends StatefulWidget {
  const PricesView({Key? key, required this.console}) : super(key: key);

  final String console;

  @override
  State<PricesView> createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
  late FutsovereignBloc _futsovereignBloc;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futsovereignBloc = context.read<FutsovereignBloc>();
    refreshPrice();
  }

  void _onClearTapped() {
    _textController.text = '';
    _futsovereignBloc.add(FilterPlayer(text: '', console: this.widget.console));
  }

  Future<bool> refreshPrice() async {
    _textController.text = '';
    _futsovereignBloc.emit(FutsovereignStateLoading());
    await Future.delayed(const Duration(seconds: 1));
    _futsovereignBloc.add(PriceRequested(console: this.widget.console));
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/SnipeLogo.png",
          width: 250,
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: TextField(
            controller: _textController,
            style: TextStyle(color: Colors.white),
            autocorrect: false,
            onChanged: (text) {
              _futsovereignBloc.add(
                FilterPlayer(text: text, console: this.widget.console),
              );
            },
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: _onClearTapped,
                child: const Icon(Icons.clear, color: const Color(0xFF00FFFF)),
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white38),
              hintText: 'Find player by name',
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 10,
          endIndent: 10,
          color: Colors.white,
        ),
        BlocConsumer<FutsovereignBloc, FutsovereignState>(
          listener: (context, state) {
            developer.log(state.toString(), name: 'Snipe59');
          },
          builder: (context, state) {
            if (state is FutsovereignStateLoading) {
              return Expanded(
                  child:
                      const Center(child: const CircularProgressIndicator()));
            }
            if (state is FutsovereignStateError) {
              return Text(state.error);
            }
            if (state is FutsovereignStateSuccess) {
              return Expanded(
                  child: RefreshIndicator(
                      child: state.items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No Results',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ))
                          : _PriceResults(
                              items: state.items,
                              console: this.widget.console,
                            ),
                      onRefresh: refreshPrice));
            }
            return const Center(child: const CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}

class _PriceResults extends StatelessWidget {
  const _PriceResults({Key? key, required this.items, required this.console})
      : super(key: key);

  final List<FutsovereignItem> items;
  final String console;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _PriceResultsItem(item: items[index], console: console);
      },
    );
  }
}

class _PriceResultsItem extends StatelessWidget {
  const _PriceResultsItem({Key? key, required this.item, required this.console})
      : super(key: key);

  final FutsovereignItem item;
  final String console;

  String formatProfits() {
    if (this.console == "ps") {
      var _formattedNumber =
          NumberFormat.compact(locale: "en_GB").format(item.currentPricePs4);
      return _formattedNumber;
    }
    var _formattedNumber =
        NumberFormat.compact(locale: "en_GB").format(item.currentPriceXbox);
    return _formattedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Price",
              style: TextStyle(color: const Color(0xFF95A3BC), fontSize: 12),
            ),
            Text(
              formatProfits(),
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Image.network(
            "https://cdn.futbin.com/content/fifa23/img/players/" +
                item.playerExternalId! +
                ".png?v=23",
            errorBuilder: (context, error, stackTrace) => Image.network(
              "https://cdn.futbin.com/content/fifa23/img/players/p" +
                  item.playerExternalId! +
                  ".png?v=23",
            ),
          )),
      title: Text(
        item.playerFullName! + " (" + item.position! + ")",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        item.rarityLabel == null
            ? "Rarity " + item.playerCardTypeId.toString()
            : item.rarityLabel!,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
