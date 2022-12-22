import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';

class DetailPage extends StatelessWidget {

  const DetailPage({super.key, required this.church});

  final Church church;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        border: Border(),
        backgroundColor: Colors.black12,
        middle: Text('Detail'),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
        ),
      ),
      child: Center(
        child: Text(church.name),
      ),
    );
  }
}