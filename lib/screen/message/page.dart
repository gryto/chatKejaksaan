import 'dart:convert';
import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../device_utils.dart';
import '../../src/api.dart';
import '../../src/preference.dart';
import '../../src/toast.dart';
import '../notifcations/page.dart';
import 'component/call_view.dart';
import 'component/message_view.dart';
import 'package:http/http.dart' as http;

class MessageListPage extends StatefulWidget {
  final String id;
  MessageListPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  RxInt activeIndex = 1.obs;

  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  List listDataRoom = [];
  String dataRoomId = "";
  String dataRoomUserId = "";
  List listChat = [];
   List<String> dataRoomIdList = []; // List to store roomcode strings

  String fullname = "";
  int userId = 0;
  var offset = 0;
  var limit = 10;
  String noHp = "";

  int pageIndex = 0;

  List pages = [
    const CallViewWidget(),
    const NotificationsPage(),
  ];

  @override
  void initState() {
    getData();
    // getDataRoom(widget.id);
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.chatPartner;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        var content = json.decode(response.body);
        for (int i = 0; i < content['data'].length; i++) {
          listData.add(content['data'][i]);
          print("listData");
          print(listData);
        }
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

  // getDataRoom(id) async {
  //   try {
  //     var accessToken = await sharedPref.getPref("access_token");
  //     var url = ApiService.chatRoomId;
  //     var uri = "$url/$id";
  //     var bearerToken = 'Bearer $accessToken';
  //     var response = await http.get(Uri.parse(uri),
  //         headers: {"Authorization": bearerToken.toString()});
  //     var content = json.decode(response.body);

  //     print("dataroom");
  //     print(uri);
  //     print(response.statusCode);
  //     print(content);
  //     print(content['status']);

  //     if (content['status'] == "200") {
  //       // var content = json.decode(response.body);
  //       // for (int i = 0; i < content['data'].length; i++) {
  //       //   listDataRoom.add(content['data'][i]);
  //       // 

  //       setState(() {
  //         listDataRoom.add(content['data']);

  //       // listDataRoom = content['data'];
  //       print("listdataroom");
  //       print(listDataRoom);

  //        // Extract specific values like roomcode and add to dataRoomId
  //         String roomcode = content['data']['roomcode'];
  //         dataRoomIdList.add(roomcode);

  //         print("listroomcode");

  //         print(dataRoomIdList);

  //       dataRoomId = content['data']['roomcode'];
  //       dataRoomUserId = content['data']['user_id'].toString();
  //       print(listDataRoom);
  //       print("dataroomid");
  //       print(dataRoomId);
          
  //       });

        

  //     } else {
  //       toastShort(context, message);
  //     }
  //   } catch (e) {
  //     toastShort(context, e.toString());
  //   }

  //   setState(() {
  //     isProcess = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: DeviceUtils.getScaledHeight(context, 1),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backChatGroundColor,
        ),
        child: SingleChildScrollView(
            child: MessageViewWidget(data: listData, senderId: widget.id, )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Obx(
        () => activeIndex.value == 1
            ? SizedBox(
                width: 45,
                height: 45,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor:clrPrimary,
                    onPressed: () {},
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
