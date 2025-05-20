import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For timestamp formatting

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

enum NotificationFilter { all, read, unread }

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  void setFilter(NotificationFilter filter) {
    setState(() {
      _filter = filter;
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // final message = ModalRoute.of(context)?.settings.arguments;
    // RemoteMessage? remoteMessage;
    // if (message is RemoteMessage) {
    //   remoteMessage = message;
    // } else {
    //   remoteMessage = null;
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton<NotificationFilter>(
            onSelected: (NotificationFilter result) {
              setState(() {
                _filter = result;
              });
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<NotificationFilter>>[
                  const PopupMenuItem<NotificationFilter>(
                    value: NotificationFilter.all,
                    child: Text('All'),
                  ),
                  const PopupMenuItem<NotificationFilter>(
                    value: NotificationFilter.read,
                    child: Text('Read'),
                  ),
                  const PopupMenuItem<NotificationFilter>(
                    value: NotificationFilter.unread,
                    child: Text('Unread'),
                  ),
                ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Local filtering
          final filteredDocs =
              docs.where((doc) {
                final read = doc['read'] as bool? ?? false;
                switch (_filter) {
                  case NotificationFilter.read:
                    return read;
                  case NotificationFilter.unread:
                    return !read;
                  case NotificationFilter.all:
                  default:
                    return true;
                }
              }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("No notifications."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['read'] ?? false;

              return GestureDetector(
                onTap: () async {
                  if (!isRead) {
                    // Optimistically mark as read in UI
                    setState(() {
                      final docData = doc.data() as Map<String, dynamic>?;
                      if (docData != null) {
                        docData['read'] = true;
                      }
                    });

                    // Delay actual Firestore update
                    await Future.delayed(const Duration(milliseconds: 300));
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(doc.id)
                        .update({'read': true});
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isRead ? Icons.notifications_none : Icons.notifications,
                        color: isRead ? Colors.grey : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                             
                                  data['title'] ??
                                  'No title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              
                                  data['body'] ??
                                  'No content',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['timestamp'] != null
                                  ? formatTimestamp(data['timestamp'])
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
