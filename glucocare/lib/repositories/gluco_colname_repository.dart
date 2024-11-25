import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/gluco_col_name_model.dart';
import '../services/auth_service.dart';

class GlucoColNameRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertGlucoColName(GlucoColNameModel model) async {

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        _store.collection('gluco_name').doc('${model.date} $uid').set(model.toJson());
      } catch(e) {
        logger.d('[glucocare_log] Failed to insert gluco col name (insertGlucoColName) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      logger.d('[glucocare_log] user num: $kakaoId');

      try {
        _store.collection('gluco_name').doc('${model.date} $kakaoId').set(model.toJson());
      } catch(e) {
        logger.d('[glucocare_log] Failed to insert gluco col name (insertGlucoColName) : $e');
      }
    }
  }

  static Future<List<String>> selectAllGlucoColName() async {
    List<String> glucoColNameList = <String>[];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('gluco_name').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        GlucoColNameModel glucoData = GlucoColNameModel.fromJson(doc.data());
        glucoColNameList.add(glucoData.date);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('gluco_name').where('uid', isEqualTo: kakaoId).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        GlucoColNameModel glucoData = GlucoColNameModel.fromJson(doc.data());
        glucoColNameList.add(glucoData.date);
      }
    }

    return glucoColNameList;
  }

  static Future<String> selectLastGlucoColName() async {
    String lastGlucoColName = '';

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        var docSnapshot = await _store.collection('gluco_name')
            .where('uid', isEqualTo: uid)
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if(docSnapshot.docs.first.exists) {
          lastGlucoColName = GlucoColNameModel.fromJson(docSnapshot.docs.first.data()).date;
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco col name (selectLastGlucoColName) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        var docSnapshot = await _store.collection('gluco_name')
            .where('uid', isEqualTo: kakaoId)
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if(docSnapshot.docs.first.exists) {
          lastGlucoColName = GlucoColNameModel.fromJson(docSnapshot.docs.first.data()).date;
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco col name (selectLastGlucoColName) : $e');
      }
    }

    return lastGlucoColName;
  }
}