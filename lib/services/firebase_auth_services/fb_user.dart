import 'package:flutter/material.dart' show immutable;
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';

@immutable
class FBUser {
  final String uid;
  final String fullname;
  final String username;
  final String email;
  final bool verified;
  final String? profilePic;

  const FBUser({
    required this.uid,
    required this.verified,
    required this.fullname,
    required this.username,
    required this.email,
    this.profilePic,
  });

  factory FBUser.fromMap(Map<String, Object?> map) {
    return FBUser(
      uid: map[userId] as String,
      verified: map[userVerified] as bool,
      fullname: map[userFullname] as String,
      username: map[userUsername] as String,
      email: map[userEmail] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      userId: uid,
      userFullname: fullname,
      userEmail: email,
      userUsername: username,
      userVerified: verified,
      userProfilePic: profilePic,
    };
  }
}
