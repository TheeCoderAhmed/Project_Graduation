import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  String? get error => _error;

  AuthProvider() {
    _firebaseUser = FirebaseAuth.instance.currentUser;

    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        // getUserData() now swallows its own errors and returns null —
        // we never crash here even on network failure.
        _userModel = await _authService.getUserData(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    // Provider-only listing fields. Required when role == 'provider'.
    String? providerType,
    String? specialty,
    String? address,
    String? phone,
    String? gender,
    String? hospital,
    String? department,
    String? room,
    String? tcKimlik, // Private (doctors) — stored on the user doc only.
  }) async {
    if (password.length < 8) {
      _error = 'Password must be at least 8 characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final userModel = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        tcKimlik: tcKimlik,
        gender: gender,
      );
      _userModel = userModel;
      _firebaseUser = FirebaseAuth.instance.currentUser;

      // Provider accounts claim a listing keyed by their UID, so the dashboard
      // can immediately resolve it. Non-fatal: account already exists.
      if (role == 'provider') {
        try {
          await _firestore.createProviderListing(ProviderModel(
            providerId: userModel.uid,
            ownerId: userModel.uid,
            type: providerType ?? 'doctor',
            name: fullName,
            specialty: specialty ?? '',
            address: address ?? '',
            phone: phone ?? '',
            gender: (providerType ?? 'doctor') == 'doctor' ? gender : null,
            hospital: (providerType ?? 'doctor') == 'doctor' ? hospital : null,
            department: (providerType ?? 'doctor') == 'doctor' ? department : null,
            room: (providerType ?? 'doctor') == 'doctor' ? room : null,
          ));
        } catch (_) {
          // Listing write failed (e.g. offline). The provider can still sign in;
          // the dashboard shows a claim/retry state until it succeeds.
        }
      }
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs the user out. Swallows network errors gracefully — if Firebase
  /// can't reach the server we still clear local state so the UI goes to login.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (_) {
      // Firebase signOut can fail on bad network. Clear local state anyway —
      // the user should always be able to leave the app.
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Sends a password-reset email. Returns a friendly message for the UI.
  Future<String> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return 'Password reset email sent. Check your inbox.';
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('user-not-found')) {
        return 'No account found with that email.';
      }
      if (raw.contains('invalid-email')) {
        return 'Please enter a valid email address.';
      }
      if (raw.contains('network-request-failed') ||
          raw.contains('connection')) {
        return 'Check your internet connection and try again.';
      }
      if (raw.contains('too-many-requests')) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      return 'Could not send reset email. Please try again.';
    }
  }

  /// Optimistic local bookmark toggle. The caller is responsible for
  /// persisting to Firestore via FirestoreService.toggleBookmark().
  void toggleBookmark(String providerId, bool add) {
    if (_userModel == null) return;
    final bookmarks = List<String>.from(_userModel!.bookmarks);
    if (add && !bookmarks.contains(providerId)) {
      bookmarks.add(providerId);
    } else if (!add) {
      bookmarks.remove(providerId);
    }
    _userModel = _userModel!.copyWith(bookmarks: bookmarks);
    notifyListeners();
  }

  /// Reverts a failed bookmark toggle back to the previous state.
  void revertBookmark(String providerId, bool wasBookmarked) {
    toggleBookmark(providerId, wasBookmarked);
  }

  Future<void> refreshUserData() async {
    if (_firebaseUser == null) return;
    final fresh = await _authService.getUserData(_firebaseUser!.uid);
    if (fresh != null) {
      _userModel = fresh;
      notifyListeners();
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'That email is already registered.';
    }
    if (raw.contains('wrong-password') ||
        raw.contains('invalid-credential') ||
        raw.contains('invalid-email')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('user-not-found')) {
      return 'No account found with that email.';
    }
    if (raw.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('network-request-failed') ||
        raw.contains('connection')) {
      return 'Check your internet connection and try again.';
    }
    if (raw.contains('Account setup failed')) {
      return 'Account setup failed. Please check your connection and try again.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
