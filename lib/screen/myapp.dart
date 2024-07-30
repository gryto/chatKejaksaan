import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import '../launcher/launcher.dart';


class MyApp extends StatelessWidget {
  final String tkn;
  const MyApp({Key? key, 
  required this.tkn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     GetMaterialApp getXApp = GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
      primaryColor: clrPrimary
      ),
      home: LauncherPage(
        token: tkn
        ),
    );

    return getXApp;
    
    // return MaterialApp(
    //   title: 'CHAT',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData.light(),
    //   routes: {
    //     '/': (context) => const LauncherPage(),
    //   },
    // );
  }
}
