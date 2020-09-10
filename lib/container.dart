import 'dart:io';
import 'package:bulksms/models/contact.dart';
import 'package:bulksms/contacts.dart';
import 'package:bulksms/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BulkSms extends StatefulWidget {
  BulkSms({Key key}) : super(key: key);

  @override
  BulkSmsState createState() => BulkSmsState();
}

class BulkSmsState extends State<BulkSms> {
  List<ContactGroup> _contacts;
  double _progress;
  String _message;

  setGroups(List<ContactGroup> list) {
    this._contacts = list;
    (context as Element).markNeedsBuild();
  }

  BulkSmsState() {
    this._progress = 0.0;
    this._contacts = List<ContactGroup>();
    loadAllGroups().then(setGroups);
  }

  addContacts(File file) {
    askGroupName(context, (String groupName) {
      this.setState(() {
        this._contacts.add(ContactGroup.fromCSV(groupName, file));
      });
    });
  }

  Future<bool> checkPermissions() async {
    if (!(await Permission.sms.isGranted)) {
      await Permission.sms.request();
    }
    return Permission.sms.isGranted;
  }

  void _bulkSend() async {
    final smsToSend = _contacts
        .where((e) => e.active)
        .fold(0.0, (v, group) => group.contacts.length + v);
    var current = 0;
    setState(() {
      _progress = 0.0;
    });
    if (!(await checkPermissions())) {
      final snackBar = SnackBar(
          content: Text('Unable to send the messages without permission'));
      Scaffold.of(this.context).showSnackBar(snackBar);
      return;
    }
    for (var group in _contacts) {
      if (group.active)
        for (var contact in group.contacts) {
          current += 1;
          var msg = this._genMsg(this._message, contact.variables);
          await _sendSms(contact.phone, msg);
          setState(() {
            _progress = current / smsToSend;
          });
          await Future.delayed(Duration(seconds: 1));
        }
    }
  }

  updateContacts(List<ContactGroup> contacts) {
    setState(() {
      this._contacts = contacts;
    });
  }

  String _genMsg(String template, List<String> vars) {
    vars.asMap().forEach((index, value) =>
        template = template.replaceAll('\$${index + 1}', value));
    return template;
  }

  askGroupName(context, Function cb) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Name the contacts'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter the name"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () {
                  Navigator.of(context).pop();
                  cb(_textFieldController.value.text);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        pad(Text('Message')),
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (value) => this._message = value,
          decoration: new InputDecoration(
            hintText: "Enter your message",
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        LinearProgressIndicator(
          value: _progress,
        ),
        Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              child: FittedBox(
                child: IconButton(
                  onPressed: _bulkSend,
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  tooltip: 'Send messages',
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
        ),
        pad(Text('Contacts')),
        new Contacts(
            contacts: this._contacts, updateContacts: this.updateContacts),
      ],
    );
  }

  static const platform = const MethodChannel('flutter.native/sms');

  Future<void> _sendSms(String phone, String msg) async {
    print("SendSMS");
    try {
      final String result = await platform.invokeMethod(
        'send',
        <String, String>{
          'phone': phone,
          'msg': msg,
        },
      );
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}
