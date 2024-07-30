import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../src/constant.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';
import '../chat_room.dart';

class ChatRoomList extends StatefulWidget {
    final String receiverId, receiverName, senderId, receiverImage, hp, roomCodeId;

  const ChatRoomList({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.senderId,
    required this.receiverImage,
    required this.hp,
    required this.roomCodeId
    });

  @override
  State<ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String userId = "";
  String chatId = "";

  List<Map<String, dynamic>> chatMessages = [];
  String chatMessagesString = '';
  bool emojiShowing = false;

  TextEditingController controller = TextEditingController();

  List listDataRoom = [];

  File? _image;
  final picker = ImagePicker();
  String userpath = "";
  String photo = "";
  var imageData;
  var filename;

  final _formKey = GlobalKey<FormState>();
  FocusNode inputNode = FocusNode();
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }


  late IO.Socket socket;
  @override
  void initState() {
    
    initSocket();

    super.initState();
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
      String roomcode = widget.roomCodeId; // Ensure this is correct
      print("roomcode");
      print(roomcode);
      print("User ID: $userId");
      print("Room code: $roomcode");
      socket.emit('joinRoom', {'user_id': userId, 'roomcode': roomcode});
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

    socket.on('sendChatToClient', (data) {
      print("manaada");
      // print('Received message: $data');
      // print(data);
      // chatMessages = (data);
      // print(chatMessages);
      var content = json.decode(data);
      chatMessages = content;
      print(chatMessages);


      setState(() {
        chatMessages.add((data));
      });
    });

    socket.emit('fetchChatHistory', widget.senderId.toString());

    socket.on('chatHistory', (chatHistory) {
      print("Chat history received:");
      print(chatHistory);
      if (chatHistory is List) {
        setState(() {
          chatMessages.addAll(List<Map<String, dynamic>>.from(chatHistory));
        });
      } else {
        print('Invalid chat history format');
      }
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
      'roomcode': widget.roomCodeId,
    };

    print("ini validasi data sebelum kirim pesan");
    print(message);
    print(widget.senderId);
    print(widget.receiverId);
    print(widget.roomCodeId);

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



  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: 
      // SingleChildScrollView(
      //   child:
         Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ChatRoomHeader(
                  no: widget.receiverImage,
                  user: widget.receiverName,
                  hp: widget.hp),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     primary: false,
            //     shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     itemCount: chatMessages.length,
            //     itemBuilder: (context, index) {
            //       return buildMessage(chatMessages[index]);
            //     },
            //   ),
            // ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              height: MediaQuery.of(context).size.height * 0.80,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child:
                    // !isProcess ?
                    listingData(),

                // : loaderDialog(context),
              ),
            ),
            /////////////
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
      // ),
    );
  }

  Widget listingData() {
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
          var datetime ="datetime";
          // var datetime =
          //     dmy.format(DateTime.parse(row['chat']['sent_at']).toLocal());

          // Check if the message is from the current user
          // bool isCurrentUser = senderId == userChat;

          return ChatMessage(
            isCurrentUser: true,
            message: message,
            time: datetime,
          );
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: chatMessages.length,
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
}