import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hediaty_appp/Models/User_model.dart';
import 'package:hediaty_appp/Classes/User.dart';

class UserController {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final UserModel _userModel = UserModel();

  // Sign-Up Method
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String mobile,
    String preferences = '',
  }) async {
    try {
      // Firebase Authentication
      fb_auth.UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firebase UID
      String uid = userCredential.user!.uid;

      // Create User object
      User user = User(
        uid: uid,
        name: name,
        email: email,
        mobile: mobile,
        preferences: preferences,
      );

      // Save to Firestore
      await _userModel.saveToRemote(user);

      // Save to SQLite
      await _userModel.saveToLocal(user);

      print("Sign-up successful for ${user.name}");
    } catch (e) {
      print("Error during sign-up: $e");
      throw Exception("Sign-up failed");
    }
  }


  // Sign-In Method
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication
      fb_auth.UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch UID from Firebase
      String firebaseUid = userCredential.user!.uid;


      // Check local SQLite for the user
      User? user = await _userModel.getFromLocal(firebaseUid);



      if (user != null) {
        // User found locally
        return user;
      } else {
        // Fetch user from Firestore
        User? remoteUser = await _userModel.getFromRemote(firebaseUid);

        if (remoteUser != null) {
          // Save user locally
          await _userModel.saveToLocal(remoteUser);

          return remoteUser;
        }
      }
    } catch (e) {
      print("Error during sign-in: $e");
      throw Exception("Sign-in failed");
    }
    return null;
  }
}
