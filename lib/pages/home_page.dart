import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/binding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mycms/cards/app_card.dart';
import 'package:mycms/objects/app.dart';
import 'package:mycms/utils/apps.dart';
import 'package:mycms/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool authorised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      showPinDialog();
    });
  }

  showPinDialog() async {
    final TextEditingController pinController = TextEditingController();
    final String correctPin = dotenv.env['APP_PIN'] ?? '';

    showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter PIN'),
              content: TextField(
                controller: pinController,
                obscureText: true, // To obscure the text
                keyboardType: TextInputType.text,
                onSubmitted: (v) {
                  if (v == correctPin) {
                    setState(() {
                      Apps.init();
                      authorised = true;
                      Navigator.pop(context);
                    });
                  } else {
                    Utils.showErrorDialog(context, "Wrong Password",
                        ""); // Return false if PIN is incorrect
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false if canceled
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (pinController.text == correctPin) {
                      setState(() {
                        Apps.init();
                        authorised = true;
                        Navigator.pop(context);
                      });
                    } else {
                      Utils.showErrorDialog(context, "Wrong Password",
                          ""); // Return false if PIN is incorrect
                    }
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Home"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: authorised?Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              children: List<Widget>.generate(Apps.apps.length, (i) {
                App app = Apps.apps[0];
                return AppCard(
                  app: app,
                );
              }),
            ),
          ),
        ):Center(
          child: ElevatedButton(onPressed: () {showPinDialog();}, child: Text("Login"),),
        ),
      ),
    );
  }
}
