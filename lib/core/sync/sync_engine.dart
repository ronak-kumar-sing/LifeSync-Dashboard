import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

import 'storage_keys.dart';

class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  static final Logger _logger = Logger();
  static bool _initialized = false;
  static String? _userId;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<QuerySnapshot>? _incomeListener;
  static Stream<QuerySnapshot>? _waterListener;
  static Stream<QuerySnapshot>? _analyticsListener;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _setupAnonymousAuth();
      _setupFirestoreListeners();
      _initialized = true;
      _logger.i('SyncEngine initialized');
    } catch (e) {
      _logger.e('SyncEngine initialization error: $e');
    }
  }

  static Future<void> _setupAnonymousAuth() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        final cred = await _auth.signInAnonymously();
        _userId = cred.user?.uid;
      } else {
        _userId = user.uid;
      }
      _logger.i('Auth user ID: $_userId');
    } catch (e) {
      _logger.e('Anonymous auth error: $e');
    }
  }

  static Future<void> upgradeToGoogleSignIn() async {
    try {
      final googleProvider = GoogleAuthProvider();
      await _auth.currentUser?.linkWithProvider(googleProvider);
      _logger.i('Upgraded to Google Sign-In');
    } catch (e) {
      _logger.e('Google Sign-In upgrade error: $e');
    }
  }

  static void _setupFirestoreListeners() {
    if (_userId == null) return;

    _incomeListener = _firestore
        .collection('users')
        .doc(_userId)
        .collection('income')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _waterListener = _firestore
        .collection('users')
        .doc(_userId)
        .collection('water')
        .orderBy('date', descending: true)
        .snapshots();

    _analyticsListener = _firestore
        .collection('users')
        .doc(_userId)
        .collection('analytics')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Future<void> syncIncome(Map<String, dynamic> data) async {
    await _syncToFirestore('income', data);
  }

  static Future<void> syncWater(Map<String, dynamic> data) async {
    await _syncToFirestore('water', data);
  }

  static Future<void> syncAnalytics(Map<String, dynamic> data) async {
    await _syncToFirestore('analytics', data);
  }

  static Future<void> _syncToFirestore(String collection, Map<String, dynamic> data) async {
    if (_userId == null || !(await isOnline)) {
      _logger.w('Cannot sync: offline or no user');
      return;
    }

    try {
      final docId = data['id'] ?? '${DateTime.now().millisecondsSinceEpoch}';
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: true));
      _logger.i('Synced to $collection: $docId');
    } catch (e) {
      _logger.e('Firestore sync error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFromFirestore(String collection) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      _logger.e('Fetch error: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> streamFromFirestore(String collection) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  static Future<void> deleteFromFirestore(String collection, String docId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collection)
          .doc(docId)
          .delete();
    } catch (e) {
      _logger.e('Delete error: $e');
    }
  }

  static void dispose() {
    _incomeListener = null;
    _waterListener = null;
    _analyticsListener = null;
  }
}