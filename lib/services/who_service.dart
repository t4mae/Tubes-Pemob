import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/who.dart';

class WhoService {
  static Future<List<WhoData>> loadBerat(String gender) async {
    var pg = "pr";
    if(gender == "L") {
      pg = "lk";
    }
    final path = 'assets/who/berat/berat_${pg.toLowerCase()}.json';
    final raw = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(raw);
    return jsonList.map((e) => WhoData.fromJson(e, gender)).toList();
  }

  static Future<List<WhoData>> loadTinggi(String gender) async {
    var pg = "pr";
    if(gender == "L") {
      pg = "lk";
    }
    final path = 'assets/who/panjang/panjang_${pg.toLowerCase()}.json';
    final raw = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(raw);
    return jsonList.map((e) => WhoData.fromJson(e, gender)).toList();
  }

  static Future<List<WhoData>> loadKepala(String gender) async {
    var pg = "pr";
    if(gender == "L") {
      pg = "lk";
    }
    final path = 'assets/who/kepala/kepala_${pg.toLowerCase()}.json';
    final raw = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(raw);
    return jsonList.map((e) => WhoData.fromJson(e, gender)).toList();
  }
}
