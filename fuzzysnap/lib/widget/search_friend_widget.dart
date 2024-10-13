// Delegate để tìm kiếm bạn bè

import 'package:flutter/material.dart';
import 'package:fuzzysnap/service/search_friend_service.dart';

class FriendSearchDelegate extends SearchDelegate {
  final SearchFriendService _searchFriendService = SearchFriendService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Xóa nội dung tìm kiếm
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Đóng màn hình tìm kiếm
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Trả về một widget hiển thị kết quả tìm kiếm
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchFriendService
          .searchUser(query), // Gọi hàm tìm kiếm người dùng với từ khóa query
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Hiển thị vòng quay khi đang chờ dữ liệu
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text('An error occurred. Please try again.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        // Hiển thị danh sách người dùng tìm được
        final users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    user['profile_image']), // Hiển thị ảnh đại diện
              ),
              title: Text(user['username']), // Hiển thị username
              trailing: StatefulBuilder(
                builder: (context, setState) {
                  return IconButton(
                    icon: Icon(
                      user['isFriend']
                          ? Icons.person // Nếu đã là bạn
                          : (user['confirm'] ?? false)
                              ? Icons
                                  .person_add_disabled // Nếu yêu cầu đang chờ xác nhận
                              : Icons.person_add, // Nếu chưa gửi yêu cầu
                    ),
                    onPressed: () {
                      if (user['isFriend']) {
                        // Nếu đã là bạn bè
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${user['username']} đã là bạn bè.')),
                        );
                      } else if (user['confirm'] ?? false) {
                        // Nếu yêu cầu kết bạn đang chờ xác nhận
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Yêu cầu kết bạn tới ${user['username']} đang chờ xác nhận.')),
                        );
                      } else {
                        // Nếu chưa gửi yêu cầu kết bạn
                        _searchFriendService.sendFriendRequest(
                            user['uid']); // Gửi yêu cầu kết bạn
                        setState(() {
                          user['confirm'] =
                              true; // Cập nhật trạng thái là yêu cầu đang chờ xác nhận
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Yêu cầu kết bạn đã được gửi tới ${user['username']}.')),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Hiển thị gợi ý tìm kiếm khi người dùng nhập liệu
    return const Center(
      child: Text('Tìm kiếm bạn bè qua email hoặc tên người dùng.'),
    );
  }
}
