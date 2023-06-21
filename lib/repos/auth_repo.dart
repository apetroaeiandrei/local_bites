import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/repos/phone_confirm_error.dart';
import 'package:local/repos/user_repo.dart';

class AuthRepo {
  static AuthRepo? instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepo _userRepo;

  AuthRepo._privateConstructor(this._userRepo);

  factory AuthRepo(UserRepo userRepo) {
    instance ??= AuthRepo._privateConstructor(userRepo);
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
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _userRepo.createUser(phoneVerified: false);
      return true;
    } on Exception catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
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

  void loginWithPhone({
    required bool linkCredential,
    required String phoneNumber,
    required Function(PhoneConfirmError, {String? verificationId}) onError,
    required Function() onSuccess,
    required Function(String) onCodeSent,
  }) {
    _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 20),
      phoneNumber: phoneNumber,
      forceResendingToken: 1,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("verificationCompleted $credential");
        if (linkCredential) {
          _linkWithCredential(credential, onError, onSuccess);
        } else {
          _signInWithPhoneCredential(credential, onError, onSuccess);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          onError(PhoneConfirmError.invalidPhoneNumber);
          print('The provided phone number is not valid.');
        } if (e.code == 'too-many-requests') {
          onError(PhoneConfirmError.tooManyRequests);
          FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
          print('Too many requests. Please try later.');
        }
        else {
          onError(PhoneConfirmError.unknown);
          FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
          print('Something went wrong. Please try later, $e');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Update the UI - wait for the user to enter the SMS code
        print("code SENT $verificationId");
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout $verificationId");
        onError(PhoneConfirmError.timeout, verificationId: verificationId);
      },
    );
  }

  confirmCodeAndLinkCredential({
    required String smsCode,
    required String verificationId,
    required Function(PhoneConfirmError) onError,
    required Function() onSuccess,
  }) async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    print("credential confirmed $credential");
    _linkWithCredential(credential, onError, onSuccess);
  }

  void confirmCodeAndSignIn({
    required String smsCode,
    required String verificationId,
    required Function(PhoneConfirmError) onError,
    required Function() onSuccess,
  }) async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    print("credential confirmed, signing in $credential");
    _signInWithPhoneCredential(credential, onError, onSuccess);
  }

  _signInWithPhoneCredential(
    PhoneAuthCredential credential,
    Function(PhoneConfirmError) onError,
    Function() onSuccess,
  ) async {
    try {
      final user = await _auth.signInWithCredential(credential);
      await _userRepo.createOrUpdateUser(
          user.user!.uid, user.user!.phoneNumber!);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          onError(PhoneConfirmError.invalidCode);
          print("The provider's credential is not valid.");
          break;
        case "invalid-verification-code":
          onError(PhoneConfirmError.invalidCode);
          print(
              "The verification code used to create the phone auth credential "
              "is invalid.");
          break;
        // See the API reference for the full list of error codes.
        default:
          onError(PhoneConfirmError.unknown);
          print("Unknown firebase error. $e");
      }
    } on Exception catch (e) {
      onError(PhoneConfirmError.unknown);
      print("Unknown exception. $e");
    }
  }

  _linkWithCredential(
    PhoneAuthCredential credential,
    Function(PhoneConfirmError) onError,
    Function() onSuccess,
  ) async {
    try {
      await _auth.currentUser?.linkWithCredential(credential);
      await _userRepo.updateUserDetails(
          phoneVerified: true, phoneNumber: _auth.currentUser!.phoneNumber!);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          onError(PhoneConfirmError.alreadyLinked);
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          onError(PhoneConfirmError.invalidCode);
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          onError(PhoneConfirmError.alreadyInUse);
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        case "invalid-verification-code":
          onError(PhoneConfirmError.invalidCode);
          print(
              "The verification code used to create the phone auth credential "
              "is invalid.");
          break;
        // See the API reference for the full list of error codes.
        default:
          onError(PhoneConfirmError.unknown);
          print("Unknown firebase error. $e");
      }
    } on Exception catch (e) {
      onError(PhoneConfirmError.unknown);
      print("Unknown exception. $e");
    }
  }
}
