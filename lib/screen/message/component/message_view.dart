// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import '../../../../constants/app_colors.dart';
// import '../../../../utils.dart';
// import '../../../../widgets/spacer/spacer_custom.dart';
// import '../../../src/api.dart';
// import '../../chat_room/chat_room.dart';

// // ignore: must_be_immutable
// class MessageViewWidget extends StatelessWidget {
//   final data;
//   String senderId;

//   MessageViewWidget({super.key, required this.data, required this.senderId});

//   @override
//   Widget build(BuildContext context) {
//     // Fungsi untuk mengubah selisih waktu menjadi format menit yang lalu
//     // String timeAgoFromDuration(Duration difference) {
//     //   if (difference.inSeconds < 60) {
//     //     return 'Baru saja';
//     //   } else if (difference.inMinutes < 60) {
//     //     return '${difference.inMinutes} menit yang lalu';
//     //   } else if (difference.inHours < 24) {
//     //     return '${difference.inHours} jam yang lalu';
//     //   } else {
//     //     return DateFormat('d MMMM yyyy').format(DateTime.now());
//     //   }
//     // }

//     if (data.isNotEmpty) {
//       return ListView.separated(
//         padding:
//             const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
//         primary: false,
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         itemBuilder: (_, index) {
//           var row = data[index];
//           final String jsonString = row['chats'][0]['sent_at'];

//           // Parse JSON ke objek DateTime
//           DateTime sentAt = DateTime.parse(jsonDecode(jsonString)['sent_at']);

//           // Hitung selisih waktu
//           Duration difference = DateTime.now().difference(sentAt);

//           // Ubah selisih waktu menjadi format yang diinginkan (menit yang lalu)
//           String timeAgo = timeAgoFromDuration(difference);

//           return ChatUserListCardWidget(
//             name: row['fullname'],
//             // ignore: prefer_interpolation_to_compose_strings
//             image: '${ApiService.folder}/image-user/' + row['image'],
//             isOnline: true,
//             message: row['chats'][0]['message_content'] == null
//                 ? Text(row['chats'][0]['message_content'].toString())
//                 : Row(
//                     children: [
//                       Icon(
//                         Icons.image,
//                         color: Colors.grey.shade400,
//                       ),
//                       Text(
//                         "Foto",
//                         style: SafeGoogleFont(
//                           'SF Pro Text',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           height: 1.2575,
//                           letterSpacing: 1,
//                           color: Colors.grey.shade500,
//                         ),
//                       )
//                     ],
//                   ),
//             unReadCount: '1',
//             isUnReadCountShow: false,
//             time: timeAgo,
//             onTap: () {
//               Get.to(ChatRoomPage(
//                   receiverId: row['id'].toString(),
//                   receiverName: row['fullname'],
//                   senderId: senderId,
//                   receiverImage: row['image'],
//                   hp: row['no_hp']));
//             },
//           );
//         },
//         separatorBuilder: (_, index) => const SizedBox(
//           height: 5,
//         ),
//         itemCount: data.isEmpty ? 0 : data.length,
//       );

//       // Column(
//       //   children: [
//       //     ChatUserListCardWidget(
//       //       name: 'Fleece Marigold',
//       //       image: Assets.images.user2.path,
//       //       isOnline: true,
//       //       message: 'Quisque blandit arcu quis turpis tincidunt facilisis…',
//       //       unReadCount: '1',
//       //       isUnReadCountShow: true,
//       //       time: '15 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),
//       //     ChatUserListCardWidget(
//       //       name: 'Gustav Purpleson',
//       //       image: Assets.images.user3.path,
//       //       isOnline: true,
//       //       message: 'QSed ligula erat, dignissim sit at amet dictum id, iaculis… ',
//       //       unReadCount: '2',
//       //       isUnReadCountShow: true,
//       //       time: '32 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),

//       //     ChatUserListCardWidget(
//       //       name: 'Chauffina Car',
//       //       image: Assets.images.user4.path,
//       //       isOnline: true,
//       //       message: 'Quisque blandit arcu quis turpis tincidunt facilisis…',
//       //       unReadCount: '1',
//       //       isUnReadCountShow: true,
//       //       time: '15 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),

//       //     ChatUserListCardWidget(
//       //       name: 'Piff Jenkins',
//       //       image: Assets.images.user5.path,
//       //       isOnline: false,
//       //       message: 'Duis eget nibh tincidunt odio id venenatis ornare quis…',
//       //       unReadCount: '1',
//       //       isUnReadCountShow: false,
//       //       time: '1 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),

//       //     ChatUserListCardWidget(
//       //       name: 'Justin Case',
//       //       image: Assets.images.user6.path,
//       //       isOnline: false,
//       //       message: 'Donec ut lorem tristique dui sit faucibus tincidunt….',
//       //       unReadCount: '1',
//       //       isUnReadCountShow: false,
//       //       time: '1 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),

//       //     ChatUserListCardWidget(
//       //       name: 'Ingredia Nutrisha',
//       //       image: Assets.images.user7.path,
//       //       isOnline: false,
//       //       message: 'Cras felis dui, facilisis sit amet dolor ac, tincidunt…',
//       //       unReadCount: '1',
//       //       isUnReadCountShow: false,
//       //       time: '1 min',
//       //       onTap: () {
//       //         Get.to(ChatRoomPage());
//       //       },
//       //     ),

//       //   ],
//       // );
//     } else {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(80.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.lock_clock,
//                   size: 90.0,
//                   color: Colors.grey.shade400,
//                 ),
//                 Text(
//                   "Ooops, Belum Ada User Dalam List Chat Anda!",
//                   style: TextStyle(
//                     fontSize: 20.0,
//                     color: Colors.grey.shade400,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 )
//               ],
//             ),
//           ),
//         ],
//       );
//     }
//   }
// }

// class ChatUserListCardWidget extends StatelessWidget {
//   const ChatUserListCardWidget({
//     super.key,
//     required this.name,
//     required this.image,
//     required this.isOnline,
//     required this.message,
//     required this.unReadCount,
//     required this.isUnReadCountShow,
//     required this.time,
//     this.onTap,
//   });

//   final String name;
//   final String image;
//   final bool isOnline;

//   final Widget message;
//   final String unReadCount;
//   final bool isUnReadCountShow;
//   final String time;
//   final Function()? onTap;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//         child: Row(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   width: 55,
//                   height: 55,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: NetworkImage(image), fit: BoxFit.fill),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 if (isOnline)
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: 14,
//                       height: 14,
//                       decoration: BoxDecoration(
//                         color: AppColors.backGroundColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(1.5),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.green,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const CustomWidthSpacer(
//               size: 0.03,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: SafeGoogleFont(
//                       'SF Pro Text',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                       height: 1.2575,
//                       letterSpacing: 1,
//                       color: const Color(0xff1e2022),
//                     ),
//                   ),
//                   message
//                   // Text(
//                   //   message,
//                   //   maxLines: 2,
//                   //   overflow: TextOverflow.ellipsis,
//                   //   style: SafeGoogleFont(
//                   //     'SF Pro Text',
//                   //     fontSize: 12,
//                   //     fontWeight: FontWeight.w400,
//                   //     height: 1.8333333333,
//                   //     letterSpacing: 1,
//                   //     color: Color(0xff77838f),
//                   //   ),
//                   // )
//                 ],
//               ),
//             ),
//             const CustomWidthSpacer(),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   time,
//                   textAlign: TextAlign.right,
//                   style: SafeGoogleFont(
//                     'SF Pro Text',
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                     height: 1.2575,
//                     letterSpacing: 1,
//                     color: const Color(0xff77838f),
//                   ),
//                 ),
//                 const CustomHeightSpacer(),
//                 if (isUnReadCountShow)
//                   Container(
//                     width: 43,
//                     height: 25,
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Center(
//                       child: Text(
//                         unReadCount,
//                         textAlign: TextAlign.center,
//                         style: SafeGoogleFont(
//                           'SF Pro Text',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           height: 1.2575,
//                           color: const Color(0xffffffff),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../utils.dart';
import '../../../../widgets/spacer/spacer_custom.dart';
import '../../../src/api.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';
import '../../chat_room/chat_room.dart';
import 'package:http/http.dart' as http;

class MessageViewWidget extends StatefulWidget {
  final List<dynamic> data;
  final String senderId;
  const MessageViewWidget({
    super.key,
    required this.data,
    required this.senderId,
  });

  @override
  State<MessageViewWidget> createState() => _MessageViewWidgetState();
}

class _MessageViewWidgetState extends State<MessageViewWidget> {
  SharedPref sharedPref = SharedPref();
  String accessToken = "";

  String url = ApiService.chatRoom;
  String message = "";
  bool isProcess = true;
  List listDataRoom = [];
  String dataRoomId = "";

  //   @override
  // void initState() {
  //   // getDataRoom(row['id'].toString());
  //    // Make sure to call getDataRoom with the correct id
  //   // if (widget.data.isNotEmpty) {
  //   //   print("idinistate");
  //   //   print(widget.data.first['id'].toString());
  //   //   getDataRoom(widget.data.first['id'].toString());
  //   // }

  //   super.initState();
  // }

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
  //     // print(uri);
  //     // print(response.statusCode);
  //     // print(content);
  //     // print(content['status']);

  //     if (content['status'] == "200") {
  //       // var content = json.decode(response.body);
  //       // for (int i = 0; i < content['data'].length; i++) {
  //       //   listDataRoom.add(content['data'][i]);
  //       //

  //       setState(() {
  //         listDataRoom.add(content['data']);
  //         print("listdataroom");
  //         print(listDataRoom);

  //         dataRoomId = content['data']['roomcode'];

  //         print("roomid");
  //         print(dataRoomId);
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
    final DateFormat dmy = DateFormat("HH:mm");
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        var row = widget.data[index] as Map;
        


        final String jsonString = row['chats'][0]['sent_at'];
        DateTime sentAt = DateTime.parse(jsonString);

        // Hitung selisih waktu
        Duration difference = DateTime.now().difference(sentAt);

        // Ubah selisih waktu menjadi format yang diinginkan (menit yang lalu)
        String timeAgo = timeAgoFromDuration(difference);

        return ChatUserListCardWidget(
          name: row['fullname'],
          // ignore: prefer_interpolation_to_compose_strings
          image: '${ApiService.folder}/image-user/' + row['image'],
          isOnline: true,
          message: row['chats'][0]['message_content'] == null
              ? Text(row['chats'][0]['message_content'].toString())
              : Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Colors.grey.shade400,
                    ),
                    Text(
                      "Foto",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.grey.shade500,
                      ),
                    )
                  ],
                ),
          unReadCount: '1',
          isUnReadCountShow: false,
          time:
              // row['chats'][0]['sent_at'],
              timeAgo,
          onTap: () {
            Get.to(ChatRoomPage(
                // roomId: dataRoomId.toString(),
                // roomUserId: dataRoomUserId.toString(),
                receiverId: row['id'].toString(),
                receiverName: row['fullname'],
                senderId: widget.senderId,
                receiverImage: row['image'],
                hp: row['no_hp']));
          },
        );
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: widget.data.length,
    );
  }

  // Fungsi untuk mengubah selisih waktu menjadi format menit yang lalu
  String timeAgoFromDuration(Duration difference) {
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }
  }
}

// ignore: must_be_immutable
// class MessageViewWidget extends StatelessWidget {
//   final List<dynamic> data;
//   final String senderId, roomId,roomUserId;

//   MessageViewWidget({Key? key, required this.data, required this.senderId , required this.roomId,required this.roomUserId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final DateFormat dmy = DateFormat("HH:mm");
//     return ListView.separated(
//       padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
//       primary: false,
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemBuilder: (_, index) {
//         var row = data[index];

//         // var local = dmy.format(DateTime.parse(row['chats'][0]['sent_at']).toLocal());
//         //   var localDate = dmy.format(DateTime.parse(row['sent_at']).toLocal());
//         // var datetime = local.toString();

//         final String jsonString = row['chats'][0]['sent_at'];
//         // String dateString = "2024-03-05 09:37:36";
//         DateTime sentAt = DateTime.parse(jsonString);

//         // Parse JSON ke objek DateTime
//         // DateTime sentAt = DateTime.parse(jsonDecode(jsonString)(row['chats'][0]['sent_at']));

//         // Hitung selisih waktu
//         Duration difference = DateTime.now().difference(sentAt);

//         // Ubah selisih waktu menjadi format yang diinginkan (menit yang lalu)
//         String timeAgo = timeAgoFromDuration(difference);

//         return ChatUserListCardWidget(
//           name: row['fullname'],
//           // ignore: prefer_interpolation_to_compose_strings
//           image: '${ApiService.folder}/image-user/' + row['image'],
//           isOnline: true,
//           message: row['chats'][0]['message_content'] == null
//               ? Text(row['chats'][0]['message_content'].toString())
//               : Row(
//                   children: [
//                     Icon(
//                       Icons.image,
//                       color: Colors.grey.shade400,
//                     ),
//                     Text(
//                       "Foto",
//                       style: SafeGoogleFont(
//                         'SF Pro Text',
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         height: 1.2575,
//                         letterSpacing: 1,
//                         color: Colors.grey.shade500,
//                       ),
//                     )
//                   ],
//                 ),
//           unReadCount: '1',
//           isUnReadCountShow: false,
//           time:
//           // row['chats'][0]['sent_at'],
//           timeAgo,
//           onTap: () {
//             Get.to(ChatRoomPage(
//               roomId: roomId,
//               roomUserId: roomUserId,
//                 receiverId: row['id'].toString(),
//                 receiverName: row['fullname'],
//                 senderId: senderId,
//                 receiverImage: row['image'],
//                 hp: row['no_hp']));
//           },
//         );
//       },
//       separatorBuilder: (_, index) => const SizedBox(
//         height: 5,
//       ),
//       itemCount: data.length,
//     );
//   }

//   // Fungsi untuk mengubah selisih waktu menjadi format menit yang lalu
//   String timeAgoFromDuration(Duration difference) {
//     if (difference.inSeconds < 60) {
//       return 'Baru saja';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} menit yang lalu';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} jam yang lalu';
//     } else {
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//     }
//   }
// }

class ChatUserListCardWidget extends StatelessWidget {
  const ChatUserListCardWidget({
    required this.name,
    required this.image,
    required this.isOnline,
    required this.message,
    required this.unReadCount,
    required this.isUnReadCountShow,
    required this.time,
    this.onTap,
  });

  final String name;
  final String image;
  final bool isOnline;

  final Widget message;
  final String unReadCount;
  final bool isUnReadCountShow;
  final String time;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.fill),
                    shape: BoxShape.circle,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const CustomWidthSpacer(
              size: 0.03,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: const Color(0xff1e2022),
                    ),
                  ),
                  message
                ],
              ),
            ),
            const CustomWidthSpacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  textAlign: TextAlign.right,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff77838f),
                  ),
                ),
                const CustomHeightSpacer(),
                if (isUnReadCountShow)
                  Container(
                    width: 43,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        unReadCount,
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2575,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
