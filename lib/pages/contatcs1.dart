import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:thegorgeousotp/firebasestorage/databsemethods.dart';
import 'package:thegorgeousotp/theme.dart';



class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Iterable<Contact> _contacts;
  // QuerySnapshot dbcontacts;
  List users = [];

  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
 TextEditingController searchController = new TextEditingController();
  @override
  void initState() {
    getContacts();
    super.initState();
  }


  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

   filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future<void> getContacts() async {
    
    final Iterable<Contact> contacts = await ContactsService.getContacts( withThumbnails: false , );
    
   Stream collectionStream = FirebaseFirestore.instance.collection('users').snapshots();

   await FirebaseFirestore.instance.collection("users").get().then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((result) {
      // print(result.data());
       final Map value = result.data();
    users = value.values.toList();
    
    print(value.values);
    print(users[1]);
    }
    );
   }
  
   );
   
 print(users);
    setState(() {
      _contacts = contacts;
    });
  
  }
    Icon actionIcon = new Icon(Icons.search);
  Widget appBarTitle = new Text("Select Contact");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.buttoncolor,
        title: appBarTitle,
        
        actions: [
            new IconButton(icon: actionIcon,onPressed:(){
          setState(() {
                     if ( this.actionIcon.icon == Icons.search){
                      this.actionIcon = new Icon(Icons.close);
                      this.appBarTitle = new TextField(
                        cursorColor: Colors.white,
                        autofocus: true,
                        decoration: new InputDecoration(
                          // prefixIcon: new Icon(Icons.search,color: Colors.white),
                          hintText: "Search...",
                          hintStyle: new TextStyle(color: Colors.white)
                        ),
                      );}
                      else {
                        this.actionIcon = new Icon(Icons.search);
                        this.appBarTitle = new Text("Select Contact");
                      }


                    });
        } ,),
        ],
      ),
      body: _contacts != null
         
          ? Container(
            child: Column(
              children: [

                Expanded(
                                  child: ListView.builder(
                    itemCount: _contacts.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      Contact contact = _contacts?.elementAt(index);
                      return contact.displayName!=null? ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                              leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage: MemoryImage(contact.avatar),
                                    )
                                  : CircleAvatar(
                                      child: Text(contact.initials()),
                                      backgroundColor: Theme.of(context).accentColor,
                                    ),
                              title:  Text(contact.displayName ),
                              //This can be further expanded to showing contacts detail
                              // onPressed().
                          
                            ) : SizedBox.shrink();
                          },
                        ),
                ),
              ],
            ),
          )
                            : Center(child: const CircularProgressIndicator()),
                      );
                    }
                  
                                     
}