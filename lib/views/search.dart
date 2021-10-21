import 'package:airindia/helper/constants.dart';
import 'package:airindia/models/user.dart';
import 'package:airindia/services/database.dart';
import 'package:airindia/views/chat.dart';
import 'package:airindia/views/chatrooms.dart';
import 'package:airindia/views/requests.dart';
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
  bool toogleRequest = false;

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
                searchResultSnapshot.documents[index].data["designation"],
                searchResultSnapshot.documents[index].data["companyName"],
              );
            })
        : Container();
  }

  // sendMessage(String userName) {
  //   List<String> users = [Constants.myName, userName];

  //   String chatRoomId = getChatRoomId(Constants.myName, userName);

  //   Map<String, dynamic> chatRoom = {
  //     "users": users,
  //     "chatRoomId": chatRoomId,
  //     "connected": false,
  //   };

  //   databaseMethods.addChatRoom(chatRoom, chatRoomId);

  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Chat(
  //                 chatRoomId: chatRoomId,
  //                 userName: userName,
  //               )));
  // }

  sendRequest(String userName) {
    List<String> users = [Constants.myName, userName];

    String requestId = getChatRoomId(Constants.myName, userName);

    Map<String, dynamic> request = {
      "users": users,
      "requestId": requestId,
      "connected": false,
    };

    toogleRequest
        ? databaseMethods.addChatRoom(request, requestId)
        : databaseMethods.delRequest(requestId);
  }

  Widget userTile(
      String userName, String userEmail, String designation, String company) {
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
                  designation + " , " + company,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  toogleRequest = !toogleRequest;
                });
                sendRequest(userName);
                toogleRequest
                    ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request Sent'),
                        action: SnackBarAction(
                          label: 'Go to Home',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ))
                    : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request Widrawed'),
                        action: SnackBarAction(
                          label: 'Go to Home',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ));
              },
              child: toogleRequest
                  ? Icon(
                      Icons.highlight_off_rounded,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.green,
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
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: false,
      ),
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
