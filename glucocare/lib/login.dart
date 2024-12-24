import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/kakao_login_service.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _idInputController = TextEditingController();

  Logger logger = Logger();
  String _masterId = '';
  bool _isKakaoLogind = false;
  bool _isMasterLogin = false;

  void _authCode() async {
    _masterId = _idInputController.text.trim();
    if(_masterId == '**daol4558**') {
      try {
        await AuthService.authPasswordAndMasterLogin();
        if(await AuthService.userLoginedFa()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } catch (e) {
        logger.e('[glucocare_log] Master login is faeild. : $e');
      }
      return;
    }
    // if (_verifyId.isEmpty || smsCode.isEmpty) {
    //   Fluttertoast.showToast(msg: '인증 정보를 입력하세요.', toastLength: Toast.LENGTH_SHORT);
    //   return;
    // } else {
    //   try {
    //     logger.d('[glucocare_log] inputed code : $smsCode');
    //     await AuthService.authCodeAndLogin(_verifyId, smsCode);
    //     if(await AuthService.userLoginedFa()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    //   } catch(e) {
    //     logger.e('[glucocare_log] Failed to phone number auth $e');
    //     Fluttertoast.showToast(msg: '올바른 전화번호와 인증번호를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
    //
    //
    //   }
    // }
  }

  void _autoLogin() async {
    // 자동 로그인
    var userFa = FirebaseAuth.instance.currentUser;
    if(userFa != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    }

    String? kakaoKa = await AuthService.getCurUserId();
    if(kakaoKa != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    logger.d('[glucocare_log] login init state.');
  }

  @override
  Widget build(BuildContext context) {
    if(_isKakaoLogind) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('로그인 중입니다.', style:
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),),
            SizedBox(height: 10,),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: Image.asset('assets/images/login_daol.png'),
              ),
              const SizedBox(height: 60,),
              Container(
                width: 280,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isKakaoLogind = true;
                    });
                    bool loginResult = await KakaoLogin.login();
                    if(loginResult) {
                      _isKakaoLogind = false;
                      _autoLogin();
                    } else {
                      setState(() {
                        _isKakaoLogind = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFFFBE300),
                    shadowColor: Colors.transparent,
                  ),
                  child: Image.asset('assets/images/login/kakao_login_large_narrow.png'),
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 280,
                height: 1,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1D1D1),
                ),
              ),
              const SizedBox(height: 30,),
              if(_isMasterLogin)
                Container(
                  width: 200,
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFF9F9F9),
                  ),
                  child: TextField(
                    controller: _idInputController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '마스터 계정 ID',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB4B4B4),
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              if(_isMasterLogin)
                const SizedBox(height: 20,),
              if(_isMasterLogin)
                SizedBox(
                  width: 200,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: _authCode,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28C2CE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                    child: const Text(
                      '마스터 계정 로그인',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 30,
        height: 30,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          onPressed: () {
            setState(() {
              if(_isMasterLogin) _isMasterLogin = false;
              else _isMasterLogin = true;
            });
          },
          child: const Icon(Icons.admin_panel_settings, color: Colors.grey,),
        ),
      )
    );
  }
}
