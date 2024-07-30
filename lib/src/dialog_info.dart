import 'package:chat_kejaksaan/src/constant.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

onBasicAlertPressed(context, text, desc) {
  var alertStyle = AlertStyle(
    backgroundColor: Colors.white,
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleTextAlign: TextAlign.left,
    descStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    descTextAlign: TextAlign.left,
    animationDuration: const Duration(milliseconds: 300),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: const BorderSide(
        color: Colors.grey,
      ),
    ),
  );

  Alert(
    context: context,
    style: alertStyle,
    title: text,
    desc: desc,
    buttons: [
      DialogButton(
        onPressed: () => Navigator.pop(context),
        color: clrPrimary,
        radius: BorderRadius.circular(10.0),
        child: const Text(
          "TUTUP",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ],
  ).show();
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
