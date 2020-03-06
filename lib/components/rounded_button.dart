import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final Color buttonColor;
  final Function onPressed;

  RoundedButton(
      {@required this.title,
      @required this.onPressed,
      @required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: GradientButton(
        shapeRadius: BorderRadius.circular(30.0),
        increaseWidthBy: 160,
        increaseHeightBy: 10,
        callback: onPressed,
        elevation: 5.0,
        child: MaterialButton(
          onPressed: null,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: "Lobster"),
          ),
        ),
      ),
    );
  }
}
