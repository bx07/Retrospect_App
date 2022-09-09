import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/purchase.dart';
import 'package:crypto_app/UI/UI%20helpers/textelements.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'Functions/cloudfunctionshelper.dart';
import 'UI/UI helpers/pages.dart';
import 'UI/UI helpers/themes.dart';
import 'UI/notifications.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'UI/cryptosearchdelegate.dart';
import "UI/detailspage.dart";
import 'Functions/cryptoinfoclass.dart';
import 'UI/information.dart';
import 'UI/updatelog.dart';
import 'Functions/database.dart';
import 'UI/mainpages.dart';
import 'UI/adhelper.dart';
import 'firebase_options.dart';

//Program Settings
const int cryptosCap = 500;
const int maxFetchTries = 4;
final int limit = 5;
int premiumExpire = 0;
bool isPremium = false;

//Declare variables
List<String> CryptosList = [];
Map<String, int> CryptosIndex = {};
List<CryptoInfo> TopCryptos = [];
Map<String, List<int>> Sort = {};
List<int> Ascending = [];
List<int> Descending = [];
List<int> MarketCapA = [];
List<int> MarketCapD = [];
List<int> ChangeA = [];
List<int> ChangeD = [];

DateTime lastRefreshed = DateTime.now();
int globalIndex = 0;
List<dynamic> data = [];

List<String> testDeviceIds = ["CFA4604CA7FDF96FC2E2B539F1B430E9"];

//Declare styles

//Settings variables
bool darkTheme = true;
String sortBy = "⬆A-Z";
bool worked = false;
String currentPromo = "none";
String offerMsg = "none";
String app_version = "1.3.4";
String new_version = app_version;
late final NotificationService notificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "Retrospect",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initPlatformState();
  // MobileAds.instance
  //   ..initialize()
  //   ..updateRequestConfiguration(
  //     RequestConfiguration(testDeviceIds: testDeviceIds),
  //   );
  // MobileAds.instance.initialize();
  // RequestConfiguration configuration = RequestConfiguration(testDeviceIds: testDeviceIds);
  // MobileAds.instance.updateRequestConfiguration(configuration);

  await GetStorage.init();
  final introdata = GetStorage();

  final worked = await fetchDatabase();
  await appVersion();

  if (worked == false) {
    exit(0);
  }

  DateTime lastRefreshed = DateTime.now();

  introdata.writeIfNull("displayed", false);
  introdata.writeIfNull("darkTheme", true);
  introdata.writeIfNull("credits", 0);
  introdata.writeIfNull("logged in", false);
  introdata.writeIfNull("username", "");
  introdata.writeIfNull("password", "");
  introdata.writeIfNull("used", <String> []);
  introdata.writeIfNull("premiumUser", "");
  introdata.writeIfNull("last open", DateTime.now().millisecondsSinceEpoch);
  introdata.writeIfNull("alerts", <String, String> {});

  DateTime now = DateTime.now();
  if (DateTime.fromMillisecondsSinceEpoch(introdata.read("last open")).compareTo(DateTime(now.year, now.month, now.day, 0, 0, 0)) < 0) {
    introdata.write("used", <String> []);
  }

  darkTheme = introdata.read("darkTheme");
  introdata.write("last open", DateTime.now().millisecondsSinceEpoch);

  Workmanager().initialize(callbackDispatcher);

  print(introdata.read("alerts"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final introdata = GetStorage();

  @override
  Widget build(BuildContext context) {

    // introdata.write("displayed", false);
    if (darkTheme == true) {
      Get.changeTheme(customDark);
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retrospect',
      theme: ThemeData.light(),
      // darkTheme: customDark,
      home: app_version == new_version ? introdata.read("displayed") ? const MainPages() : IntroPage() : const UpdateApp(),
    );
  }
}



void callbackDispatcher() {

  Workmanager().executeTask((taskName, inputData) async {
    print("Task executing: $taskName with input $inputData"); //simpleTask will be emitted here.
    if (taskName.contains("Alert")) {
      //update server
      bool worked = await fetchDatabase();

      notificationService = NotificationService();

      notificationService.initializePlatformNotifications();

      if (worked) {
        if (TopCryptos[CryptosIndex[inputData!['crypto']] ?? 0].prediction == inputData['trigger']) {

          await notificationService.showLocalNotification(
              id: 0,
              title: "Predictions Alert!",
              body: "${inputData['crypto']} just turned ${inputData['target']}!!",
              payload: "You just took water! Huurray!");

          Workmanager().cancelByUniqueName(inputData['crypto']);

        }
      }
    }

    return Future.value(true);
  });
}

