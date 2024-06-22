import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return Center(
              child: Text('No messages found.'),
            );
          }

          if (chatSnapshots.hasError) {
            return Center(
              child: Text('Something went wrong...'),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
              padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessages[index].data();
                print('-----------------------------------');
                print(loadedMessages);
                //[Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot'
                // Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot', Instance of '_JsonQueryDocumentSnapshot']

                print('-----------------------------------');
                print(chatMessage);
                //{createdAt: Timestamp(seconds=1719051891, nanoseconds=761786000), userImage: https://firebasestorage.googleapis.com/v0/b/chat-app-48d16.appspot.com/o/user_images%2Fr0Ezdchnpvhm1uqQH1O19tthxOY2.jpg?alt=media&token=96b87247-b759-491b-a1b7-3ba8c6c3495f,
                // text: Aaa, userId: r0Ezdchnpvhm1uqQH1O19tthxOY2, username: kalki}
                print(chatMessage.length); //shows 5
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
                else {
                  return MessageBubble.first(userImage: chatMessage['userImage'], username: chatMessage['username'], message: chatMessage['text'], isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
