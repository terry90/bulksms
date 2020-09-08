import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Contact {
  String phone;
  List<String> variables;

  Contact(String phone, List<String> variables) {
    this.phone = phone;
    this.variables = variables;
  }
}

class BulkSms extends StatefulWidget {
  BulkSms({Key key, this.file}) : super(key: key);

  final File file;

  @override
  _BulkSmsState createState() => _BulkSmsState();
}

class _BulkSmsState extends State<BulkSms> {
  List<Contact> _contacts;
  String _message;

  _BulkSmsState() {
    this._contacts = List<Contact>();
  }

  readContacts() async {
    var contacts = List<Contact>();

    if (widget.file != null) {
      for (var line in await widget.file.readAsLines()) {
        var splitted = line.split(",");
        if (splitted.length > 0) {
          var phone = splitted[0];
          splitted.removeRange(0, 1);
          contacts.add(Contact(phone, splitted));
        }
      }
      setState(() {
        _contacts = contacts;
      });
    }
  }

  void _bulkSend() async {
    for (var contact in _contacts) {
      var msg = this._genMsg(this._message, contact.variables);
      await _sendSms(contact.phone, msg);
    }
  }

  String _genMsg(String template, List<String> vars) {
    vars.asMap().forEach((index, value) =>
        template = template.replaceAll('\$${index + 1}', value));
    return template;
  }

  @override
  void didUpdateWidget(BulkSms old) {
    readContacts();
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _padY(Text('Message')),
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (value) => this._message = value,
          decoration: new InputDecoration(
            hintText: "Enter your message",
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              child: FittedBox(
                child: IconButton(
                  onPressed: _bulkSend,
                  icon: Icon(Icons.send),
                  tooltip: 'Send messages',
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
        ),
        _padY(Text('Contacts')),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(16.0),
            children: this._contacts.map((e) => _item(e)).toList(),
          ),
        ),
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

Container _item(Contact c) => Container(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [_padRight(Text(c.phone))] +
              c.variables.map((v) => _padRight(Text(v))).toList(),
        ),
      ),
    );

Padding _padY(Widget w) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: w,
    );

Padding _padX(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: w,
    );

Padding _padRight(Widget w) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: w,
    );
