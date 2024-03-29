import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';

class CryptoInfo {
  final String market_cap_rank;
  final String ath;
  final String market_cap;
  final String low_24h;
  final String high_24h;
  final String current_price;
  final String total_volume;
  final String symbol;
  final String last_updated;
  final String id;
  final String image;
  final String total_supply;
  final String price_change_precentage_24h;
  final String prediction;
  final String marketView;
  final String tweets;
  final String commits;
  final String score;
  final String realVolume;
  final String realScore;
  final String realPrediction;

  CryptoInfo({
    required this.market_cap_rank,
    required this.ath,
    required this.market_cap,
    required this.low_24h,
    required this.high_24h,
    required this.current_price,
    required this.total_volume,
    required this.symbol,
    required this.last_updated,
    required this.id,
    required this.image,
    required this.total_supply,
    required this.price_change_precentage_24h,
    required this.prediction,
    required this.marketView,
    required this.tweets,
    required this.commits,
    required this.score,
    required this.realVolume,
    required this.realScore,
    required this.realPrediction,
  });

  factory CryptoInfo.fromJson(Map<String, dynamic> predictions, Map<String, dynamic> data) {
    String id = data['id'].toString();
    String marketCap = Numeral(data['market_cap']).format().toString();
    String volume = Numeral(data['total_volume']).format().toString();
    String price = data['current_price'].toString();
    String twtyFHigh = data['high_24h'].toString();
    String twtyFLow = data['low_24h'].toString();
    String twentyFourHours = data['price_change_percentage_24h'].toString();
    String prediction = predictions['prediction'].toString();
    String marketView = predictions['marketView'].toString();
    String tweets = predictions['tweets'].toString() == "updating database" ? '0' : predictions['tweets'].toString();
    String commits = predictions['commits'].toString() == "updating database" ? '0' : predictions['commits'].toString();
    String score = predictions['score'].toString();
    String totalSupply = data['total_supply'].toString();
    String realVolume = data['total_volume'].toString();
    String realScore = predictions['score'].toString() == "updating database" ? 'Upd' : double.parse(predictions['score'].toString()).toStringAsFixed(1);

    if (prediction != "updating database") {
      double pred = double.parse(prediction);
      if (pred == 0) {
        prediction = "Neutral";
      } else if (pred > 0 && pred <= 5) {
        prediction = "Smwht Bullish";
      } else if (pred > 5 && pred <= 10) {
        prediction = "Bullish";
      } else if (pred > 10) {
        prediction = "Very Bullish";
      } else if (pred >= -5 && pred < 0) {
        prediction = "Smwht Bearish";
      } else if (pred >= -10 && pred < -5) {
        prediction = "Bearish";
      } else if (pred < -10) {
        prediction = "Very Bearish";
      }
    }

    if (marketCap.contains(".")) {
      marketCap = marketCap.substring(0, marketCap.indexOf(".")) +
          marketCap.substring(marketCap.length - 1, marketCap.length);
    }
    if (volume.contains(".")) {
      volume = volume.substring(0, volume.indexOf(".")) +
          volume.substring(volume.length - 1, volume.length);
    }
    if (realVolume.contains(".")) {
      realVolume = realVolume.substring(0, realVolume.indexOf("."));
    }

    if (double.parse(price) < 0.0001) {}
    else {
      price = double.parse(price).toStringAsFixed(3);
    }

    totalSupply = Numeral(double.tryParse(totalSupply) ?? -1).format().toString();

    if (twtyFHigh.length < 5) {
      twtyFHigh = twtyFHigh.substring(0, twtyFHigh.length);
    } else {
      if (double.parse(twtyFHigh) < 0.0001) {}
      else {
        twtyFHigh = twtyFHigh.substring(0, 5);
      }

    }
    if (twtyFLow.length < 5) {
      twtyFLow = twtyFLow.substring(0, twtyFLow.length);
    } else {
      if (double.parse(twtyFLow) < 0.0001) {}
      else {
        twtyFLow = twtyFLow.substring(0, 5);
      }
    }
    if (twentyFourHours.contains('.')) {
      twentyFourHours = twentyFourHours.substring(0, twentyFourHours.indexOf('.')+2);
    }

    final addCryptoIndex = <String, int>{id: globalIndex};
    globalIndex += 1;

    CryptosIndex.addEntries(addCryptoIndex.entries);
    CryptosList.add(id);

    return CryptoInfo(
      market_cap_rank: data['market_cap_rank'].toString(),
      ath: data['ath'].toString(),
      market_cap: marketCap,
      low_24h: twtyFLow,
      high_24h: twtyFHigh,
      current_price: price,
      total_volume: volume,
      symbol: data['symbol'].toString(),
      last_updated: data['last_updated'].toString(),
      id: id,
      image: data['image'].toString(),
      total_supply: totalSupply,
      price_change_precentage_24h: twentyFourHours,
      prediction: prediction,
      marketView: marketView,
      tweets: tweets,
      commits: commits,
      score: score,
      realVolume: realVolume,
      realScore: realScore,
      realPrediction: predictions['prediction'].toString(),
    );
  }
}
