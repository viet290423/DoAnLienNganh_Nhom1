// Delegate để tìm kiếm bạn bè
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/searchFriend/search_friend.dart';

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
      future: _searchFriendService.searchUser(query), // Gọi hàm tìm kiếm người dùng với từ khóa query
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Hiển thị vòng quay khi đang chờ dữ liệu
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred. Please try again.'));
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
                backgroundImage: NetworkImage(user['profile_image']), // Hiển thị ảnh đại diện
              ),
              title: Text(user['username']), // Hiển thị username
              trailing: IconButton(
                icon: const Icon(Icons.person_add), // Nút thêm bạn
                onPressed: () {
                  _searchFriendService.sendFriendRequest(user['uid']); // Gửi yêu cầu kết bạn
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend request sent to ${user['username']}.')),
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
      child: Text('Search for friends by email or username.'),
    );
  }
}
