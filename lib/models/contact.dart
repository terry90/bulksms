import 'dart:io';

import 'package:bulksms/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';

String genFileName() {
  return randomAlphaNumeric(10);
}

class Contact {
  String phone;
  List<String> variables;

  Contact(String phone, List<String> variables) {
    this.phone = phone;
    this.variables = variables;
  }

  Contact.fromLine(String line) {
    var splitted = line.split(",");
    var phone = splitted[0];

    if (phone.length < 6)
      throw Exception("Bad contact, phone number < 6 characters");

    splitted.removeRange(0, 1);
    this.phone = phone;
    this.variables = splitted;
  }
}

class ContactGroup {
  String name;
  String fileName;
  bool active;
  bool expanded;
  List<Contact> contacts;

  ContactGroup(String name, String fileName, List<Contact> contacts) {
    this.fileName = fileName;
    this.name = name;
    this.contacts = contacts;
    this.active = false;
    this.expanded = false;
  }

  ContactGroup.fromCSV(String name, File file) {
    this.name = name;
    this.fileName = genFileName();
    this.active = true;
    this.expanded = false;
    this.contacts = List<Contact>();
    readContacts(file);
  }

  destroy() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = this.fileName;

    final file = File('$path/csvGroups/$fileName.csv');
    file.delete();
  }

  readContacts(file) async {
    var contacts = List<Contact>();

    if (file != null) {
      for (var line in await file.readAsLines()) {
        if (line == "") continue;

        try {
          contacts.add(Contact.fromLine(line));
        } catch (e) {
          final snackBar =
              SnackBar(content: Text('Bad CSV ! Try again with another file'));
          scaffoldKey.currentState.showSnackBar(snackBar);
        }

        this.contacts = contacts;
        this.persist();
      }
    }
  }

  persist() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = this.fileName;

    final file = File('$path/csvGroups/$fileName.csv');
    final content =
        contacts.map((e) => '${e.phone},${e.variables.join(",")}').join("\n");
    file.writeAsString('$name\n$content');
  }
}

Future<List<ContactGroup>> loadAllGroups() async {
  final List<ContactGroup> list = List<ContactGroup>();
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final files = Directory("$path/csvGroups").listSync();
  for (var file in files) {
    if (file.statSync().type == FileSystemEntityType.file) {
      list.add(await loadFromFile(file.path));
    }
  }
  return list;
}

Future<ContactGroup> loadFromFile(String path) async {
  final file = File(path);

  var contacts = List<Contact>();
  var lines = await file.readAsLines();
  final name = lines[0];
  lines.removeRange(0, 1);

  for (var line in lines) {
    if (line == "") break;

    try {
      contacts.add(Contact.fromLine(line));
    } catch (e) {
      final snackBar =
          SnackBar(content: Text('Bad CSV ! Try again with another file'));
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  return ContactGroup(name, basename(file.path).split(".csv")[0], contacts);
}
