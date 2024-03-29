import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/premium.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../UI/cryptosearchdelegate.dart';
import '../UI/detailspage.dart';
import 'cryptoinfoclass.dart';
import '../UI/information.dart';
import '../UI/updatelog.dart';
import '../main.dart';

Future<void> refreshAlerts() async {
  final ref = FirebaseDatabase.instance.ref('alerts/users/${FirebaseAuth.instance.currentUser?.uid}');
  final snapshot = await ref.get();

  if (snapshot.exists) {
    alerts = snapshot.value as Map<dynamic, dynamic>;
  }
  else {
    alerts = {};
  }
}

Future<bool> fetchDatabase() async {
  print("Refreshing");

  for (int tries = 0; tries < maxFetchTries; tries++) {
    try {
      final response = await http.get(Uri.parse('https://crypto-project-001-default-rtdb.firebaseio.com/database.json'));
      data = await jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception('Could not fetch data!');
      }

      worked = true;

      // print(data);

      Sort["↑A-Z"] = [];
      Sort["↓A-Z"] = [];
      Sort["↑Mrkt"] = [];
      Sort["↓Mrkt"] = [];
      Sort["↑24h"] = [];
      Sort["↓24h"] = [];
      Sort["↑Vol"] = [];
      Sort["↓Vol"] = [];
      Sort["↑Pred"] = [];
      Sort["↓Pred"] = [];
      Sort["Starred"] = [];

      int count = 0;

      TopCryptos = [];
      CryptosList = [];
      CryptosIndex = {};
      globalIndex = 0;

      for (String crypto in data['predictions'].keys) {
        try {
          final Res = CryptoInfo.fromJson(data['predictions'][crypto], data['cryptos'][crypto]);
          TopCryptos.add(await Res);
        }
        catch (e) {
          print("$crypto is no longer supported");
        }

        count+=1;
      }

      for (int i=0;i<count;i++) {
        Sort["↑A-Z"]?.add(i);
        Sort["↓A-Z"]?.add(count-i-1);
      }

      break;
    } catch (e) {

      if (e is ClientException) {
        if (e.message == 'Connection closed while receiving data') {
          await Future.delayed(const Duration(seconds: 5), () {});
          print('Exception Connection closed while receiving data');
          print('Trying again in 5 seconds');
          continue;
        }
      } else {
        print('Trying again in 10 seconds');
        print(e);
        await Future.delayed(const Duration(seconds: 10), () {});
        continue;
      }
    }
  }

  if (worked == false) {
    return worked;
  }


  // Sort cryptos by marketCap and Change
  List<CryptoInfo> copy = List.from(TopCryptos);


  copy.sort((a,b) => (int.tryParse(a.market_cap_rank) ?? 1000).compareTo((int.tryParse(b.market_cap_rank) ?? 1000)));
  for (CryptoInfo crypto in copy) {
    Sort["↓Mrkt"]?.add(CryptosIndex[crypto.id] ?? 0);
  }


  copy.sort((a,b) => (int.tryParse(b.market_cap_rank) ?? 1000).compareTo((int.tryParse(a.market_cap_rank) ?? 1000)));
  for (CryptoInfo crypto in copy) {
    Sort["↑Mrkt"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(a.price_change_precentage_24h) ?? 0.0).compareTo(double.tryParse(b.price_change_precentage_24h) ?? 0.0));
  for (CryptoInfo crypto in copy) {
    Sort["↓24h"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(b.price_change_precentage_24h) ?? 0.0).compareTo(double.tryParse(a.price_change_precentage_24h) ?? 0.0));
  for (CryptoInfo crypto in copy) {
    Sort["↑24h"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (int.tryParse(a.realVolume) ?? 0).compareTo(int.tryParse(b.realVolume) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["↑Vol"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (int.tryParse(b.realVolume) ?? 0).compareTo(int.tryParse(a.realVolume) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["↓Vol"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(a.realPrediction) ?? 0).compareTo(double.tryParse(b.realPrediction) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["↑Pred"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(b.realPrediction) ?? 0).compareTo(double.tryParse(a.realPrediction) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["↓Pred"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  List<String> stars = localStorage.read("starred_coins")?.cast<String>() ?? [];

  Sort["Starred"] = [];

  for (String crypto in stars) {
    if (CryptosIndex.containsKey(crypto)) {
      Sort["Starred"]?.add(CryptosIndex[crypto]!);
    }
    else {
      stars.remove(crypto);
    }
  }

  localStorage.write("starred_coins", stars);

  return worked;
}