import 'package:flutter/material.dart';
import 'package:mycms/objects/app.dart';
import 'package:mycms/pages/collections_page.dart';
import 'package:mycms/utils/utils.dart';

class AppCard extends StatefulWidget {
  final App app;

  const AppCard({Key? key, required this.app}) : super(key: key);

  @override
  _AppCardState createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final App app;

  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    app = widget.app;
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        value: 0.7,
        lowerBound: 0.7);
    animation = CurvedAnimation(curve: Curves.ease, parent: _controller);
    _controller.forward(from: 0.7);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        _controller.forward(from: 0.7);
      },
      onTapDown: (_) {
        _controller.reverse(from: 1);
      },
      onTapUp: (_) {
        _controller.forward(from: 0.7);
        Navigator.push(context,
            Utils.createRoute(CollectionsPage(app: app), Utils.RTL));
      },
      child: ScaleTransition(
        scale: animation,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      app.image,
                      fit: BoxFit.cover,
                      height: 150,
                      width: 150,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
