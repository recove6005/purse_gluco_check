import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:intl/intl.dart';

class PatientInfoPage extends StatelessWidget {
  const PatientInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 정보', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: PatientInfoForm(),
    );
  }
}

class PatientInfoForm extends StatefulWidget {
  const PatientInfoForm({super.key});

  @override
  State<PatientInfoForm> createState() => _PatientInfoFormState();
}

class _PatientInfoFormState extends State<PatientInfoForm> {
   String _name = '';
   String _gen = '';
   String _birthDate = '';
   String _state = '없음';

  Future<void> _getModel() async {
    PatientModel? model = await PatientRepository.selectPatientByUid();
    if(model != null) {
      setState(() {
        _name = model.name;
        _gen = model.gen;
        _birthDate = DateFormat('yyyy년 MM월 DD일').format(model.birthDate.toDate());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getModel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50,),
          Container(
            width: 350,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('$_name 님', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          Container(
            width: 350,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 30,),
                Text('성별 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(width: 30,),
                Text(_gen, style: TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          Container(
            width: 350,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 30,),
                Text('생일 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(width: 30,),
                Text(_birthDate, style: TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          Container(
            width: 350,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('특이사항', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(height: 5,),
                Text(_state, style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
