import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/pill_alarm_model.dart';
import 'package:glucocare/repositories/pill_colname_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PillAlarmRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPillAlarm(PillAlarmModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        await _store.collection('pill_alarm').doc(uid)
            .collection(model.saveDate).doc(model.saveTime)
            .set(model.toJson());
      } catch (e) {
        logger.e('[glucocare_log] Failed to insert pill alarm (insertPillAlarm) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        await _store.collection('pill_alarm').doc(kakaoId)
            .collection(model.saveDate).doc(model.saveTime)
            .set(model.toJson());
      } catch (e) {
        logger.e('[glucocare_log] Failed to insert pill alarm (insertPillAlarm) : $e');
      }
    }
  }

  static Future<List<PillAlarmModel>> selectAllPillAlarm() async {
    List<PillAlarmModel> pillAlarmModels = <PillAlarmModel>[];
    List<String> namelist = await PillColNameRepository.selectAllAlarmColName();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String subColName in namelist) {
        try{
          var querySnapshot = await _store.collection('pill_alarm').doc(uid).collection(subColName).get();
          for(var doc in querySnapshot.docs) {
            PillAlarmModel model = PillAlarmModel.fromJson(doc.data());
            pillAlarmModels.add(model);
          }
        } catch(e) {
          logger.e('[glucocare_log] Failed to select pill alarms (selectAllPillAlarm) : $e');
          return [];
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String subColName in namelist) {
        try{
          var querySnapshot = await _store.collection('pill_alarm').doc(kakaoId).collection(subColName).get();
          for(var doc in querySnapshot.docs) {
            PillAlarmModel model = PillAlarmModel.fromJson(doc.data());
            pillAlarmModels.add(model);
          }
        } catch(e) {
          logger.e('[glucocare_log] Failed to select pill alarms (selectAllPillAlarm) : $e');
          return [];
        }
      }
    }
    return pillAlarmModels;
  }

  static Future<void> deletePillAlarmBySaveTime(String saveDate, String saveTime) async {
    String? uid = AuthService.getCurUserUid();
    await _store.collection('pill_alarm').doc(uid).collection(saveDate).doc(saveTime).delete();
  }
}