import 'package:airindia/helper/constants.dart';
import 'package:airindia/helper/helperfunctions.dart';
import 'package:airindia/services/database.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class messageRequest extends StatefulWidget {
  String userName;
  messageRequest(this.userName);
  @override
  _messageRequestState createState() => _messageRequestState();
}

class _messageRequestState extends State<messageRequest> {
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String user = snapshot.data.documents[index].data['requestId']
                      .toString()
                      .replaceAll("_", "")
                      .replaceAll(Constants.myName, "");
                  List<dynamic> sendbyNameList =
                      snapshot.data.documents[index].data['users'];
                  final sendbyName = sendbyNameList[0];
                  return ChatRoomsTile(
                    userName: user,
                    chatRoomId:
                        snapshot.data.documents[index].data["requestId"],
                    connected: snapshot.data.documents[index].data["connected"],
                    sendByName: sendbyName,
                  );
                })
            : Container(
                child: Center(
                child: Text("Please Wait ..."),
              ));
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Requests",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: chatRoomsList(),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  bool connected;
  final String sendByName;

  ChatRoomsTile({
    this.userName,
    @required this.chatRoomId,
    this.connected,
    this.sendByName,
  });
  DatabaseMethods databaseMethods = new DatabaseMethods();
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.redAccent,
      elevation: 10,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.person),
        ),
        onTap: connected
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              chatRoomId: chatRoomId,
                              userName: userName,
                            )));
              }
            : () {},
        title: Text(userName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        subtitle: !(Constants.myName == sendByName)
            ? Text("has requested to connect")
            : Text("response pending"),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 10,
          children: Constants.myName == sendByName
              ? <Widget>[
                  IconButton(
                    onPressed: () {
                      databaseMethods.delRequest(chatRoomId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request Widrawn'),
                        action: SnackBarAction(
                          label: 'Go to Home',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ));
                    },
                    icon: Icon(Icons.highlight_off_rounded),
                    color: Colors.red,
                  ),
                ]
              : <Widget>[
                  IconButton(
                    onPressed: () {
                      databaseMethods.accRequest(chatRoomId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request Accepted'),
                        action: SnackBarAction(
                          label: 'Go to Home',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ));
                    },
                    icon: Icon(Icons.person_add_alt_1_rounded),
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: () {
                      databaseMethods.delRequest(chatRoomId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request Declined'),
                        action: SnackBarAction(
                          label: 'Go to Home',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ));
                    },
                    icon: Icon(Icons.person_remove_alt_1_rounded),
                    color: Colors.red,
                  )
                ],
        ),
      ),
    );
  }
}
