import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/pill_alarm_col_name_model.dart';
import 'package:glucocare/models/pill_alarm_model.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/repositories/pill_alarm_repository.dart';
import 'package:glucocare/repositories/pill_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../repositories/pill_colname_repository.dart';

class PillCheckPage extends StatelessWidget {
  const PillCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        leadingWidth: 300, 
          leading: const Row(
            children: [
              BackButton(
                color: Colors.black,
              ),
              Text('알림 설정', style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),),
            ],
          ),
      ),
      body: const PillCheckForm(),
    );
  }
}

class PillCheckForm extends StatefulWidget {
  const PillCheckForm({super.key});

  @override
  State<StatefulWidget> createState() => _PillCheckFormState();
}

class _PillCheckFormState extends State<PillCheckForm> {
  Logger logger = Logger();
  String? uid = AuthService.getCurUserUid();
  bool _isLoading = true;

  int _alarmHourValue = 1;
  final List<int> _alarmHourOptions = List.generate(12, (index) => (index+=1));
  int? get previousHourOption => _alarmHourValue > 0 && _alarmHourValue != 1 ? _alarmHourValue - 1 : null;
  int? get nextHourOption => _alarmHourValue < _alarmHourOptions.length ? _alarmHourValue + 1 : null;

  int _alarmMinuteValue = 0;
  final List<String> _alarmMinuteOptions = List.generate(60, (index) => index.toString());
  String? get previousMinuteOption => _alarmMinuteValue > 0 ? _alarmMinuteOptions[_alarmMinuteValue - 1] : null;
  String? get nextMinuteOption => _alarmMinuteValue < _alarmMinuteOptions.length - 1 ? _alarmMinuteOptions[_alarmMinuteValue + 1] : null;

  String _alarmTimeAreaValue = '오전';
  final List<String> _alarmTimeAreaOptions = ['오전', '오후'];

  final TextEditingController _stateContoller = TextEditingController();

  String _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
  String _saveDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  String _state = '';
  Timestamp _alarmTime = Timestamp.fromDate(DateTime.now());

  List<PillModel> _pillModels = [];
  int _childCount = 0;

  void _setPillModels() async {
    // setState() 이전에 먼저 async-await 작업 후
    // setStete() 내에서 해당 데이터를 옮겨 줌
    try {
      List<PillModel> models = await PillRepository.selectAllPillModels();
      setState(() {
        _pillModels = models;
        _childCount = _pillModels.length;
        _isLoading = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load pill histories : $e');
    }
  }

  void _setPillAlarmModels() async {
    List<PillAlarmModel> models = await PillAlarmRepository.selectAllPillAlarm();
  }

  String _getLocaleTime(Timestamp time) {
    DateTime utcTime = time.toDate();
    DateTime krTime = utcTime.toLocal();
    String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(krTime);

    return formattedTime;
  }

  void _setStates() {
    _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _saveDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
    _state = _stateContoller.text;

    // _alarmTime
    int adjustedHour = _alarmHourValue;
    if(_alarmTimeAreaValue == '오후') adjustedHour += 12;
    if(_alarmTimeAreaValue == '오전' && _alarmHourValue == 12) adjustedHour = 0;
    _alarmTime = Timestamp.fromDate(
        DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            adjustedHour,
            _alarmMinuteValue
        ).toUtc()
    );
  }

  void _initValues() {
    _stateContoller.text = '';
    _alarmTimeAreaValue = '오전';
    _alarmHourValue = 1;
    _alarmMinuteValue = 0;
  }

  void _onSaveButtonPressed() {
    _setStates();
    PillModel pillModel = PillModel(saveDate: _saveDate, saveTime: _saveTime, alarmTime: _alarmTime, state: _state);
    PillAlarmModel pillAlarmModel = PillAlarmModel(saveDate: _saveDate, saveTime: _saveTime, alarmTime: _alarmTime);
    PillAlarmColNameModel alarmNameModel = PillAlarmColNameModel(date: _saveDate, uid: uid!);

    PillRepository.insertPillCheck(pillModel);
    PillAlarmRepository.insertPillAlarm(pillAlarmModel);
    PillColNameRepository.insertAlarmColName(alarmNameModel);

    _setPillModels();
    _initValues();
  }

  @override
  void initState() {
    super.initState();
    _setPillModels();
    // _setPillAlarmModels();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40,),
              Container(
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFF9F9F9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(_alarmTimeAreaValue == '오전')
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(''),
                            ),
                          if(_alarmTimeAreaValue == '오후')
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text('오전', style: TextStyle(
                                fontSize: 30,
                                color: Color(0xFFB7B7B7),
                              ),),
                            ),
                          SizedBox(
                            width: 90,
                            height: 50,
                            child: CupertinoPicker(
                              itemExtent: 60,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _alarmTimeAreaValue = _alarmTimeAreaOptions[index];
                                });
                              },
                              children: _alarmTimeAreaOptions.map((item) => Center(
                                child: Text(item, style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                  textAlign: TextAlign.center,
                                ),
                              )).toList(),
                            ),
                          ),
                          if(_alarmTimeAreaValue == '오후')
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(''),
                            ),
                          if(_alarmTimeAreaValue == '오전')
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text('오후', style: TextStyle(
                                fontSize: 30,
                                color: Color(0xFFB7B7B7),
                              ),),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(previousHourOption != null)
                            SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(previousHourOption.toString(), style: const TextStyle(
                                fontSize: 30,
                                color: Color(0xFFB7B7B7),
                              ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                          if(previousHourOption == null)
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(''),
                            ),
                          SizedBox(
                            width: 90,
                            height: 50,
                            child: CupertinoPicker(
                              backgroundColor: Color(0xFFF9F9F9),
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _alarmHourValue = index+1;
                                });
                              },
                              children: _alarmHourOptions.map((item) => Center(
                                child: Text(item.toString(), style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                  textAlign: TextAlign.center,
                                ),
                              )).toList(),
                            ),
                          ),
                          if(nextHourOption != null)
                            SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(nextHourOption.toString(), style: const TextStyle(
                                fontSize: 30,
                                color: Color(0xFFB7B7B7),
                              ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                          if(nextHourOption == null)
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text('',),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(previousMinuteOption != null)
                            SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(previousMinuteOption!,
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFFB7B7B7),
                                ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                          if(previousMinuteOption == null)
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text('',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFFB7B7B7),
                                ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(
                            width: 90,
                            height: 50,
                            child: CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _alarmMinuteValue = index;
                                });
                              },
                              children: _alarmMinuteOptions.map((item) => Center(
                                child: Text(item, style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),),
                              )).toList(),
                            ),
                          ),
                          if(nextMinuteOption != null)
                            SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(nextMinuteOption!,
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Color(0xFFB7B7B7),
                                ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                          if(nextMinuteOption == null)
                            const SizedBox(
                              width: 60,
                              height: 50,
                              child: Text(''),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Container(
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFF9F9F9),
                ),
                child: TextField(
                  controller: _stateContoller,
                  maxLines: null,
                  minLines: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '메모를 입력하세요',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 350,
                height: 400,
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: _childCount,
                            (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pillModels[index].saveDate,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: Image.asset('assets/images/ic_clock.png'),
                                            ),
                                            const SizedBox(width: 10,),
                                            Text('${_getLocaleTime(_pillModels[index].alarmTime)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: Image.asset('assets/images/ic_pill_check.png'),
                                            ),
                                            const SizedBox(width: 10,),
                                            Text(_pillModels[index].state,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          onPressed: _onSaveButtonPressed,
          backgroundColor: Color(0xFF28C2CE),
          child: const Text(
            '추가하기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}