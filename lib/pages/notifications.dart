import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> notifications = [
    {
      "type": "image",
      "image": "https://via.placeholder.com/150",
      "text": "New role posted: Female, 30-40,...",
      "time": "7d"
    },
    {
      "type": "message",
      "text": "You have 2 new messages",
      "time": "7d"
    },
    {
      "type": "image",
      "image": "https://via.placeholder.com/150",
      "text": "New role posted: Male, 25–35, fun...",
      "time": "8d"
    },
    {
      "type": "message",
      "text": "You have 5 new messages",
      "time": "8d"
    },
    {
      "type": "image",
      "image": "https://via.placeholder.com/150",
      "text": "New role posted: Female, 20–30,...",
      "time": "10d"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101820),
      
      body: Column(
        children: [
          Container(
            color: Color(0xFF101820),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Unread"),
                Tab(text: "Read"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(3, (_) => _buildNotificationList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => Divider(color: Colors.transparent, height: 10),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: notification["type"] == "image"
              ? CircleAvatar(
                  backgroundImage: NetworkImage(notification["image"]),
                  radius: 24,
                )
              : CircleAvatar(
                  backgroundColor: Color(0xFF2C3A47),
                  radius: 24,
                  child: Icon(Icons.message, color: Colors.white),
                ),
          title: Text(
            notification["text"],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            notification["time"],
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
