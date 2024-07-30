import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import '../../device_utils.dart';
import '../../utils.dart';
import 'chat_bubble.dart';

class ReceivedMessage extends StatelessWidget {
  final bool isCurrentUser;
  final String message;
  final String time;

  const ReceivedMessage({
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
            alignment: Alignment.topLeft),
        child: Container(
          constraints: BoxConstraints(
              minWidth: 100,
              maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 20, top: 10, bottom: 10),
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
    );
  }
}
