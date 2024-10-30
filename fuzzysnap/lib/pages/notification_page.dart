import 'package:flutter/material.dart';
import 'package:fuzzysnap/service/addFriend/friend_requests_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

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
    List<Map<String, dynamic>> requests =
        await friendRequestsService.getFriendRequests();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: friendRequests.isEmpty
          ? const Center(
              child: Text(
              'Nothing here!',
              style: TextStyle(fontSize: 22),
            ))
          : ListView.builder(
              itemCount: friendRequests.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> request = friendRequests[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (request['profile_image'] != null &&
                            request['profile_image'].isNotEmpty)
                        ? NetworkImage(request['profile_image'])
                        : AssetImage("assets/images/avatar.png"),
                  ),

                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${request['username'] ?? 'Unknown'} has sent you a Friend Request",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              _acceptFriendRequest(request);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: const Text(
                              'Confirm',
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _declineFriendRequest(request);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Decline'),
                          )
                          // IconButton(
                          //   icon: const Icon(Icons.check, color: Colors.green),
                          //   onPressed: () => _acceptFriendRequest(request),
                          // ),
                          // IconButton(
                          //   icon: const Icon(Icons.clear, color: Colors.red),
                          //   onPressed: () => _declineFriendRequest(request),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  // Nếu không muốn hiển thị subtitle, có thể bỏ đi
                  // subtitle: Text(request['email'] ?? ''),
                );
              },
            ),
    );
  }
}
