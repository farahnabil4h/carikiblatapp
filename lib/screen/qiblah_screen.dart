import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:qibla_finder/utils.dart';

class QiblahScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const QiblahScreen(
      {required this.latitude, required this.longitude, Key? key})
      : super(key: key);

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? _animationController;
  double begin = 0.0;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    super.initState();
  }

  @override
  void dispose() {
    _animationController
        ?.dispose(); // Dispose of the AnimationController's Ticker
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: StreamBuilder(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: Colors.white),
              );
            }

            final qiblahDirection = snapshot.data;
            final offset =
                Utils.getOffsetFromNorth(widget.latitude, widget.longitude);
            animation = Tween(begin: begin, end: offset * (pi / 180) * -1)
                .animate(_animationController!);
            begin = offset * (pi / 180) * -1;
            _animationController!.forward(from: 0);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${qiblahDirection!.direction.toInt()}°",
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: AnimatedBuilder(
                      animation: animation!,
                      builder: (context, child) => Transform.rotate(
                        angle: animation!.value,
                        child: Image.asset('assets/images/qibla.png'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
