import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/addFriend/friend_equests.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  FriendRequestsService friendRequestsService = FriendRequestsService();
  List<Map<String, dynamic>> friendRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    List<Map<String, dynamic>> requests = await friendRequestsService.getFriendRequests();
    setState(() {
      friendRequests = requests;
    });
  }

  void _acceptFriendRequest(Map<String, dynamic> request) async {
    await friendRequestsService.acceptFriendRequest(request);
    _loadFriendRequests(); // Cập nhật lại danh sách sau khi chấp nhận
  }

  void _declineFriendRequest(Map<String, dynamic> request) async {
    await friendRequestsService.declineFriendRequest(request);
    _loadFriendRequests(); // Cập nhật lại danh sách sau khi xóa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu cầu kết bạn'),
      ),
      body: friendRequests.isEmpty
          ? Center(child: Text('Không có yêu cầu kết bạn.'))
          : ListView.builder(
              itemCount: friendRequests.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> request = friendRequests[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(request['profile_image'] ?? 'default_profile_image_url'),
                  ),
                  title: Text(request['username'] ?? 'Unknown'),
                  subtitle: Text(request['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptFriendRequest(request),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () => _declineFriendRequest(request),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
