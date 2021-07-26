import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getyoutubecomment/GetApi.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_parser/youtube_parser.dart';

var videoUrl;
var videoId;
var commentErrorStatus;

class HomePage extends StatefulWidget {
  //const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var commentList = [];
  var commentorImage = [];
  var commentorName = [];
  
  getCommentData() async {
    var privateAPI = getApi(); //enter your own api key here.
    var link =
        "https://youtube.googleapis.com/youtube/v3/commentThreads?part=snippet&maxResults=100&order=relevance&videoId=$videoId&key=$privateAPI";

    final response = await http.get(Uri.parse(link));

    var jsonData;
    if (response.statusCode == 200) {
      setState(() {
        jsonData = json.decode(response.body);
        for (var c in jsonData["items"]) {
          if (!commentList.contains(
              c["snippet"]["topLevelComment"]["snippet"]["textOriginal"])) {
            commentList.add(
                c["snippet"]["topLevelComment"]["snippet"]["textOriginal"]);
            commentorImage.add(c["snippet"]["topLevelComment"]["snippet"]
                ["authorProfileImageUrl"]);
            commentorName.add(c["snippet"]["topLevelComment"]["snippet"]
                ["authorDisplayName"]);
          } else {
            commentErrorStatus =
                "Please enter valid video id or check api response.body";
          }
        }
      });
    }
  }

//for adding video id ui
  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              onChanged: (val) {
                setState(() {
                  videoUrl = val;
                });
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Enter valid url starting with https://",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  )),
            ),
            actions: <Widget>[
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.red,
                child: Text(
                  'Get Comments',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (!videoUrl.isEmpty) {
                    videoId = getIdFromUrl(videoUrl);
                    commentList = [];
                    commentorImage = [];
                    commentorName = [];
                    getCommentData();
                    Navigator.of(context).pop();
                    print(videoId);
                    videoUrl = "";
                  }
                },
              ),
            ],
          );
        });
  }

  //add video id button widget
  Widget floatAdd() => FloatingActionButton.extended(
        label: Text(
          "Video URL",
        ),
        icon: Icon(Icons.add),
        onPressed: () async {
          await showInformationDialog(context);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Youtube Comments"),
          centerTitle: true,
        ),
        floatingActionButton: floatAdd(),
        body: commentList.length == 0
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: commentList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(commentorImage[index]),
                      title: Text(
                        "${commentList[index]}",
                      ),
                      subtitle: Text(
                        "@ ${commentorName[index]}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                )));
  }
}
