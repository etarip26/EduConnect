import 'package:flutter/material.dart';
import 'routing/app_router.dart';

class EduApp extends StatelessWidget {
  const EduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
