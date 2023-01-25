import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirche/model/church.dart';

class DetailPage extends StatelessWidget {

  const DetailPage({super.key, required this.church});

  final Church church;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text('Detail'),
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Text(church.name),
      ),
    );
  }
}