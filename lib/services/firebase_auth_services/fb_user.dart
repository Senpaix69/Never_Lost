import 'package:flutter/material.dart' show immutable;
import 'package:neverlost/constants/firebase_contants/firebase_contants.dart';

@immutable
class FBUser {
  final String uid;
  final String fullname;
  final String username;
  final String email;
  final bool verified;
  final String? profilePic;
  final String? profilePicURL;

  const FBUser({
    required this.uid,
    required this.verified,
    required this.fullname,
    required this.username,
    required this.email,
    this.profilePic,
    this.profilePicURL,
  });

  factory FBUser.fromMap(Map<String, Object?> map) {
    return FBUser(
      uid: map[userId] as String,
      verified: map[userVerified] as bool,
      fullname: map[userFullname] as String,
      username: map[userUsername] as String,
      email: map[userEmail] as String,
      profilePic: map[userProfilePic] as String?,
      profilePicURL: map[userProfilePicURL] as String?,
    );
  }

  FBUser copyWith({
    String? uid,
    String? fullname,
    String? username,
    String? email,
    bool? verified,
    String? profilePic,
    String? profilePicURL,
  }) {
    return FBUser(
      uid: uid ?? this.uid,
      verified: verified ?? this.verified,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      profilePicURL: profilePicURL ?? this.profilePicURL,
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
      userProfilePicURL: profilePicURL,
    };
  }

  @override
  String toString() {
    return "SPUser { userID: $uid, fullname: $fullname, email: $email, username: $username, verified: $verified, profilePic: $profilePic, profilePicUrl: $profilePicURL }";
  }
}
