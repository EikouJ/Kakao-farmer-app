import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kakao_farmer/models/notification.dart' as ModelNotification;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String apiHead = Glob.apiHead;
  WebSocketChannel? channel;

  static const _pageSize = 5;
  final PagingController<int, ModelNotification.Notification>
      _pagingController = PagingController(firstPageKey: 0);

  List<ModelNotification.Notification> allNotifications = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(Glob.wsUrl);

    _pagingController.addPageRequestListener((pageKey) {
      _fetchAllNotifications().then((_) {
        _fetchPage(pageKey);
      });
    });

    channel!.sink.add(jsonEncode({
      "type": "authenticate",
      "userId": Glob.userId,
      "status": Glob.userStatus
    }));

    channel!.stream.listen((message) {
      print(message);
      dynamic datas = jsonDecode(message);
      if (datas["type"] == "notification") {
        setState(() {
          _fetchAllNotifications();
          _pagingController.refresh();
        });
      }
    });

    _readAllNotifications();
  }

  Future<void> _fetchAllNotifications() async {
    try {
      allNotifications = await _loadNotifications();
    } catch (error) {
      print("\n\n Error fetch all notifications");
      print(error);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          allNotifications.skip(pageKey * _pageSize).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<ModelNotification.Notification>> _loadNotifications() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/notifications/"),
      headers: <String, String>{
        "Content-type": "application/json;charset=UTF-8",
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      List<ModelNotification.Notification> notifications = body
          .map((dynamic item) => ModelNotification.Notification.fromJson(item))
          .toList();

      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }
  /*void sendMessage() {
    setState(() {
      channel!.sink.add("New Message");
    });
  }*/

  String addZeroBefore(int data) {
    return "${data < 10 ? "0$data" : data}";
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${addZeroBefore(dateTime.day)}-${addZeroBefore(dateTime.month)}-${dateTime.year}  ${addZeroBefore(dateTime.hour)}:${addZeroBefore(dateTime.minute)}';
  }

  @override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: PagedListView<int, ModelNotification.Notification>(
            pagingController: _pagingController,
            builderDelegate:
                PagedChildBuilderDelegate<ModelNotification.Notification>(
              itemBuilder: (context, notification, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        notification.title!,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(notification.content!),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Text(formatDate(notification.date!))],
                      )
                    ],
                  ),
                  tileColor: notification.readAt == null
                      ? Colors.green.withAlpha(60)
                      : Colors.grey.withAlpha(60),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteNotification(notification.id!);
                    },
                  ),
                ),
              ),
            )));
  }

  // When open notifications screen, all unread notifications are set as read
  Future<void> _readAllNotifications() async {
    final token = Glob.token;

    final response = await http.patch(
      Uri.parse("$apiHead/notifications/read-all"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      /*Glob.channel!.sink.add(jsonEncode({
        "type": "send_notification",
        "targetId": Glob.userId,
        "title": "Read All notifications",
        "content": "Read All"
      }));*/
    } else {
      throw Exception('Failed to read all the notifications');
    }
  }

  Future<void> _deleteNotification(int id) async {
    final token = Glob.token;

    final response = await http.delete(
      Uri.parse("$apiHead/notifications/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      channel!.sink.add(jsonEncode({
        "type": "send_notification",
        "targetId": Glob.userId,
        "title": "Delete Notification",
        "content": "Delete"
      }));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("notification supprimée avec succès")),
      );
    } else {
      throw Exception('Failed to delete notification');
    }
  }
}
