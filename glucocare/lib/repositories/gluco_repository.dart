import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

import 'gluco_colname_repository.dart';

class GlucoRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertGlucoCheck(GlucoModel model) async {
    String uid = AuthService.getCurUserUid();

    try {
      await _store
          .collection('gluco_check').doc(uid)
          .collection(model.checkDate).doc(model.checkTime)
          .set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert GlucoCheck field : $e');
    }
  }

  static Future<List<GlucoModel>> selectAllGlucoCheck() async {
    String uid = AuthService.getCurUserUid();
    List<GlucoModel> models = <GlucoModel>[];

    List<String> namelist = await GlucoColNameRepository.selectAllGlucoColName();

    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(uid)
            .collection(name).get();
        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          models.add(model);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco check history $e');
        return [];
      }
    }

    return models;
  }

  static Future<GlucoModel?>? selectGlucoByColName(String colName) async {
    String uid = AuthService.getCurUserUid();

    try {
      var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(colName)
          .orderBy('check_time', descending: true).limit(1).get();
      GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
      return model;
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco check history $e');
      return null;
    }
  }

  static Future<List<GlucoModel>> selectGlucoByDay(String checkDate) async {
    String uid = AuthService.getCurUserUid();
    List<GlucoModel> models = <GlucoModel>[];

    try{
      var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(checkDate).get();

      for(var doc in docSnapshot.docs) {
        GlucoModel model = GlucoModel.fromJson(doc.data());
        models.add(model);
      }

      return models;
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco history by day : $e');
      return [];
    }

  }

  static Future<List<FlSpot>> getGlucoData(list) async {
    String uid = AuthService.getCurUserUid();

    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await GlucoColNameRepository.selectAllGlucoColName();
    colNames = colNames.reversed.toList();

    for(String name in colNames) {
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(name)
            .orderBy('check_time', descending: false).get();
        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          chartDatas.add(FlSpot(index, model.value.toDouble()));
          list.add(name.substring(10,12));

          index++;

          if(chartDatas.length >= 30) return chartDatas;
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco chart data : $e');
        return chartDatas;
      }
    }

    return chartDatas;
  }

  static Future<GlucoModel?> selectLastGlucoCheck() async {
    String uid = AuthService.getCurUserUid();
    GlucoModel? model = null;

    try{
      String lastColName = await GlucoColNameRepository.selectLastGlucoColName();

      if(lastColName != '') {
        try {
          var docSnapshot = await _store
              .collection('gluco_check').doc(uid)
              .collection(lastColName)
              .orderBy('check_time')
              .limit(1)
              .get();

          model = GlucoModel.fromJson(docSnapshot.docs.first.data());
          return model;
        } catch(e) {
          logger.d('[glucocare_log] Failed to load gluco check by colname : $e');
        }



      }
    } catch(e) {
      logger.d('[glucocare_log] Failed to load gluco check by colname : $e');
    }

    return model;
  }

  static Future<void> updateGlucoCheck(GlucoModel model) async {

  }

  static Future<void> deleteGlucoCheck(GlucoModel model) async {

  }
}