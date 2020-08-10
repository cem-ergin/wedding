import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "Bilinmiyor";
  get name => _name;
  set name(String name) {
    _name = name;
    notifyListeners();
  }
}
