import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Creates a Firebase Auth account AND a Firestore user document.
  ///
  /// If the Firestore write fails we delete the Auth account so we never
  /// leave an orphaned credential with no corresponding user document.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? tcKimlik,
    String? gender,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow; // Let AuthProvider translate to a friendly message.
    }

    final user = UserModel(
      uid: credential.user!.uid,
      fullName: fullName,
      email: email,
      role: role,
      tcKimlik: tcKimlik,
      gender: gender,
    );

    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (_) {
      // Firestore write failed — roll back the Auth account so the user can
      // retry without being left in a broken half-created state.
      await credential.user!.delete();
      throw Exception(
        'Account setup failed. Please check your connection and try again.',
      );
    }

    return user;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password-reset email via Firebase Auth.
  /// Throws on invalid email or network error — callers handle the error.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Returns null if the document doesn't exist (new user) or on any
  /// network/permission error — callers must handle null gracefully.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (_) {
      // Network error or permission denied — return null; caller decides
      // what to show. Do NOT rethrow — auth listener must not crash.
      return null;
    }
  }
}
