import 'package:airindia/helper/authenticate.dart';
import 'package:airindia/helper/constants.dart';
import 'package:airindia/helper/helperfunctions.dart';
import 'package:airindia/helper/theme.dart';
import 'package:airindia/models/user.dart';
import 'package:airindia/services/auth.dart';
import 'package:airindia/services/database.dart';
import 'package:airindia/views/chat.dart';
import 'package:airindia/views/requests.dart';
import 'package:airindia/views/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
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
                  return ChatRoomsTile(
                    userName: snapshot.data.documents[index].data['requestId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId:
                        snapshot.data.documents[index].data["requestId"],
                    connected: snapshot.data.documents[index].data["connected"],
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
        title: Image.asset(
          "assets/images/logo.png",
          height: 40,
        ),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: chatRoomsList(),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.person_add_alt_rounded),
            heroTag: Text("Requests"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => messageRequest("")));
            },
          ),
          SizedBox(
            width: 15,
          ),
          FloatingActionButton(
            child: Icon(Icons.search),
            heroTag: Text("Search"),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
            },
          ),
        ],
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  bool connected;

  ChatRoomsTile({
    @required this.userName,
    @required this.chatRoomId,
    this.connected,
  });

  @override
  Widget build(BuildContext context) {
    return connected
        ? Card(
            shadowColor: Colors.redAccent,
            elevation: 10,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.person),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              chatRoomId: chatRoomId,
                              userName: userName,
                            )));
              },
              title: Text(userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text("is now connected"),
              isThreeLine: true,
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          )
        : Card(
            shadowColor: Colors.redAccent,
            elevation: 10,
            child: ListTile(
              enabled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.person),
              ),
              onTap: () {},
              title: Text(userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text("is not connected"),
              isThreeLine: true,
              trailing: Icon(
                Icons.block_rounded,
                color: Colors.red,
              ),
            ),
          );
  }
}
