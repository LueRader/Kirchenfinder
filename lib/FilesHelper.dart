import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FilesHelper {
  static final FilesHelper _filesHelper = FilesHelper._();

  FilesHelper._();

  factory FilesHelper() {
    return _filesHelper;
  }


}