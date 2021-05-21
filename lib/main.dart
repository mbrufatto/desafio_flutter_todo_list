import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list/app/database/connection.dart';
import 'package:todo_list/app/database/database_adm_connection.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  DatabaseAdmConnection databaseAdmConnection = DatabaseAdmConnection();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(databaseAdmConnection);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(databaseAdmConnection);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFF9129),
        buttonColor: Color(0xFFFF9129),
        textTheme: GoogleFonts.robotoTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Container(),
      ),
    );
  }
}
