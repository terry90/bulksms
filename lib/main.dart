import 'dart:io';

import 'package:bulksms/container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void init() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  Directory("$path/csvGroups").create();
}

void main() {
  runApp(MyApp());
  init();
}

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
final GlobalKey<BulkSmsState> containerKey = GlobalKey();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulk SMS CSV',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Bulk SMS CSV'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.fileCb}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Function(File) fileCb;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void readFile() async {
    File file = await FilePicker.getFile(
        type: FileType.custom, allowedExtensions: ['csv']);

    containerKey.currentState.addContacts(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: BulkSms(key: containerKey),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: readFile,
        tooltip: 'Read CSV File',
        child: Icon(Icons.file_upload),
      ),
    );
  }
}
