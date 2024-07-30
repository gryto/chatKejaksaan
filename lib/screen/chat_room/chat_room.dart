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
import 'package:url_launcher/url_launcher.dart';
import '../../../gen/assets.gen.dart';
import '../../../utils.dart';
import '../../device_utils.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/preference.dart';
import '../../src/toast.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/spacer/spacer_custom.dart';
import '../../widgets/received_message.dart';
import '../../widgets/sent_message.dart';

class ChatRoomPage extends StatefulWidget {
  final String receiverId, receiverName, senderId, receiverImage, hp;
  const ChatRoomPage({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.senderId,
    required this.receiverImage,
    required this.hp,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final DateFormat dmy = DateFormat("HH:mm");
  final DateFormat dm = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  FocusNode inputNode = FocusNode();
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  File? _image;
  final picker = ImagePicker();
  String userpath = "";
  String photo = "";
  var imageData;
  var filename;
  FilePickerResult? result;
  String replyText = '';
  String messageReply = '';
  late final ValueChanged onSwipedMessage;
  bool recording = false;
  String authenticatedUserId = "";
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get messagesStream => _streamController.stream;
  String nomer = "", akun = "";

  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String userId = "";
  String chatId = "";

  String url = ApiService.chatRoom;
  String message = "";
  bool isProcess = true;
  List listData = [];
  List<Map<String, dynamic>> chatMessages = [];
  String chatMessagesString = '';
  bool emojiShowing = false;

  TextEditingController controller = TextEditingController();

  List listDataRoom = [];
  List listDataRoomHistory = [];
  String dataRoomId = "";
  String dataRoomUserId = "";
  List listChat = [];

  late ScrollController _listScrollController;
  bool _isVisible = true;

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  getDataHistory(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.chatHistory;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      print("dataroom");
      print(uri);
      print(response.statusCode);
      print(content);
      print(content['status']);

      if (content['status'] == "200") {
        setState(() {
          print("listdataroomHistory");
          listDataRoomHistory = content['data'];

          print(listDataRoomHistory);
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

  getDataRoom(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.chatRoomId;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      print("dataroom");
      print(uri);
      print(response.statusCode);
      print(content);
      print(content['status']);

      if (content['status'] == "200") {
        setState(() {
          print("listdataroom");
          listDataRoom.add(content['data']);

          print(listDataRoom);

          dataRoomId = content['data']['roomcode'];

          print("roomid");
          print(dataRoomId);

          if (dataRoomId.isNotEmpty) {
            initSocket();
          }
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

  void moveToSecondPage() async {
    // Get.to(() => CameraViewPage(
    //       path: _image,
    //       sender: widget.senderId,
    //       receiver: widget.receiverId,
    //       receiverName: widget.receiverName,
    //       receiverImage: widget.receiverImage,
    //       hp: widget.hp,
    //       roomId: '',
    //       roomUserId: '',
    //     ));
  }

  Future downloadPdf(context, fileUrl, filename) async {
    final output = await getDownloadPath(context);
    final savePath = '$output/$filename';

    download2(context, fileUrl, savePath);
  }

  Future download2(context, fileUrl, savePath) async {
    try {
      Response response = await Dio().get(
        fileUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);

      raf.writeFromSync(response.data);
      await raf.close();

      _onAlertButtonPressed(context, true, "File PDF berhasil di download");
    } catch (e) {
      _onAlertButtonPressed(context, false, e.toString());
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      (received / total * 100).toStringAsFixed(0);
    }
  }

  Future<String?> getDownloadPath(context) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      _onAlertButtonPressed(context, false, "Folder download tidak ditemukan");
    }

    return directory?.path;
  }

  _onAlertButtonPressed(context, status, message) {
    Alert(
      context: context,
      type: !status ? AlertType.error : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: clrPrimary,
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

// Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        _image = File(pickedFile.path);
        moveToSecondPage();
      });

      photo = pickedFile.name;

      userpath = _image as String;

      print(userpath);

      print(photo);
      print(_image);
    }
  }

// Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        _image = File(pickedFile.path);
        moveToSecondPage();
        // _image = pickedFile;
      });

      filename = pickedFile.name;
      print(filename);
      print(_image);
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  // Function to pick multiple files
  void pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        moveToSecondPage();

        // Process the selected files
        for (File file in files) {
          print('Selected file: ${file.path}');
          // Add your file processing logic here
          _image = File(file.path);
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  late IO.Socket socket;
  @override
  void initState() {
    checkSession();

    super.initState();
  }

  checkSession() async {
    var aToken = await sharedPref.getPref("access_token");
    getDataRoom(widget.receiverId);
    getDataHistory(widget.receiverId);
    _listScrollController = ScrollController();

    // Tambahkan listener pada ScrollController
    _listScrollController.addListener(() {
      setState(() {
        // Periksa apakah posisi scroll sudah mencapai bagian paling bawah
        _isVisible = !(_listScrollController.position.pixels >=
            _listScrollController.position.maxScrollExtent);
      });
    });

    setState(() {
      accessToken = aToken;
    });
  }

  @override
  void dispose() {
    // Hapus listener pada saat widget di-dispose
    _listScrollController.dispose();
    super.dispose();
  }

  initSocket() async {
    // Fetch the access token
    String accessToken = await sharedPref.getPref("access_token");
    print("Access token: $accessToken");
    var bearerToken = 'Bearer $accessToken';
    print("tokenserever");
    print(bearerToken);

    // Create the socket instance
    socket = IO.io(
      'http://paket7.kejaksaan.info:3019',
      IO.OptionBuilder()
          .setTransports(['websocket']).setAuth({'token': bearerToken}).build(),
    );

    // Connect the socket
    socket.connect();

    // Set up event listeners
    socket.onConnect((_) {
      print('Connection established22');
      String userId = widget.senderId.toString();
      String roomcode = dataRoomId; // Ensure this is correct
      print("roomcode");
      print(roomcode);
      print("User ID: $userId");
      print("Room code: $roomcode");
      socket.emit('joinRoom', {'user_id': userId, 'roomcode': roomcode});
      print("fetchconnect");
      socket.emit('fetchChatHistory', widget.receiverId);
      print("fetchconnectberhasil");
    });

    socket.onDisconnect((_) {
      print('Connection Disconnected');
    });

    socket.onConnectError((err) {
      print('Connection Error: $err');
    });

    socket.onError((err) {
      print('Socket Error: $err');
    });

    socket.on('chatHistory', (chatHistory) {
      print("Chat history received:");
      print(chatHistory);
      chatMessages.add((chatHistory));
      print("chatmessagehistory");
      print(chatMessages);

      // if (chatHistory is List) {
      //   setState(() {
      //     // chatMessages.addAll(List<Map<String, dynamic>>.from(chatHistory));
      //     // chatMessages.add((chatHistory));
      //   });
      // } else {
      //   print('Invalid chat history format');
      // }
    });

    // if (widget.receiverId.isNotEmpty) {
    //   print("recevidnotempty");
    //   socket.emit('fetchChatHistory', widget.receiverId);

    //   socket.on('chatHistory', (chatHistory) {
    //     print("Chat history received:");
    //     print(chatHistory);
    //     // chatMessages.add((chatHistory));
    //     print("chatmessagehistory");
    //     print(chatMessages);

    //     if (chatHistory is List) {
    //       setState(() {
    //         // chatMessages.addAll(List<Map<String, dynamic>>.from(chatHistory));
    //         // chatMessages.add((chatHistory));
    //       });
    //     } else {
    //       print('Invalid chat history format');
    //     }
    //   });
    // }

    socket.on('sendChatToClient', (data) {
      print("manaada");
      print(data);

      setState(() {
        chatMessages.add((data));
        print("inichatmessage");
        print(chatMessages);
      });
    });
  }

  void sendMessage(String message) {
    message = controller.text.trim();
    if (message.isEmpty) return;
    Map messageMap = {
      'message_content': message,
      'sender_user_id': widget.senderId.toString(),
      'receiver_user_id': widget.receiverId.toString(),
      'attachment': null,
      'roomcode': dataRoomId,
    };

    print("ini validasi data sebelum kirim pesan");
    print(message);
    print(widget.senderId);
    print(widget.receiverId);
    print(dataRoomId);

    try {
      socket.emit('sendChatToServer', messageMap);
      print("ini isian apakah data udah kekirim");
      print(messageMap);
      print("receiveenya");
      controller.clear();
    } catch (e) {
      print("data tidak kekirim");
      toastShort(context, e.toString());
    }
  }

  // void sendPartnerId(String partnerId) {
  //   socket.emit('fetchChatHistory',partnerId);
  //   print("apakah ke printfecthchatnya");
  //   print(widget.receiverId);
  // }

  bool isDataReceived = false;

  void displayMessage(messageReceive) {
    print("Received Message: $messageReceive");
  }

  Widget buildMessage(Map<String, dynamic> message) {
    bool isOwnMessage = message['sender_user_id'] == widget.senderId;
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${message['sender_user_id']}:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message['message_content'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            if (message['image_url'] != null)
              Image.network(
                message['image_url'],
                height: 100,
                width: 100,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ChatRoomHeader(
                  no: widget.receiverImage,
                  user: widget.receiverName,
                  hp: widget.hp),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              height: MediaQuery.of(context).size.height * 0.80,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                controller: _listScrollController,
                child: Column(
                  children: [
                    listingDataRoom(widget.senderId),
                    listingData(widget.senderId),
                  ],
                ),

                // !isProcess ?
                //

                // : loaderDialog(context),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 0.68),
                      decoration: BoxDecoration(
                        color: AppColors.lightBack,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                emojiShowing = !emojiShowing;
                              });
                            },
                            child: Icon(
                              Icons.emoji_emotions,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.30),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  focusNode: inputNode,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: Colors.white54,
                                  controller: controller,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  onFieldSubmitted: (value) {
                                    if (socket.connected) {
                                      sendMessage(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    suffixIconColor: Colors.white54,
                                    filled: true,
                                    fillColor: AppColors.lightBack,
                                    hintText: 'Isi pesan ...',
                                    hintStyle:
                                        const TextStyle(color: Colors.black26),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              pickMultipleFiles();
                            },
                            child: Icon(
                              Icons.attach_file,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.40),
                            ),
                          ),
                          const SizedBox(width: kDefaultPadding / 4),
                          GestureDetector(
                            onTap: () {
                              showOptions();
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding / 35),
                  Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: GestureDetector(
                      onTap: () {
                        if (socket.connected) {
                          sendMessage(controller.text);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: clrPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        // Tentukan visibilitas floating button berdasarkan nilai _isVisible
        visible: _isVisible,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: GestureDetector(
            onTap: () {
              scrollListToEnd();
            },
            child: SizedBox(
              width: 30,
              height: 30,
              child: FittedBox(
                child: FloatingActionButton(
                  foregroundColor: clrBackground,
                  backgroundColor: clrBackgroundLight,
                  shape: const CircleBorder(),
                  onPressed: scrollListToEnd,
                  child: const Icon(
                    Icons.keyboard_double_arrow_down,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget listingData(String senderId) {
    // final widgetKey = GlobalKey();
    if (chatMessages.isNotEmpty) {
      return ListView.separated(
        padding:
            const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          // return buildMessage(chatMessages[index]);

          var row = chatMessages[index];
          print("isichat");
          print(row);
          print(row['chat']['sender_user_id'].toString());
          print(row['chat']['message_content'].toString());
          var userChat = row['chat']['sender_user_id'].toString();
          var message = row['chat']['message_content'].toString();
          var datetime =
              dmy.format(DateTime.parse(row['chat']['sent_at']).toLocal());

          // Check if the message is from the current user
          // bool isCurrentUser = senderId == userChat;

          if (senderId == userChat) {
            return SentMessage(
              isCurrentUser: true,
              message: message,
              time: datetime,
            );
          } else {
            return ReceivedMessage(
              isCurrentUser: false,
              message: message,
              time: datetime,
            );
          }
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: chatMessages.length,
      );
    } else {
      return const Center(
        child: Text(''),
      );
    }
  }

  Widget listingDataRoom(String senderId) {
    // final widgetKey = GlobalKey();
    if (listDataRoomHistory.isNotEmpty) {
      return ListView.separated(
        padding:
            const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          // return buildMessage(chatMessages[index]);

          var row = listDataRoomHistory[index];
          print("isichat");
          // print(row);
          print(row['sender_user_id'].toString());
          print(row['message_content'].toString());
          var userChat = row['sender_user_id'].toString();
          var message = row['message_content'].toString();
          var datetime =
              dmy.format(DateTime.parse(row['created_at']).toLocal());

          // Check if the message is from the current user
          // bool isCurrentUser = senderId == userChat;

          if (senderId == userChat) {
            return SentMessage(
              isCurrentUser: true,
              message: message,
              time: datetime,
            );
          } else {
            return ReceivedMessage(
              isCurrentUser: false,
              message: message,
              time: datetime,
            );
          }
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: listDataRoomHistory.length,
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: const Text("No data found"),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      );
    }
  }

  RelativeRect _getRelativeRect(GlobalKey key) {
    return RelativeRect.fromSize(
        _getWidgetGlobalRect(key), const Size(200, 200));
  }

  Rect _getWidgetGlobalRect(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    debugPrint('Widget position: ${offset.dx} ${offset.dy}');
    return Rect.fromLTWH(offset.dx / 3.1, offset.dy * 1.05,
        renderBox.size.width, renderBox.size.height);
  }
}

_launchCaller() async {
  const url = "tel:1234567";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class DummyWaveWithPlayIcon extends StatelessWidget {
  const DummyWaveWithPlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // rectanglesHz (0:577)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoSY (0:592)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglejqz (0:578)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle5ex (0:581)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRD2 (0:585)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglexye (0:590)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        Container(
          // rectangleSP2 (0:587)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleyNx (0:582)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleJg8 (0:579)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleEpg (0:593)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglez3A (0:586)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle8QG (0:589)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHHA (0:584)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle2Ve (0:598)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglenUp (0:591)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleGPz (0:588)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoep (0:583)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle9Tn (0:580)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHZz (0:594)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRw6 (0:595)
          width: 3,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglea3J (0:596)
          width: 3,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleifJ (0:597)
          width: 3,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Text(
          '01:3',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: const Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Image.asset(
          Assets.images.playIcon.path,
          width: 28,
          height: 28,
        )
      ],
    );
  }
}

class DateDevider extends StatelessWidget {
  const DateDevider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: 100, // OK
        height: 41, // OK
        decoration: const BoxDecoration(
          color: Color(0xffF2F3F6),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
            child: Text(
          'Today',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.193359375,
            letterSpacing: 1,
            color: const Color(0xff77838f),
          ),
        )),
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
            child: const Icon(
              Icons.phone,
              color: clrPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final bool isCurrentUser;
  final String message;
  final String time;

  const ChatMessage({
    Key? key,
    required this.isCurrentUser,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: CustomPaint(
        painter: ChatBubble(
            color: isCurrentUser ? clrPrimary : Colors.grey,
            alignment: Alignment.topRight),
        child: Container(
          constraints: BoxConstraints(
              minWidth: 100,
              maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Container(
      //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   padding: const EdgeInsets.all(12),
      //   decoration: BoxDecoration(
      //     color: isCurrentUser ? Colors.blue : Colors.grey,
      //     borderRadius: BorderRadius.circular(8),
      //   ),
      //   child:
      // ),
    );
  }
}

class ChatMessageReceive extends StatelessWidget {
  final bool isCurrentUser;
  final String message;
  final String time;

  const ChatMessageReceive({
    Key? key,
    required this.isCurrentUser,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
