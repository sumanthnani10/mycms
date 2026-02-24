import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mycms/utils/theme.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyCMS());
}

class MyCMS extends StatefulWidget {
  const MyCMS({Key? key}) : super(key: key);

  @override
  State<MyCMS> createState() => _MyCMSState();
}

class _MyCMSState extends State<MyCMS> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My CMS',
      theme: MyTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}