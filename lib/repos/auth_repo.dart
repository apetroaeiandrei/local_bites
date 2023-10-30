import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/repos/phone_confirm_error.dart';
import 'package:local/repos/user_repo.dart';

class AuthRepo {
  static AuthRepo? instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
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

  Future<bool> login(String email, String password,
      {bool reauthenticate = false}) async {
    try {
      if (reauthenticate) {
        await _auth.currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: email, password: password));
      } else {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
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
    bool reauthenticate = false,
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
        if (reauthenticate) {
          _reauthenticateWithCredential(credential, onError, onSuccess);
        } else if (linkCredential) {
          _linkWithCredential(credential, onError, onSuccess);
        } else {
          _signInWithPhoneCredential(credential, onError, onSuccess);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        _crashlytics.recordError(e, StackTrace.current);
        if (e.code == 'invalid-phone-number') {
          onError(PhoneConfirmError.invalidPhoneNumber);
        }
        if (e.code == 'too-many-requests') {
          onError(PhoneConfirmError.tooManyRequests);
        } else {
          onError(PhoneConfirmError.unknown);
          _crashlytics.recordError(e, StackTrace.current);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Update the UI - wait for the user to enter the SMS code
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
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
    _linkWithCredential(credential, onError, onSuccess);
  }

  void confirmCodeAndSignIn({
    bool reauthenticate = false,
    required String smsCode,
    required String verificationId,
    required Function(PhoneConfirmError) onError,
    required Function() onSuccess,
  }) async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    if (reauthenticate) {
      _reauthenticateWithCredential(credential, onError, onSuccess);
    } else {
      _signInWithPhoneCredential(credential, onError, onSuccess);
    }
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
      _crashlytics.recordError(e, StackTrace.current);
      switch (e.code) {
        case "invalid-credential":
          onError(PhoneConfirmError.invalidCode);

          break;
        case "invalid-verification-code":
          onError(PhoneConfirmError.invalidCode);
          break;
        // See the API reference for the full list of error codes.
        default:
          onError(PhoneConfirmError.unknown);
      }
    } on Exception catch (e) {
      onError(PhoneConfirmError.unknown);
      _crashlytics.recordError(e, StackTrace.current);
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
      _crashlytics.recordError(e, StackTrace.current);
      switch (e.code) {
        case "provider-already-linked":
          onError(PhoneConfirmError.alreadyLinked);
          break;
        case "invalid-credential":
          onError(PhoneConfirmError.invalidCode);
          break;
        case "credential-already-in-use":
          onError(PhoneConfirmError.alreadyInUse);
          break;
        case "invalid-verification-code":
          onError(PhoneConfirmError.invalidCode);
          break;
        default:
          onError(PhoneConfirmError.unknown);
      }
    } on Exception catch (e) {
      onError(PhoneConfirmError.unknown);
      _crashlytics.recordError(e, StackTrace.current);
    }
  }

  Future<void> _reauthenticateWithCredential(
    AuthCredential credential,
    Function(PhoneConfirmError) onError,
    Function() onSuccess,
  ) async {
    try {
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      onSuccess();
    } catch (error) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
      onError(PhoneConfirmError.unknown);
    }
  }

  Future<bool> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
      return true;
    } catch (error) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
    }
    return false;
  }

  List<UserInfo>? getUserProviders() {
    return _auth.currentUser?.providerData;
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (error) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
      return false;
    }
  }
}
