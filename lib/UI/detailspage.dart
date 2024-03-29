import 'dart:convert';
import 'package:crypto_app/Functions/premium.dart';
import 'package:crypto_app/UI/UI%20helpers/alerts.dart';
import 'package:crypto_app/UI/get_premium.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../Functions/database.dart';
import '../Functions/detailspageassist.dart';
import '../main.dart';
import 'UI helpers/buttons.dart';
import 'UI helpers/graphics.dart';
import 'UI helpers/style.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import 'information.dart';
import 'login_page.dart';

List<String> types = <String> ["","(in K)","(in M)"];
List<String> sub = <String> ["in units", "in thousands", "in millions"];
List<double> numbers = <double> [1, 1000, 1000000];
List<Widget> periods = <Widget> [Text("Day"), Text("Week"), Text("Month"), Text("Year"), Text("YTD")];
List<Widget> periodsVol = <Widget> [Text("Week"), Text("Month"), Text("Year"), Text("YTD")];
List<Widget> periodsScore = <Widget> [Text("Week"), Text("Month"), Text("Year")];
List<Widget> periodsPredictions = <Widget> [Text("Month"), Text("Signals")];


class DetailsPage extends StatefulWidget {
  final int passedIndex;

  const DetailsPage({Key? key, required this.passedIndex}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> with TickerProviderStateMixin  {
  late TrackballBehavior _trackballBehavior;
  late TrackballBehavior _trackballBehavior2;
  late TrackballBehavior _trackballBehavior3;
  late TrackballBehavior _trackballBehavior4;
  late List<List<PriceData>> _cryptoData = [];
  late BannerAd _bannerAd;
  late BannerAd _endBannerAd;
  String type = "", subtitle = "in units";
  List<bool> isSelected = [false, false, true, false, false];
  List<bool> isSelectedVol = [false, true, false, false];
  List<bool> isSelectedScore = [true, false, false];
  List<bool> isSelectedMarketview = [true, false, false];
  List<bool> isSelectedPredictions = [true, false];
  int selectedIdx = 2; int selectedIdxVol = 1; int selectedIdxScore = 0; int selectedIdxMarketview = 0; int selectedIdxPredictions = 0;
  final ValueNotifier<String> _priceText = ValueNotifier<String>("");

  Color twentyFourColor = Colors.white; Color scoreColor = Colors.white;
  Color predictionColor = Colors.white; Color tweetsColor = Colors.white;
  Color commitsColor = Colors.white; Color marketViewColor = Colors.white;

  Map<String, String> inputData = {};
  double percentageTw = 0; double percentageCm = 0;
  List<double> scoreGge = [], marketviewGge = [];
  String predUrl = "https://i.postimg.cc/tgYj7XSn/bull-v2-offset.png";
  String marketUrl = "https://i.postimg.cc/HkYX7KCC/smiley-v2.png";
  List<String> baTw = []; List<String> baCm = []; List<String> stars = [];
  double dTwH = 0; double dTwL = 0; double dPrice = 0; bool isStarred = false; bool canSee = false; bool hasAlert = false;

  bool gotData = false; late TabController _tabController;


  @override
  initState() {
    super.initState();
    _priceText.value = "${TopCryptos[widget.passedIndex].current_price};Now";
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<bool> waitForData() async {
    if (gotData == true) {
      return true;
    }
    _cryptoData = await getChartData();
    gotData = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Theme.of(context).colorScheme.secondary,
      shouldAlwaysShow: true,
      tooltipSettings: InteractiveTooltip(
        enable: false,
        format: 'point.y;point.x',
      ),
    );
    _trackballBehavior2 = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Theme.of(context).colorScheme.secondary,
      shouldAlwaysShow: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Theme.of(context).colorScheme.primary,
        // color: Colors.transparent,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        format: 'point.y  (point.x)',
      ),
    );
    _trackballBehavior3 = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Theme.of(context).colorScheme.secondary,
      shouldAlwaysShow: true,
      hideDelay: 2,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Theme.of(context).colorScheme.primary,
        // color: Colors.transparent,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        format: '\$point.y  (point.x)',
      ),
    );
    _trackballBehavior4 = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Theme.of(context).colorScheme.secondary,
      shouldAlwaysShow: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Theme.of(context).colorScheme.primary,
        // color: Colors.transparent,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        format: '\$point.y  (point.x)',
      ),
    );


    final localStorage = GetStorage();
    twentyFourColor = getTextColor(TopCryptos[widget.passedIndex].price_change_precentage_24h);
    scoreColor = getTextColor(TopCryptos[widget.passedIndex].score);
    predictionColor = cGreen;
    tweetsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].tweets);
    commitsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].commits);
    marketViewColor = getTextColor(TopCryptos[widget.passedIndex].marketView);

    inputData['crypto'] = TopCryptos[widget.passedIndex].id;

    percentageTw =
    double.parse(TopCryptos[widget.passedIndex].tweets) / 100.abs() > 1
        ? 1
        : double.parse(TopCryptos[widget.passedIndex].tweets) / 100.abs();
    percentageCm =
    double.parse(TopCryptos[widget.passedIndex].commits) / 100.abs() > 1
        ? 1
        : double.parse(TopCryptos[widget.passedIndex].commits) / 100.abs();
    //make sure they're not negative
    percentageTw = percentageTw.abs();
    percentageCm = percentageCm.abs();

    scoreGge = updateMetrics(TopCryptos[widget.passedIndex].score);
    marketviewGge = updateMetrics(TopCryptos[widget.passedIndex].marketView);
    baTw = updateStartEnd(TopCryptos[widget.passedIndex].tweets);
    baCm = updateStartEnd(TopCryptos[widget.passedIndex].commits);

    dTwH = double.parse(TopCryptos[widget.passedIndex].high_24h);
    dTwL = double.parse(TopCryptos[widget.passedIndex].low_24h);
    dPrice = double.parse(TopCryptos[widget.passedIndex].current_price);

    if (dPrice > dTwH) {
      dTwH = dPrice;
    }
    else if (dPrice < dTwL) {
      dTwL = dPrice;
    }
    if (dTwL == dTwH) {
      dTwL = dTwH-(dTwH*0.01);
    }

    if (TopCryptos[widget.passedIndex].prediction != null) {
      if (TopCryptos[widget.passedIndex].prediction.contains("Bearish")) {
        predictionColor = cRed;
        predUrl = "https://i.postimg.cc/BvkGKdkY/bear-v2-offset.png";
      }
      if (TopCryptos[widget.passedIndex].prediction.contains("Neutral")) {
        predUrl = "";
      }
    }

    if (TopCryptos[widget.passedIndex].marketView.contains("-")) {
      marketUrl = "https://i.postimg.cc/T13XqSpF/sad.png";
      marketViewColor = cRed;
    }


    stars = localStorage.read("starred_coins")?.cast<String>() ?? [];
    if (stars.contains(TopCryptos[widget.passedIndex].id)) {
      isStarred = true;
    }
    else {
      isStarred = false;
    }

    canSee = userLimitAvailable(widget.passedIndex);
    refreshAlerts();
    hasAlert = alerts.containsKey(CryptosList[widget.passedIndex]);

    setState(() {

    });

    return FutureBuilder(
        future: waitForData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return detailsPageScaffold(
              <Widget> [
                SizedBox(height: 350),
                Column(
                  children: const <Widget> [
                    Text(
                      "Retro-Score History",
                      style: TextStyle(
                        height: 2, fontSize: 20, fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 265),
                  ],
                ),
                Column(
                  children: const <Widget> [
                    Text(
                      "MarketView History",
                      style: TextStyle(
                        height: 2, fontSize: 20, fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 265),
                  ],
                ),
                SizedBox(height: 265),
                SizedBox(height: 265),
              ],
            );
          }
          return detailsPageScaffold(
            <Widget> [
              cryptoPriceChart(_trackballBehavior, _cryptoData[selectedIdx], false, screenWidth * 0.93),
              historyChart("Retro-Score", cryptoAnalChart(_trackballBehavior2, _cryptoData[selectedIdxScore+9], false, screenWidth * 0.93, null, null), selectedIdxScore),
              historyChart("MarketView", cryptoAnalChart(_trackballBehavior2, _cryptoData[selectedIdxMarketview+12], false, screenWidth * 0.93, cGreen, cRed), selectedIdxMarketview),
              cryptoPredictionHistoryChart(_trackballBehavior3, _cryptoData[2], false, screenWidth * 0.93, _cryptoData[15], selectedIdxPredictions),
              cryptoInfoChart("Volume", _trackballBehavior4, _cryptoData[selectedIdxVol+5], false, screenWidth * 0.93),
            ]
          );
        });
  }

  Scaffold detailsPageScaffold(List<Widget> widgets) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TopCryptos[widget.passedIndex].id),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 35,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  refreshAlerts();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => alertPage(context, inputData),
                  ).then((_)=>setState((){}));
                },
                child: Icon(
                  hasAlert ? Icons.notifications_active : Icons.notification_add_outlined,
                  size: 26.0,
                ),
              )
          ),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  stars = localStorage.read("starred_coins")?.cast<String>() ?? [];
                  if (stars.contains(TopCryptos[widget.passedIndex].id)) {
                    stars.remove(TopCryptos[widget.passedIndex].id);
                    Sort["Starred"]?.remove(widget.passedIndex);
                  }
                  else {
                    stars.add(TopCryptos[widget.passedIndex].id);
                    Sort["Starred"]?.add(widget.passedIndex);
                  }
                  localStorage.write("starred_coins", stars);

                  setState(() {});
                },
                child: Icon(
                  isStarred ? Icons.star : Icons.star_border_outlined,
                  size: 26.0,
                ),
              )
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  height: 530,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Row(
                        children: <Widget> [
                          CircleAvatar(
                            backgroundImage: NetworkImage(TopCryptos[widget.passedIndex].image),
                            backgroundColor: Colors.transparent,
                            radius: 23,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 200,
                                child: Text(
                                  TopCryptos[widget.passedIndex].id.capitalizeFirst ?? TopCryptos[widget.passedIndex].id,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                  softWrap: false,
                                ),
                              ),
                              Text(
                                TopCryptos[widget.passedIndex].symbol.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.left,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                      ValueListenableBuilder<String>(
                          valueListenable: _priceText,
                          builder: (context, value, child) {
                            return RichText(
                              textAlign: TextAlign.left,
                              softWrap: false,
                              text: TextSpan(
                                text: " \$${value.substring(0, value.indexOf(";"))} USD ",
                                style: TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 1.5,
                                  height: 2,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: value.substring(value.indexOf(";")+1), style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          }
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? " -" : " +"}",
                            style: TextStyle(
                              fontSize: 16,
                              color: TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          NumberSlideAnimation(
                            number: TopCryptos[widget.passedIndex].price_change_precentage_24h.substring(TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? 1 : 0, TopCryptos[widget.passedIndex].price_change_precentage_24h.indexOf(".")),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.bounceIn,
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                            ),
                          ),
                          Text(
                            ".",
                            style: TextStyle(
                              fontSize: 16,
                              color: TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                            ),
                          ),
                          Flexible(
                            child: NumberSlideAnimation(
                              number: TopCryptos[widget.passedIndex].price_change_precentage_24h.substring(TopCryptos[widget.passedIndex].price_change_precentage_24h.indexOf(".")+1, TopCryptos[widget.passedIndex].price_change_precentage_24h.length),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.bounceIn,
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                              ),
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              fontSize: 16,
                              color: TopCryptos[widget.passedIndex].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: widgets[0],
                      ),
                      Center(
                        child: ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              // The button that is tapped is set to true, and the others to false.
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == index;
                                if (isSelected[i] == true) {
                                  selectedIdx = i;
                                }
                              }
                            });
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          selectedBorderColor: Colors.transparent,
                          selectedColor: Colors.black,
                          fillColor: Colors.white,
                          // color: Colors.white,
                          borderWidth: 2,
                          constraints: BoxConstraints(
                            minHeight: 40.0,
                            minWidth: screenWidth * 0.15,
                          ),
                          isSelected: isSelected,
                          children: periods,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenHeight*0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Text(
                        "Range (24h)",
                        style: TextStyle(
                          height: 1, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                      ),
                      SfLinearGauge(
                        minimum: dTwL,
                        maximum: dTwH,
                        maximumLabels: 1,
                        animateAxis: true,
                        axisTrackStyle: const LinearAxisTrackStyle(
                          color: Colors.transparent,
                        ),
                        ranges: <LinearGaugeRange>[
                          LinearGaugeRange(
                              startValue: dTwL,
                              endValue: dPrice,
                              position: LinearElementPosition.outside,
                              color: cRed),
                          LinearGaugeRange(
                              startValue: dPrice,
                              endValue: dTwH,
                              position: LinearElementPosition.outside,
                              color: cGreen),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: dPrice,
                            animationType: LinearAnimationType.ease,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  height: 255,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Row(
                        children: <Widget> [
                          const Text(
                            "Market Stats",
                            style: TextStyle(
                              height: 4, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      )
                                  ),
                                  builder: (context) => Center(
                                    child: marketStatsInfo(Theme.of(context).colorScheme.secondary),
                                  )
                              );
                            },
                            icon: const Icon(Icons.info_outlined),
                            iconSize: 15,
                            padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(maxHeight: 16, maxWidth: 16),
                          ),
                        ],
                      ),
                      Table(
                        // border: TableBorder.all(),
                        columnWidths: <int, TableColumnWidth>{
                          0: FixedColumnWidth(screenWidth * 0.95),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          infoRow("Market cap", "\$${TopCryptos[widget.passedIndex].market_cap} USD", Theme.of(context).colorScheme.secondary,),
                          infoRow("Volume (24h)", "\$${TopCryptos[widget.passedIndex].total_volume} USD", Theme.of(context).colorScheme.secondary,),
                          infoRow("Total supply", "${TopCryptos[widget.passedIndex].total_supply} ${TopCryptos[widget.passedIndex].symbol.toUpperCase()}", Theme.of(context).colorScheme.secondary,),
                          infoRow("All-time high", "\$${TopCryptos[widget.passedIndex].ath} USD", Theme.of(context).colorScheme.secondary,),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 25),
                          child: TextButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse("https://www.coingecko.com/"));
                            },
                            child: Text(
                              "powered by CoinGecko",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: canSee ? 450 : 355,
                child: TabBarView(
                  physics: canSee ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                  controller: _tabController,
                    children: [
                      Container(
                        width: screenWidth * 0.95,
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start, //Center Row contents horizontally,
                            children: <Widget>[
                              const Text(
                                " Analysis",
                                style: TextStyle(
                                  height: 2, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                              ),
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          )
                                      ),
                                      builder: (context) => Center(
                                        child: analysisInfo(Theme.of(context).colorScheme.secondary),
                                      )
                                  );
                                },
                                icon: const Icon(Icons.info_outlined),
                                iconSize: 15,
                                padding: EdgeInsets.all(5),
                                constraints: BoxConstraints(maxHeight: 28, maxWidth: 16),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: 5
                          ),
                          if (canSee == true)
                            Table(
                              // border: TableBorder.all(),
                              columnWidths: <int, TableColumnWidth>{
                                0: FixedColumnWidth(screenWidth * 0.95),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                TableRow(
                                  children: <Widget> [
                                    Container(
                                        margin: const EdgeInsets.all(1.0),
                                        padding: const EdgeInsets.all(3.0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        height: 100,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: EdgeInsets.zero,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              _tabController.index = 1;
                                            },
                                            child: Column(
                                              children: <Widget> [
                                                Row(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: screenWidth*0.431,
                                                      child: Row(
                                                          children: <Widget> [
                                                            Align(
                                                              alignment: Alignment.bottomCenter,
                                                              child: Image.network(
                                                                'https://i.postimg.cc/6QCj5gVx/R-for-Retrospect-in-App.png',
                                                                fit: BoxFit.cover,
                                                                height: 22,
                                                              ),
                                                            ),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text: "etro",
                                                                    style: blueRetroTitleStyle,
                                                                    children: <TextSpan>[
                                                                      TextSpan(text:"-Score©", style: TextStyle(
                                                                        height: 2,
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Theme.of(context).colorScheme.secondary,
                                                                      )),
                                                                    ]
                                                                )
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    SizedBox(width:screenWidth*0.161),
                                                    SizedBox(
                                                      width: screenWidth*0.323,
                                                      child: Text(
                                                        "${double.parse(TopCryptos[widget.passedIndex].score).toStringAsFixed(3)}",
                                                        textAlign: TextAlign.right,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: scoreColor,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                analysisGauge(scoreGge[0], scoreGge[1], scoreGge[2], scoreGge[3], Theme.of(context).colorScheme.secondary),
                                              ],
                                            )
                                        )
                                    ),

                                  ],
                                ),
                                TableRow(
                                  children: <Widget> [
                                    Container(
                                        margin: const EdgeInsets.all(1.0),
                                        padding: const EdgeInsets.all(3.0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        height: 100,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: EdgeInsets.zero,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              _tabController.index = 2;
                                            },
                                          child: Column(
                                            children: <Widget> [
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: screenWidth*0.431,
                                                    child: RichText(
                                                        text: TextSpan(
                                                            text: "Market ",
                                                            style: TextStyle(
                                                              height: 2,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Theme.of(context).colorScheme.secondary,
                                                            ),
                                                            children: <TextSpan>[
                                                              TextSpan(text:"View ", style: blueTitleStyle),
                                                              TextSpan(text:"score: "),
                                                            ]
                                                        )
                                                    ),
                                                  ),
                                                  SizedBox(width:screenWidth*0.161),
                                                  SizedBox(
                                                    width: screenWidth*0.323,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget> [
                                                        Image.network(
                                                          marketUrl,
                                                          height: 15,
                                                        ),
                                                        Text(
                                                          " ${double.parse(TopCryptos[widget.passedIndex].marketView).toStringAsFixed(3)}",
                                                          textAlign: TextAlign.right,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: marketViewColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              analysisGauge(marketviewGge[0], marketviewGge[1], marketviewGge[2], marketviewGge[3], Theme.of(context).colorScheme.secondary),
                                            ],
                                          )
                                        ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: <Widget> [
                                    Container(
                                        margin: const EdgeInsets.all(1.0),
                                        padding: const EdgeInsets.all(3.0),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        height: 47,
                                        child: Column(
                                          children: <Widget> [
                                            Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: screenWidth*0.431,
                                                  child: const Text(
                                                    "Prediction (24h)",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      height: 2,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width:screenWidth*0.134),
                                                SizedBox(
                                                  width: screenWidth*0.359,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: <Widget> [
                                                      Align(
                                                        alignment: Alignment.bottomCenter,
                                                        child: SizedBox(
                                                          height: 30,
                                                          width: 20,
                                                          child: Image.network(
                                                            predUrl,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        " ${TopCryptos[widget.passedIndex].prediction}",
                                                        textAlign: TextAlign.right,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          height: 2,
                                                          color: predictionColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          if (canSee == false)
                            Container(
                              width: screenWidth * 0.95,
                              height: 280,
                              child: Column(
                                children: <Widget> [
                                  SizedBox(height: 20),
                                  Image.network(
                                    "https://i.postimg.cc/VkpYychz/Lock.png",
                                    height:60,
                                  ),
                                  const Text(
                                    "You have reached your daily limit!",
                                    style: TextStyle(
                                      height: 3,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    !loggedIn ? "Join Retro to get more cryptocurrency analysis! It's free. \n\n\n\n You still have access to:" : "Get Premium to access more analysis!\n\nYou still have access to:",
                                    style: TextStyle(
                                      height: 1,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.8,
                                    height: 30,
                                    child: Text(
                                      "${localStorage.read("used")}",
                                      style: const TextStyle(
                                        height: 1,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    height: 30,
                                    width: 135,
                                    child: OutlinedButton(
                                        onPressed: () async {
                                          if (loggedIn) {
                                            bool worked = await redeemCreditsDetails(widget.passedIndex ?? 0);

                                            if (worked) {
                                              setState(() {});
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('You don\'t have enough Credits'),
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(20.0))),
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                content: const Text('You need at least 50 Credits to redeem that'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                    child: const Text('OK', style: TextStyle(color: Colors.blue)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => LoginPage()),
                                            ).then((_)=>setState((){}));
                                          }

                                        },
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18.0),
                                                )
                                            ),
                                          backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.secondary),
                                        ),
                                        child: loggedIn ? Row(
                                          children: <Widget> [
                                            Text('Unlock: 50 ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                                            Icon(
                                              Icons.donut_large,
                                              size: 22,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ],
                                        ) : Text('Sign Up!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(
                            height: 30,
                          ),
                          if (canSee == true)
                            Row(children: <Widget>[
                              Spacer(),
                              socialsChange(percentageTw, "${baTw[0]}${TopCryptos[widget.passedIndex].tweets}%${baTw[1]}", tweetsColor, "Tweets count (7d)"),
                              Spacer(),
                              socialsChange(percentageCm, "${baCm[0]}${TopCryptos[widget.passedIndex].commits}%${baCm[1]}", commitsColor, "Commit count (7d)"),
                              Spacer(),
                            ]),
                        ]),
                      ),
                      Container(
                        child: Center(
                          child: Container(
                            width: screenWidth * 0.95,
                            height: 450,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Center(
                                  child: widgets[1],
                                ),
                                Center(
                                  child: ToggleButtons(
                                    direction: Axis.horizontal,
                                    onPressed: (int index) {
                                      setState(() {
                                        // The button that is tapped is set to true, and the others to false.
                                        for (int i = 0; i < isSelectedScore.length; i++) {
                                          isSelectedScore[i] = i == index;
                                          if (isSelectedScore[i] == true) {
                                            selectedIdxScore = i;
                                          }
                                        }
                                      });
                                    },
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    selectedBorderColor: Colors.transparent,
                                    selectedColor: Colors.black,
                                    fillColor: Colors.white,
                                    // color: Colors.white,
                                    borderWidth: 2,
                                    constraints: BoxConstraints(
                                      minHeight: 40.0,
                                      minWidth: screenWidth*0.15,
                                    ),
                                    isSelected: isSelectedScore,
                                    children: periodsScore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Container(
                            width: screenWidth * 0.95,
                            height: 450,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Center(
                                  child: widgets[2],
                                ),
                                Center(
                                  child: ToggleButtons(
                                    direction: Axis.horizontal,
                                    onPressed: (int index) {
                                      setState(() {
                                        // The button that is tapped is set to true, and the others to false.
                                        for (int i = 0; i < isSelectedMarketview.length; i++) {
                                          isSelectedMarketview[i] = i == index;
                                          if (isSelectedMarketview[i] == true) {
                                            selectedIdxMarketview = i;
                                          }
                                        }
                                      });
                                    },
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    selectedBorderColor: Colors.transparent,
                                    selectedColor: Colors.black,
                                    fillColor: Colors.white,
                                    // color: Colors.white,
                                    borderWidth: 2,
                                    constraints: BoxConstraints(
                                      minHeight: 40.0,
                                      minWidth: screenWidth*0.15,
                                    ),
                                    isSelected: isSelectedMarketview,
                                    children: periodsScore,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),

              SizedBox(
                height: 20,
              ),

              if (canSee)
                Center(
                  child: Container(
                    height: 425,
                    width: screenWidth * 0.95,
                    child: Column(children: <Widget>[
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget> [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Predictions History",
                                    style: TextStyle(
                                      height: 2, fontSize: 20, fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              )
                                          ),
                                          builder: (context) => Center(
                                            child: predictionsInfo(Theme.of(context).colorScheme.secondary),
                                          )
                                      );
                                    },
                                    icon: const Icon(Icons.info_outlined),
                                    iconSize: 15,
                                    padding: EdgeInsets.all(5),
                                    constraints: BoxConstraints(maxHeight: 28, maxWidth: 16),
                                  ),
                                ]
                              )
                            ),
                            Center(
                              child: selectedIdxPredictions == 0 ? (loggedIn ? widgets[3] : paywallCharts("Predictions")) : (userHasPremium() ? widgets[3] : paywallCharts("Predictions Signals")),
                            ),
                            Center(
                              child: ToggleButtons(
                                direction: Axis.horizontal,
                                onPressed: (int index) {
                                  setState(() {
                                    // The button that is tapped is set to true, and the others to false.
                                    for (int i = 0; i < isSelectedPredictions.length; i++) {
                                      isSelectedPredictions[i] = i == index;
                                      if (isSelectedPredictions[i] == true) {
                                        selectedIdxPredictions = i;
                                      }
                                    }
                                  });
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.transparent,
                                selectedColor: Colors.black,
                                fillColor: Colors.white,
                                // color: Colors.white,
                                borderWidth: 2,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: screenWidth*0.15,
                                ),
                                isSelected: isSelectedPredictions,
                                children: periodsPredictions,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ]),
                  )
              ),

              const SizedBox(
                height: 45,
              ),

              //VOLUME
              Center(
                  child: Container(
                    height: 400,
                    width: screenWidth * 0.95,
                    child: Column(children: <Widget>[
                      Center(
                        child: Container(
                          width: screenWidth * 0.95,
                          height: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              Center(
                                child: widgets[4]
                              ),
                              Center(
                                child: Text(subtitle, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ),
                              Center(
                                child: ToggleButtons(
                                  direction: Axis.horizontal,
                                  onPressed: (int index) {
                                    setState(() {
                                      // The button that is tapped is set to true, and the others to false.
                                      for (int i = 0; i < isSelectedVol.length; i++) {
                                        isSelectedVol[i] = i == index;
                                        if (isSelectedVol[i] == true) {
                                          selectedIdxVol = i;
                                        }
                                      }
                                    });
                                  },
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  selectedBorderColor: Colors.transparent,
                                  selectedColor: Colors.black,
                                  fillColor: Colors.white,
                                  // color: Colors.white,
                                  borderWidth: 2,
                                  constraints: BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: screenWidth*0.15,
                                  ),
                                  isSelected: isSelectedVol,
                                  children: periodsVol,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ]),
                  )
              ),
            ]),
      ),
    );
  }

  Future<List<List<PriceData>>> getChartData() async {
    List<List<PriceData>> cryptoData = [];
    List<PriceData> priceDataD = [];
    List<PriceData> priceDataY = [];
    List<PriceData> priceDataM = [];
    List<PriceData> priceDataW = [];
    List<PriceData> priceDataYTD = [];
    List<PriceData> volumeDataY = [];
    List<PriceData> volumeDataW = [];
    List<PriceData> volumeDataM = [];
    List<PriceData> volumeDataYTD = [];
    List<PriceData> scoreDataW = [];
    List<PriceData> scoreDataM = [];
    List<PriceData> scoreDataY = [];
    List<PriceData> marketviewDataW = [];
    List<PriceData> marketviewDataM = [];
    List<PriceData> marketviewDataY = [];
    List<PriceData> predictionsDataW = [];
    List<PriceData> predictionsDataM = [];
    List<PriceData> predictionsDataY = [];


    final String url = "https://api.coingecko.com/api/v3/coins/${TopCryptos[widget.passedIndex].id}/market_chart?vs_currency=usd&days=365&interval=daily";
    final String url2 = "https://api.coingecko.com/api/v3/coins/${TopCryptos[widget.passedIndex].id}/market_chart?vs_currency=usd&days=7&interval=hourly";
    final String url3 = "https://crypto-project-001-default-rtdb.firebaseio.com/history/main/${TopCryptos[widget.passedIndex].id}.json";

    for (int i=0;i<maxFetchTries;i++) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode != 200) {
          throw Exception('Could not fetch data (1)!');
        }

        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> prices = data['prices'];
        List<dynamic> volume = data['total_volumes'];

        DateTime now = DateTime.now();

        int counter = 0;
        int pricesLen = prices.length;
        int volumeLen = volume.length;

        for (List<dynamic> time in prices) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]);
          priceDataY.add(adding);
          if (pricesLen-counter <= 28) {
            priceDataM.add(adding);
          }
          if (adding.time.year == now.year) {
            priceDataYTD.add(adding);
          }

          counter+=1;
        }

        double largest = 0;

        for (List<dynamic> time in volume) {
          if (time[1] > largest) {
            largest = time[1];
          }
        }

        int curIndex = 0;

        for (int i=0;i<types.length;i++) {
          if (largest / numbers[i] > 1) {
            type = types[i];
            subtitle = sub[i];
            curIndex = i;
          }
          else {
            break;
          }
        }

        counter = 0;

        for (List<dynamic> time in volume) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]), double.parse((time[1]/numbers[curIndex]).toStringAsFixed(3)));
          volumeDataY.add(adding);

          if (volumeLen-counter <= 28) {
            volumeDataM.add(adding);
          }
          if (volumeLen-counter <= 7) {
            volumeDataW.add(adding);
          }
          if (adding.time.year == now.year) {
            volumeDataYTD.add(adding);
          }
          counter+=1;
        }

        final response2 = await http.get(Uri.parse(url2));

        if (response2.statusCode != 200) {
          throw Exception('Could not fetch data (2)!');
        }

        Map<String, dynamic> data2 = json.decode(response2.body);
        List<dynamic> prices2 = data2['prices'];

        int add = 3;

        for (List<dynamic> time in prices2) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]);
          if (add == 3) {
            priceDataW.add(adding);
            add = 0;
          }
          else {
            add += 1;
          }
          if (adding.time.day == now.day && adding.time.month == now.month) {
            priceDataD.add(adding);
          }
        }

        final response3 = await http.get(Uri.parse(url3));

        if (response3.statusCode != 200) {
          throw Exception('Could not fetch data (3)!');
        }

        Map<String, dynamic> data3 = Map<String, dynamic>. from(json.decode(response3.body));

        for (String key in data3.keys) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(int.parse(key)*1000),data3[key]['score'].toDouble());
          if (adding.time.compareTo(now.subtract(Duration(days: 7))) > 0) {
            scoreDataW.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 28))) > 0) {
            scoreDataM.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 365))) > 0) {
            scoreDataY.add(adding);
          }
        }

        for (String key in data3.keys) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(int.parse(key)*1000),data3[key]['marketView'].toDouble());
          if (adding.time.compareTo(now.subtract(Duration(days: 7))) > 0) {
            marketviewDataW.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 28))) > 0) {
            marketviewDataM.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 365))) > 0) {
            marketviewDataY.add(adding);
          }
        }

        for (String key in data3.keys) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(int.parse(key)*1000),double.parse(data3[key]['prediction']));
          if (adding.time.compareTo(now.subtract(Duration(days: 7))) > 0) {
            predictionsDataW.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 28))) > 0) {
            predictionsDataM.add(adding);
          }
          if (adding.time.compareTo(now.subtract(Duration(days: 365))) > 0) {
            predictionsDataY.add(adding);
          }
        }

        cryptoData.add(priceDataD);
        cryptoData.add(priceDataW);
        cryptoData.add(priceDataM);
        cryptoData.add(priceDataY);
        cryptoData.add(priceDataYTD);
        cryptoData.add(volumeDataW);
        cryptoData.add(volumeDataM);
        cryptoData.add(volumeDataY);
        cryptoData.add(volumeDataYTD);
        cryptoData.add(scoreDataW);
        cryptoData.add(scoreDataM);
        cryptoData.add(scoreDataY);
        cryptoData.add(marketviewDataW);
        cryptoData.add(marketviewDataM);
        cryptoData.add(marketviewDataY);
        // cryptoData.add(predictionsDataW);
        cryptoData.add(predictionsDataM);
        // cryptoData.add(predictionsDataY);
        break;
      }
      catch (e) {
        print(e);
        print('Trying again in 5 seconds');
        await Future.delayed(const Duration(seconds: 5), () {});
        continue;
      }
    }

    return cryptoData;
  }

  Container cryptoPredictionHistoryChart(TrackballBehavior trackballBehavior, List<PriceData> cryptoData, bool showAxis, double width, List<PriceData> predictionsHistory, int Mode) {

    List<PriceDataColor> predictionsDataChart = [];
    List<PlotBand> signals = [];
    int gap = 0;


    int prevPrediction = 0;
    bool inATrade = false;
    String start = DateFormat('MM-dd HH:00').format(predictionsHistory[0].time);
    String end = DateFormat('MM-dd HH:00').format(predictionsHistory[0].time);


    for (int i=gap;i<predictionsHistory.length;i++) {
      predictionsDataChart.add(
        PriceDataColor(predictionsHistory[i-gap].time, cryptoData[i-gap].price, predictionsHistory[i].price >= 0 ? (Mode != 1 ? Colors.greenAccent : Colors.lightBlueAccent) : (Mode != 1 ? Colors.redAccent : Colors.blueAccent))
      );

      if (Mode == 1) {
        int currentPred = predictionsHistory[i].price > 1 ? 2 : (predictionsHistory[i].price < -0.5 ? -2 : (predictionsHistory[i].price >= 0 ? 1 : -1));
        // print("prv is $prevPrediction and cur is $currentPred");


        //Exit trade
        if (((prevPrediction > 0 && currentPred < 0) || (prevPrediction < 0 && currentPred > 0)) && inATrade) {
          // print("Closing trade");
          end = DateFormat('MM-dd HH:00').format(predictionsHistory[i-gap].time);

          signals.add(
              PlotBand(
                start: start,
                end: end,
                isVisible: true,
                color: prevPrediction > 0 ? lightGreen : lightRed,
              )
          );
          inATrade = false;
        }
        //Enter trade
        if ((currentPred >= 2 && prevPrediction < 2) || (currentPred <= -2 && prevPrediction > -2)) {
          // print("entered Trade");
          start = DateFormat('MM-dd HH:00').format(predictionsHistory[i].time);
          inATrade = true;
        }

        prevPrediction = currentPred;
      }
    }

    if (inATrade) {
      signals.add(
        PlotBand(
          start: start,
          end: DateFormat('MM-dd HH:00').format(predictionsHistory[predictionsHistory.length-1].time),
          isVisible: true,
          color: prevPrediction > 0 ? Colors.greenAccent : Colors.redAccent,
        )
      );
      inATrade = false;
    }

    return Container(
      height: 325,
      width: width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 325,
            width: width,
            child: SfCartesianChart(
              trackballBehavior: trackballBehavior,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                isVisible: showAxis,
                plotBands: signals
              ),
              primaryYAxis: NumericAxis(
                isVisible: showAxis,
                majorGridLines: const MajorGridLines(width: 0),
                rangePadding: ChartRangePadding.round,
                // labelFormat: '\${value}',
              ),
              borderColor: Colors.transparent,
              plotAreaBorderColor: Colors.transparent,
              legend: Legend(isVisible: false),
              series: <LineSeries<PriceDataColor, String>>[
                LineSeries<PriceDataColor, String>(
                  dataSource: predictionsDataChart,
                  xValueMapper: (PriceDataColor prices, _) => DateFormat('MM-dd HH:00').format(prices.time),
                  yValueMapper: (PriceDataColor prices, _) => prices.price,
                  pointColorMapper: (PriceDataColor prices, _) => prices.pointColor,
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }

  Container cryptoPriceChart(TrackballBehavior trackballBehavior, List<PriceData> cryptoData, bool showAxis, double width) {
    Color lineColor = cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0 ? cRed : cGreen;
    return Container(
      height: 350,
      width: width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 350,
            width: width,
            child: SfCartesianChart(
              trackballBehavior: trackballBehavior,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                isVisible: showAxis,
              ),
              primaryYAxis: NumericAxis(
                isVisible: showAxis,
                majorGridLines: const MajorGridLines(width: 0),
                rangePadding: ChartRangePadding.round,
                // labelFormat: '\${value}',
              ),
              borderColor: Colors.transparent,
              plotAreaBorderColor: Colors.transparent,
              onTrackballPositionChanging: (TrackballArgs args) {
                _priceText.value = args.chartPointInfo.label!;
              },
              legend: Legend(isVisible: false),
              series: <LineSeries<PriceData, String>>[
                LineSeries<PriceData, String>(
                  color: lineColor,
                  dataSource: cryptoData,
                  xValueMapper: (PriceData prices, _) => DateFormat('MM-dd HH:00').format(prices.time),
                  yValueMapper: (PriceData prices, _) => prices.price,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column historyChart(String object, Widget chart, int selectedIdx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Center(
            child: Column(
                children: <Widget> [
                  Text(
                    "$object History",
                    style: const TextStyle(
                      height: 2, fontSize: 20, fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  selectedIdx != 0 ? (selectedIdx == 1 ? (loggedIn ? chart : paywallCharts(object)) : (userHasPremium() ? chart : paywallCharts(object))) : chart,
                ]
            )
        )
      ],
    );
  }

  Column paywallCharts(String object) {
    return Column(children: <Widget> [
      SizedBox(height: 60),
      Image.network(
        "https://i.postimg.cc/VkpYychz/Lock.png",
        height:60,
      ),
      Text(
        !loggedIn ? "Join Retro" : "You discovered a Premium Feature!",
        style: const TextStyle(
          height: 3,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      Text(
        !loggedIn ? "Sign Up to access monthly $object History!" : "Get Premium to access more $object History! \n Go to the Premium Page to Learn more.",
        style: const TextStyle(
          height: 1,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10,),
      if (!loggedIn)
        SizedBox(
          height: 30,
          width: 120,
          child: OutlinedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ).then((_)=>setState((){}));
              return;
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )
              ),
              backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.secondary),
            ),
            child: Text('Sign Up!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
          ),
        ),
      if (loggedIn)
        SizedBox(
          height: 30,
          width: 135,
          child: OutlinedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GetPremiumPage()),
              ).then((_)=>setState((){}));
              return;
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )
              ),
              backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.secondary),
            ),
            child: Text('Learn More', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),
          ),
        ),
      SizedBox(height: 80),
    ]);
  }

}


class PriceData {
  PriceData(this.time, this.price);

  final DateTime time;
  final double price;
}

class PriceDataColor {
  PriceDataColor(this.time, this.price, this.pointColor);

  final DateTime time;
  final double price;
  final Color pointColor;
}