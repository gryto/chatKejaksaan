import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';

loaderDialog(BuildContext context) {
  return Center(
    child: Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
        ),
        CircularProgressIndicator(
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(clrPrimary),
        ),
      ],
    ),
  );
}