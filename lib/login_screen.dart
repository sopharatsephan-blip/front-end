import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:trying_flutter/config/app_config.dart';
import 'package:trying_flutter/utils/date_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/screens/home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final _formKey = GlobalKey<FormState>();
final _usernameValueController = TextEditingController();
final _passwordValueController = TextEditingController();




class _LoginScreenState extends State<LoginScreen> {

Future <(bool, String, String)> _authenRequest() async{
  String username = _usernameValueController.text;
  DateTime now = DateTime.now();
  String formattedDateString = DateUtil.getFormattedDate(now);

  String combinedString = "$username&$formattedDateString";
  print(combinedString);

  String authenRequestString = sha256
  .convert(utf8.encode(combinedString))
  .toString();

  print(authenRequestString);

  final response = await http.post(
    Uri.parse('${AppConfig.apiBaseUri}/authen/authen_request'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'authen_request': authenRequestString}),
  );

  final json = jsonDecode(response.body);

  print(json);
  return (
    json["isError"] as bool,
    json["data"] as String,
    json["errorMessage"] as String,
  );
}

void _doLogin(BuildContext context) async {
  var (isError, authenToken, errorMessage) = await _authenRequest();

  if (isError) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(content: Text(errorMessage));
      },
    );
  } else {
    var result = await _accessRequest(authenToken);

    print(result);

    if (!result.isError) {
      // เปลี่ยนหน้าไปที่ Home screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(result.errorMessage));
        },
      );
    }
  }
}

Future<({bool isError, String data, String errorMessage})> _accessRequest(
  String authenToken,
) async {
  String username = _usernameValueController.text;
  String password = _passwordValueController.text;
  String passwordEncode = sha256.convert(utf8.encode(password)).toString();
  String combinedString = "$username&$passwordEncode&$authenToken";
  String authenSignature = sha256
      .convert(utf8.encode(combinedString))
      .toString();

  print(combinedString);
  print(authenSignature);

  final response = await http.post(
    Uri.parse('${AppConfig.apiBaseUri}/authen/access_request'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'authen_signature': authenSignature,
      'authen_token': authenToken,
    }),
  );

  final json = jsonDecode(response.body);

  print(json);

  if (!json["isError"]) {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("access_token", json["data"]["access_token"]);
    await prefs.setString("username", _usernameValueController.text);
    await prefs.setString("image_url", json["data"]["image_url"]);
  }

  return (
    isError: json["isError"] as bool,
    data: json["data"]["access_token"] as String,
    errorMessage: json["errorMessage"] as String,
  );
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. พื้นหลังไล่เฉดสีโทนน้ำเงินเข้ม-ม่วงคราม ลึกลับและทรงพลัง
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF03001e), // น้ำเงินเข้มเกือบดำ
                  Color(0xFF7303c0), // ม่วงคราม
                  Color(0xFF03001e), // ไล่กลับมามืดสนิท
                ],
              ),
            ),
          ),
          
          // ภาพกราฟิกอวกาศทางช้างเผือก (ปรับค่าความสว่างให้เข้ากับโทนน้ำเงิน)
          Positioned.fill(
            child: Opacity(
              opacity: 0.35, 
              child: Image.network(
                'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?q=80&w=2070', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. กล่องหน้าจอ Login ดีไซน์กระจกหรูหรา (โทน Deep Blue & Ice Cyan)
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  constraints: const BoxConstraints(maxWidth: 420), 
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1128).withOpacity(0.8), // กล่องน้ำเงินเข้มมืดสีกระจก
                    borderRadius: BorderRadius.circular(35),
                    // เส้นขอบเรืองแสงสีฟ้าไอซ์บลูบางๆ
                    border: Border.all(
                      color: const Color(0xFF00F2FE).withOpacity(0.3), 
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withOpacity(0.12), // แสงฟุ้งออร่าสีฟ้าอ่อนรอบกล่อง
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // หัวข้อ Login สีฟ้าสว่างสดใส
                      const Text(
                        "Login",
                        style: TextStyle(color: Color(0xFF00F2FE), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Login with your social account",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // ปุ่ม Social Media 
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: Colors.white.withOpacity(0.02),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata, color: Color(0xFFFF4B4B), size: 30), 
                                  SizedBox(width: 6),
                                  Text("Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: Colors.white.withOpacity(0.02),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center, // 👈 แก้ไขตรงนี้เรียบร้อยแล้วครับน้า!
                                children: [
                                  Icon(Icons.facebook, color: Color(0xFF2D88FF), size: 22), 
                                  SizedBox(width: 8),
                                  Text("Facebook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ช่องกรอก Email
                      Text("EMAIL ADDRESS", style: TextStyle(color: const Color(0xFF00F2FE).withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameValueController, 
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          prefixIcon: Icon(Icons.email_outlined, color: const Color(0xFF00F2FE).withOpacity(0.6), size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 1)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ช่องกรอก Password
                      Text("PASSWORD", style: TextStyle(color: const Color(0xFF00F2FE).withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordValueController, 
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF00F2FE).withOpacity(0.6), size: 20),
                          suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.white.withOpacity(0.3), size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 1)),
                        ),
                      ),
                      
                      // ปุ่ม Forget Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Color(0xFF00F2FE), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ปุ่ม SIGN IN ไล่เฉดสีฟ้าไอซ์บลู-น้ำเงินสว่าง
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00F2FE), 
                              Color(0xFF4FACFE), 
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F2FE).withOpacity(0.35), 
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _doLogin(context); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, 
                            foregroundColor: const Color(0xFF0A1128), 
                            shadowColor: Colors.transparent, 
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SIGN IN", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } 
}