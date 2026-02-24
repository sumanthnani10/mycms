import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Utils {

  static Map appCollections = {};

  static const Offset RTL = Offset(1, 0);
  static const Offset LTR = Offset(-1, 0);
  static const Offset UTD = Offset(0, -1);
  static const Offset DTU = Offset(0, 1);

  static String generateId(String pref) {
    var chars =
        'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210';
    int charLength = chars.length;
    var t = DateTime.now();
    String id = pref;
    // id += chars[(t.year / 100).round()];
    id += chars[t.year % charLength];
    id += chars[t.month];
    id += chars[t.day];
    id += chars[t.hour];
    id += chars[t.minute];
    id += chars[t.second];
    id += chars[t.millisecond % charLength];
    id += chars[t.microsecond % charLength];
    return id;
  }

  static Route createRoute(dest, Offset dir) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => dest,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = dir;
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static httpPost(Map args) async {
    var domain = args["domain"];
    var path = args["path"];
    var body = args["body"];

    try {
      body["passd"] = dotenv.env['API_PASSWORD'] ?? '';
      var resp = await http.post(Uri.https(domain, path), body: body, );
      if (resp.statusCode == 200) {
        var r = jsonDecode(resp.body);
        if (r['success']) {
          return r[body["collection"]];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch(e) {
      print(e);
      return null;
    }
  }

  static showLoadingDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: kDebugMode,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(title)
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool>? showdialog(BuildContext context, String title,
      String message) async {
    FocusScope.of(context).unfocus();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
                // return true;
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool>? showSuccessDialog(BuildContext context, String title,
      String message, Color? color, Color bg, onOkPressed) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text(
            title,
            style: TextStyle(color: color ?? Colors.green),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: onOkPressed,
            ),
          ],
        );
      },
    );
  }

  static Future<bool>? showErrorDialog(
      BuildContext context, String title, String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static String formattedDateTime(int timestamp) {
    DateTime i = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][i.month-1]} ${(i.day).toString().padLeft(2, '0')}, ${i.year} at ${(i.hour).toString().padLeft(2, '0')}:${(i.minute).toString().padLeft(2, '0')}:${(i.second).toString().padLeft(2, '0')} ${i.timeZoneName} UTC${(i.timeZoneOffset.inMinutes~/60).toString().padLeft(2, '0')}:${(i.timeZoneOffset.inMinutes%60).toInt().toString().padLeft(2, '0')}";
  }

}