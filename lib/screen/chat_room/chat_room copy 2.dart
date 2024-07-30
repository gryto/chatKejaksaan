import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/dialog_info.dart';
import '../../src/preference.dart';
import '../../widgets/spacer/spacer_custom.dart';
import '../../widgets/received_message.dart';
import '../../widgets/sent_message.dart';

class ChatRoomPage extends StatefulWidget {
  final String receiverId, receiverName, senderId, receiverImage, hp, roomId;
  const ChatRoomPage({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.senderId,
    required this.receiverImage,
    required this.hp,
    required this.roomId,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  SharedPref sharedPref = SharedPref();
  late IO.Socket socket;
  TextEditingController controller = TextEditingController();
  // Stream<String> messagesStream = Stream.empty();
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get messagesStream => _streamController.stream;

  @override
  void initState() {
    super.initState();
    initSocketConnection();
  }

  Future<void> initSocketConnection() async {
    // Get accessToken from shared preferences
    String accessToken = await sharedPref.getPref("access_token");

    // Initialize Socket.IO connection with accessToken in extraHeaders
    socket = IO.io('http://paket7.kejaksaan.info:3019', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'token': accessToken}
    });

    socket.connect;
    socket.emit("/test", "HelloWorld");
    socket.onConnect((data) => print("Connected"));
    print(socket.connected);

    // Join room with user ID
    String userId = widget.senderId;
    String roomcode = widget.roomId;
    socket.emit('joinRoom', {'user_id': userId, 'roomcode': roomcode});

    // Event listener for receiving messages from server
    socket.on('sendChatToClient', (data) {
      print('Received message: $data');
      _streamController.add(data);
      // Update UI or perform any actions based on received message
    });

    // Event listener for receiving user list from server
    socket.on('userList', (data) {
      print('Received user list: $data');
      // Update UI or perform any actions based on received user list
    });

    // Create a stream to listen for incoming messages
    // messagesStream = socket.on<String>('message');
  }

  

  void sendMessage(String message) {
    socket.emit('sendMessage', message);
  }

  // @override
  // void dispose() {
  //   // Close Socket.IO connection when widget is disposed
  //   socket.dispose();
  //   super.dispose();
  // }

   @override
  void dispose() {
    // Disconnect from the Socket.IO server when the app is disposed
    socket.disconnect();

    //close stream
    _streamController.close();
    super.dispose();
  }


  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                onChanged: (value) {
                  if (socket.connected) {
                    sendMessage(value);
                  }
                },
                controller: controller,
                decoration: const InputDecoration(hintText: "Enter Message"),
              ),
            ),
            const SizedBox(height: 40),
            StreamBuilder<String>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ListTile(
                    title: Text("Received Message: ${snapshot.data ?? ""}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomHeader extends StatelessWidget {
  final String no, user, hp;
  const ChatRoomHeader(
      {Key? key, required this.no, required this.user, required this.hp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = "";

    _launchCaller() async {
      url = "tel:$hp";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15, top: 25, bottom: 5),
      // const EdgeInsets.fromLTRB(16, 48, 16, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  Assets.icons.leftIcon.path,
                  width: 16,
                  height: 16,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          NetworkImage('${ApiService.folder}/image-user/$no'),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                user,
                textAlign: TextAlign.center,
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: const Color(0xff3b566e),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _launchCaller();
            },
            child: Icon(
              Icons.phone,
              color: clrPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
