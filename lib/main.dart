import 'package:flutter/material.dart';
import 'package:test_app/src/app.dart';
import 'package:test_app/src/core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const EduApp());
}
