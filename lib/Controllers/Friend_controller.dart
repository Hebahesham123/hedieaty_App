import 'package:hediaty_appp/Models/Friend_model.dart';

class FriendController {
  final FriendModel _friendModel = FriendModel();

  // Add Friend Logic
  Future<void> addFriend(String currentUserId, String friendId) async {
    // Save the friend relationship in SQLite
    await _friendModel.saveFriendToLocal(currentUserId, friendId);
    await _friendModel.saveFriendToLocal(friendId, currentUserId);

    // Save the friend relationship in Firestore
    await _friendModel.saveFriendToRemote(currentUserId, friendId);

    print("Friend added successfully.");
  }

  // Fetch Friends
  Future<List<String>> fetchFriends(String userId) async {
    return await _friendModel.fetchFriendsFromLocal(userId);
  }

  // Sync Friends
  Future<void> syncFriends(String userId) async {
    await _friendModel.syncFriends(userId);
  }

  // Search for Friend by Phone
  Future<Map<String, dynamic>?> searchFriendByPhone(String phone) async {
    return await _friendModel.searchFriendByPhone(phone);
  }
}
