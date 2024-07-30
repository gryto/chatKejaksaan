import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import '../gen/assets.gen.dart';

class VideoMessage extends StatelessWidget {
  const VideoMessage({super.key, });
  // final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(Assets.images.user2.path),
              ),
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: clrPrimary,
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ));
  }
}
