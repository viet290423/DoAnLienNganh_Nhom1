// import 'package:flutter/material.dart';
// import 'package:fuzzysnap/service/addFriend/friend_requests_service.dart';
// import 'package:fuzzysnap/provider/notification_provider.dart';

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final FriendRequestsService friendRequestsService = FriendRequestsService();
//   final NotificationProvider notificationProvider = NotificationProvider();

//   List<Map<String, dynamic>> friendRequests = [];

//   @override
//   void initState() {
//     super.initState();
//     _listenForFriendRequests();
//   }

//   void _listenForFriendRequests() {
//     friendRequestsService.getFriendRequestsStream().listen((newRequests) {
//       // Compare new requests with the existing list to detect new entries
//       if (newRequests.length > friendRequests.length) {
//         final newRequest = newRequests.last;
//         notificationProvider.showFriendRequestNotification(
//           newRequest['username'] ?? 'Someone',
//         );
//       }
//       setState(() {
//         friendRequests = newRequests;
//       });
//     });
//   }

//   void _acceptFriendRequest(Map<String, dynamic> request) async {
//     await friendRequestsService.acceptFriendRequest(request);
//   }

//   void _declineFriendRequest(Map<String, dynamic> request) async {
//     await friendRequestsService.declineFriendRequest(request);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         centerTitle: true,
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             fontSize: 20,
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       body: friendRequests.isEmpty
//           ? const Center(
//               child: Text(
//               'Nothing here!',
//               style: TextStyle(fontSize: 22),
//             ))
//           : ListView.builder(
//               itemCount: friendRequests.length,
//               itemBuilder: (context, index) {
//                 final request = friendRequests[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: (request['profile_image'] != null &&
//                             request['profile_image'].isNotEmpty)
//                         ? NetworkImage(request['profile_image'])
//                         : const AssetImage("assets/images/avatar.png")
//                             as ImageProvider,
//                   ),
//                   title: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${request['username'] ?? 'Unknown'} has sent you a Friend Request",
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               _acceptFriendRequest(request);
//                             },
//                             style: TextButton.styleFrom(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 40),
//                               foregroundColor: Colors.black,
//                               backgroundColor: Colors.white,
//                               side: const BorderSide(color: Colors.black),
//                             ),
//                             child: const Text('Confirm'),
//                           ),
//                           const SizedBox(width: 8),
//                           TextButton(
//                             onPressed: () {
//                               _declineFriendRequest(request);
//                             },
//                             style: TextButton.styleFrom(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 40),
//                               backgroundColor: Colors.black,
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Decline'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
