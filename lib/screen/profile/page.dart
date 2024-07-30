import 'dart:convert';
import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../src/api.dart';
import '../../src/loader.dart';
import '../../src/logout.dart';
import '../../src/preference.dart';
import '../home.dart';
import 'component/detail.dart';

class SettingLogic extends StatefulWidget {
  final id;
  const SettingLogic({Key? key, this.id}) : super(key: key);

  @override
  State<SettingLogic> createState() => _SettingLogicState();
}

class _SettingLogicState extends State<SettingLogic> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];

  String fullname = "";
  int userId = 0;
  var formatter = DateFormat.yMMMMd('en_US');

  final ScrollController _scrollController = ScrollController();
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
      // var content = json.decode(response.body);

      if (response.statusCode == 200) {
        var content = json.decode(response.body);
        // print("datanya");
        // listData = content['data'];
        fullname = content['data']['fullname'];
        // print(fullname);
        // listData = content['data'];
        listData.add(content['data']);
        // print(listData);

        userId = content['data']['id'];
        print(userId);
      } else {
        // ignore: use_build_context_synchronously
        // onBasicAlertPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // onBasicAlertPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  String formatDate(String dateTimeString) {
    DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
    DateFormat outputFormat = DateFormat("dd-MM-yyyy");
    DateTime dateTime = inputFormat.parse(dateTimeString);
    String formattedDate = outputFormat.format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => MainTabBar(
                          id: userId.toString(),
                        )),
                (Route<dynamic> route) => false);

            // Get.to(() => MainTabBar(
            //       id: userId.toString(),
            //     ));
          },
          child: const Icon(Icons.arrow_back),
        ),
        backgroundColor: clrPrimary,
        scrolledUnderElevation: 0,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: settingPage(),
      ),
    );
  }

  Widget settingPage() {
    double h = MediaQuery.of(context).size.height - 20;
    double w = MediaQuery.of(context).size.width - 0;
    var mediaQueryHeight = MediaQuery.of(context).size.height;
    if (listData.isNotEmpty) {
      return ListView.separated(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) {
          var row = listData[index] as Map;

          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: (mediaQueryHeight / 6) + 100,
                    // height: (mediaQueryHeight / 6) + 100,
                    decoration: BoxDecoration(color: clrPrimary),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => InfoUser(
                            todo: row,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Row(
                                children: [],
                              ),
                              SizedBox(
                                // width: 50,
                                height: mediaQueryHeight / 7,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  fit: StackFit.expand,
                                  children: [
                                    CircleAvatar(
                                      // radius: 15,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          '${ApiService.folder}/' +
                                              row['image'],
                                          scale: 10,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: mediaQueryHeight / 7,
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          Get.to(
                                            () => InfoUser(
                                              todo: row,
                                            ),
                                          );
                                        },
                                        elevation: 2.0,
                                        fillColor: clrSecondary,
                                        padding: const EdgeInsets.all(5.0),
                                        shape: const CircleBorder(),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                row['fullname'] ?? "-",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                row['role_id'].toString() == "1"
                                    ? "Admin"
                                    : row['role_id'].toString() == "2"
                                        ? "Administrator"
                                        : "User",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text(
                  "NIP",
                  style: TextStyle(fontSize: 10, height: 1.8),
                ),
                subtitle: Text(
                  row['nip'] ?? " ",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  "Nama",
                  style: TextStyle(fontSize: 10, height: 1.8),
                ),
                subtitle: Text(
                  row['fullname'] ?? " ",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text(
                  "Email",
                  style: TextStyle(fontSize: 10, height: 1.8),
                ),
                subtitle: Text(
                  row['email'] ?? " ",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text(
                  "No. Handphone",
                  style: TextStyle(fontSize: 10, height: 1.8),
                ),
                subtitle: Text(
                  row['no_hp'] ?? " ",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const Divider(),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: w,
                  height: h / 14.7,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: clrPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      logoutDialog(context);
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 19, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              )
            ],
          );
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: listData.isEmpty ? 0 : listData.length,
      );
    } else {
      // return Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 10),
      //   child: SizedBox(
      //     width: w,
      //     height: h / 14.7,
      //     child: ElevatedButton(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: AppColors.primaryColor,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //       onPressed: () async {
      //         logoutDialog(context);
      //       },
      //       child: const Text(
      //         "Logout",
      //         style: TextStyle(fontSize: 19, color: Colors.white),
      //       ),
      //     ),
      //   ),
      // );
      return loaderDialog(context);
    }
  }
}
