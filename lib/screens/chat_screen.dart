import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';

final _firestore = Firestore.instance;
FirebaseUser userLoggedIn;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();

  static const String id = 'chat_screen';
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String _message = "";
  final messageTextController = TextEditingController();

  void getCurrentUser() async {
    try {
      FirebaseUser user = await _auth.currentUser();
      if (user != null) {
        userLoggedIn = user;
        print(userLoggedIn.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var messages in snapshot.documents) {
        print(messages.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messagesStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStreamBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: messageTextController,
                      onChanged: (value) {
                        _message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'text': _message,
                        'sender': userLoggedIn.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubbles> list = [];
        for (var message in messages) {
          final String _sender = message.data['sender'];
          final String _messageText = message.data['text'];

          final Timestamp _time = message.data['timestamp'];

          final currentUser = userLoggedIn.email;
          var messageBubble = MessageBubbles(
            sender: _sender,
            text: _messageText,
            isMe: currentUser == _sender,
            time: DateFormat('kk:mm:a \n EEE d MMM').format(_time!=null?_time.toDate():DateTime.now()),
          );
          list.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: list,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ),
        );
      },
    );
  }
}

class MessageBubbles extends StatelessWidget {
  MessageBubbles(
      {@required this.text,
      @required this.sender,
      @required this.isMe,
      @required this.time});

  final String text;
  final String sender;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.4),
            child: Text(
              sender,
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ),
          Material(
            elevation: 8.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.black,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "$text",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 2),
            child: Text(
              time,
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: isMe ? Colors.black : Colors.blue[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
