import 'package:bulksms/models/contact.dart';
import 'package:flutter/material.dart';

class Contacts extends StatelessWidget {
  const Contacts({Key key, this.contacts, this.updateContacts})
      : super(key: key);

  final List<ContactGroup> contacts;
  final Function updateContacts;

  deleteGroup(ContactGroup group, BuildContext context) {
    group.destroy();
    var index = this.contacts.indexOf(group);
    this.contacts.removeAt(index);
    this.updateContacts(this.contacts);
  }

  toggleGroup(ContactGroup group, bool value) {
    this.contacts[this.contacts.indexOf(group)].active = value;
    this.updateContacts(this.contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          this.contacts[index].expanded = !isExpanded;
          this.updateContacts(this.contacts);
        },
        children: this
            .contacts
            .map(
              (group) => ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: group.active,
                              onChanged: (bool value) =>
                                  toggleGroup(group, value),
                            ),
                            Text(group.name),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => deleteGroup(group, context),
                        )
                      ],
                    ),
                  );
                },
                body: Column(
                  children: group.contacts
                      .map((contact) => ListTile(
                            title: Text(contact.phone),
                            subtitle: Text(contact.variables.join(", ")),
                          ))
                      .toList(),
                ),
                isExpanded: group.expanded,
              ),
            )
            .toList(),
      ),
    );
  }
}
