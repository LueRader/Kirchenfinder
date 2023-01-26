import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kirche/model/church.dart';
import 'package:kirche/model/visit.dart';
import 'package:intl/date_symbol_data_local.dart';

class VisitDetailPage extends StatefulWidget {
  const VisitDetailPage({super.key, required this.visit});

  final Visit visit;

  @override
  _VisitDetailPageState createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {


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
        child: Text(
            DateFormat.yMd('de_DE').format(widget.visit.timestamp),
        ),
      ),
    );
  }
}