import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<GroupModel>> getGroups() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) return Stream.value([]);

    return _db
        .collection('groups')
        .where('members', arrayContains: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => GroupModel.fromFirestore(d)).toList());
  }

  Future<void> createGroup(String name, List<String> memberEmails) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    if (!memberEmails.contains(user.email!)) {
      memberEmails.add(user.email!);
    }

    await _db.collection('groups').add({
      'name': name,
      'members': memberEmails,
      'createdBy': user.uid,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<ExpenseModel>> getExpenses(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ExpenseModel.fromFirestore(d)).toList());
  }

  Future<void> addExpense(
    String groupId,
    String description,
    double amount,
    List<String> members,
    String paidByEmail,
  ) async {
    await _db.collection('groups').doc(groupId).collection('expenses').add({
      'description': description,
      'amount': amount,
      'paidBy': paidByEmail,
      'paidAt': Timestamp.now(),
      'splitAmong': members,
    });
  }

  // New methods for settlements
  Stream<List<Settlement>> getSettlements(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .orderBy('settledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Settlement.fromFirestore(d)).toList());
  }

  Future<void> addSettlement(
    String groupId,
    String from,
    String to,
    double amount,
  ) async {
    await _db.collection('groups').doc(groupId).collection('settlements').add({
      'from': from,
      'to': to,
      'amount': amount,
      'settledAt': Timestamp.now(),
    });
  }

  // Optional: Get settlement history for a specific user
  Future<List<Settlement>> getUserSettlements(String groupId, String userEmail) async {
    final snapshot = await _db
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .where('from', isEqualTo: userEmail)
        .orderBy('settledAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Settlement.fromFirestore(doc)).toList();
  }

  // Optional: Delete a settlement (in case of mistakes)
  Future<void> deleteSettlement(String groupId, String settlementId) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .doc(settlementId)
        .delete();
  }
}

// Riverpod provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});