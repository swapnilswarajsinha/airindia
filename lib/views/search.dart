import 'package:airindia/helper/constants.dart';
import 'package:airindia/models/user.dart';
import 'package:airindia/services/database.dart';
import 'package:airindia/views/chat.dart';
import 'package:airindia/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.documents[index].data["userName"],
                searchResultSnapshot.documents[index].data["userEmail"],
              );
            })
        : Container();
  }

  sendMessage(String userName) {
    List<String> users = [Constants.myName, userName];

    String chatRoomId = getChatRoomId(Constants.myName, userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
      // "designation":,
      // "companyName":,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  chatRoomId: chatRoomId,
                )));
  }

  Widget userTile(String userName, String userEmail) {
    return Card(
      elevation: 10,
      shadowColor: Colors.redAccent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                sendMessage(userName);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(24)),
                child: Text(
                  "Message",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchEditingController,
                            style: simpleTextStyle(),
                            decoration: InputDecoration(
                                hintText: "Search fellow passengers...",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              initiateSearch();
                            },
                            icon: Icon(Icons.search))
                        // GestureDetector(
                        //     onTap: () {
                        //       initiateSearch();
                        //     },
                        //     child: Container(
                        //       height: 40,
                        //       width: 40,
                        //       decoration: BoxDecoration(
                        //           gradient: LinearGradient(
                        //               colors: [
                        //                 const Color(0x36FFFFFF),
                        //                 const Color(0x0FFFFFFF)
                        //               ],
                        //               begin: FractionalOffset.topLeft,
                        //               end: FractionalOffset.bottomRight),
                        //           borderRadius: BorderRadius.circular(40)),
                        //       padding: EdgeInsets.all(12),
                        //       child: Icon(Icons.search),
                        //     ))
                      ],
                    ),
                  ),
                  Divider(),
                  userList()
                ],
              ),
            ),
    );
  }
}
