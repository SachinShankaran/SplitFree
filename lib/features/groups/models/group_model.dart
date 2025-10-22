import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final List<String> members;
  final String createdBy;
  final Timestamp createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}