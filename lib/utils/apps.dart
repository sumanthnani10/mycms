import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mycms/objects/app.dart';

class Apps {
  static List<App> apps = [];

  static List appsMap = [
    {
      "id": "tictrac",
      "name": "Tic Trac",
      "play_store_link": "https://bit.ly/ticTrac",
      "image": "assets/app_images/tic_trac.png",
      "collections": ["users", "tracks", "tweets", "announcements", "payments", "passes"],
      "objects": {
        "user": {
          "_id": "MongoDB Doc ID",
          "uid": "User ID",
          "created": "User Account Creation Time",
          "last_login": "User Last Login Time",
          "name": "User Name",
          "phone": "User Phone Number",
          "notifs": "User Notification Tokens",
          "vers": "User Used Versions"
        },
        "tracks": {
          "_id": "MongoDB Doc ID",
          "id": "Track ID",
          "at": "Theatre Name with Region",
          "last_updated": "Last Update Time",
          "movie": "Movie Name with Format",
          "on": "Movie Track Date",
          "region": "Region Name with Code",
          "start": "Track STart Time",
          "status": "Track Status",
          "uid": "User ID"
        },
        "tweets": {
          "_id": "MongoDB Doc ID",
          "id": "Track ID",
          "at": "Theatre Name with Region",
          "time": "Tweet Time",
          "for": "Movie Name with Format",
          "on": "Movie Track Date",
          "reg": "Region Name with Code",
        },
        "announcements": {
          "_id": "MongoDB Doc ID",
          "text": "Content",
          "image": "Image",
          "created": "Created on",
          "regs": "Regions Name with Code",
        },
        "payments": {
          "_id": "MongoDB Doc ID",
          'success': "success",
          'amount': "amount",
          'created': "created",
          'updated': "updated",
          'user_id': "userId",
          'receipt_id': "receiptId",
          'order_id': "orderId",
          'product': "product",
          'product_id': "productId",
          'status': "status",
          'pg_data': "pgData",
          'notes': "notes",
        },
        "passes": {
          "_id": "MongoDB Doc ID",
          'active': "active",
          'image': "image",
          'name': "name",
          'header': "header",
          'description': "description",
          'movie_id': "movieId",
          'movie_name': "movieName",
          'valid_from': "validFrom",
          'cost': "cost",
        }
      },
      "server_type": "https",
      "server_domain": "",
      "server_path": "",
      "apis": {
        "getCollection": "/getCollection",
        "getRegions": "/getRegions",
        "getMovies": "/getMovies",
        "getTheatres": "/getTheatres",
        "addUser": "/addUser",
        "getUser": "/getUser",
        "updateLastLogin": "/updateLastLogin",
        "addTrack": "/addTrack",
      },
    }
  ];

  static init() {
    apps.clear();
    final domain = dotenv.env['SERVER_DOMAIN'] ?? '';
    final serverType = dotenv.env['SERVER_TYPE'] ?? 'https';
    final serverPath = dotenv.env['SERVER_PATH'] ?? '';
    for (var i in appsMap) {
      final map = Map<String, dynamic>.from(i as Map);
      map['server_domain'] = domain;
      map['server_type'] = serverType;
      map['server_path'] = serverPath;
      apps.add(App.fromJson(map));
    }
    return;
  }
}
