import 'package:airindia/helper/authenticate.dart';
import 'package:airindia/helper/constants.dart';
import 'package:airindia/helper/helperfunctions.dart';
import 'package:airindia/helper/theme.dart';
import 'package:airindia/models/user.dart';
import 'package:airindia/services/auth.dart';
import 'package:airindia/services/database.dart';
import 'package:airindia/views/chat.dart';
import 'package:airindia/views/search.dart';
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
                    userName: snapshot.data.documents[index].data['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId:
                        snapshot.data.documents[index].data["chatRoomId"],
                  );
                })
            : Container();
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
    // String designation = "";
    // String companyName = "";
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({
    this.userName,
    @required this.chatRoomId,
  });

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
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chat(
                        chatRoomId: chatRoomId,
                      )));
        },
        title: Text(userName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        subtitle: Text("Designation ,CompanyName"),
        isThreeLine: true,
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
}
