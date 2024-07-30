import 'dart:convert';
import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/api.dart';
import '../src/preference.dart';
import '../src/toast.dart';
import '../utils.dart';
import 'message/component/call_view.dart';
import 'profile/page.dart';
import 'message/page.dart';
import '../widgets/bottom_icon_widget.dart';
import 'package:http/http.dart' as http;

class MainTabBar extends StatefulWidget {
  final String id;
  const MainTabBar({Key? key, required this.id}) : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  SharedPref sharedPref = SharedPref();
  bool isProcess = false;
  int pageIndex = 0;
  String fullName = "";
  String typeUser = "";
  String path = "";
  String accessToken = "";
  String dateString = "";
  late final Function(int) callback;
  String message = "";
  List<Map<String, dynamic>> listData = [];
  List<Widget> pages = <Widget>[]; // Declare pages here

  String fullname = "";
  late int userId = 0;

  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getData(widget.id);
    super.initState();
  }

  getData(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.detailUser;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          var content = json.decode(response.body);

          fullname = content['data']['fullname'];
          listData.add(content['data']);
          userId = content['data']['id'];
          path = content['data']['image'];
          pages = [
            MessageListPage(id: userId.toString()),
            const CallViewWidget(),
            // const NotificationsPage(),
          ];
        });
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: clrPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Connectify",
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2575,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => SettingLogic(id: widget.id));
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                            '${ApiService.folder}/$path',
                            scale: 10,
                          ),
                          fit: BoxFit.fill),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: pages[pageIndex],
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: AppColors.lightBack,
        margin: const EdgeInsets.only(top: 2, right: 0, left: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomIconWidget(
              title: 'Darurat',
              iconName: Icons.chat,
              iconColor: pageIndex == 0
                  ? Theme.of(context).primaryColor
                  : AppColors.gray,
              tap: () {
                setState(() {
                  pageIndex = 0;
                });
              },
            ),
            BottomIconWidget(
              title: 'Panggilan',
              iconName: Icons.call,
              iconColor: pageIndex == 1
                  ? Theme.of(context).primaryColor
                  : AppColors.gray,
              tap: () {
                setState(() {
                  pageIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
