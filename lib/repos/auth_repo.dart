import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthRepo {
  static AuthRepo? instance;
  static const String _collectionUsers = "users";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepo._privateConstructor();

  factory AuthRepo() {
    instance ??= AuthRepo._privateConstructor();
    return instance!;
  }

  Future<bool> isLoggedIn() async {
    var firebaseUser = _auth.currentUser;
    firebaseUser ??= await _auth.authStateChanges().first;
    return firebaseUser != null;
  }

  String? get uid => _auth.currentUser?.uid;

  Future<bool> register(String email, String password) async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection(_collectionUsers).doc(user.user?.uid).set({
        "email": email,
        "uid": user.user?.uid,
      });
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> loginAnonymously() async {
    try {
      final user = await _auth.signInAnonymously();
      await _firestore.collection(_collectionUsers).doc(user.user?.uid).set({
        "email": "anonymous ${user.user?.uid}",
        "uid": user.user?.uid,
      });
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  void loginWithPhone(String phoneNumber) {
    _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        _linWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Something went wrong. Please try later');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Update the UI - wait for the user to enter the SMS code
        String smsCode = 'xxxx';

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        //_auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  _linWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.currentUser
          ?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    }
  }
}
