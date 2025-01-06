import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  late BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.black,
                size: 46.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  void dismiss() {
    Navigator.pop(ctx);
  }
}
