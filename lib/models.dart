import 'package:meta/meta.dart';
class User {
  final String uuid; // count starts at 10000
  final String username;
  final String firstname;
  final String lastname;
  final String userDescription;
  final String locality;
  final int age;
  final String avatarUrl;
  final List<String> follows;

  User({
    @required this.uuid,
    @required this.username,
    this.firstname,
    this.lastname,
    this.userDescription,
    this.locality,
    this.age,
    this.avatarUrl,
    @required this.follows
  });
}

class Comment {
  final String commentId; // count starts at 100
  final String text;
  final String uuid;
  final String contentId;
  final DateTime timestamp;

  Comment({
    @required this.commentId,
    @required this.text,
    @required this.uuid,
    @required this.contentId,
    @required this.timestamp});
}

class ContentItem {
  final String contentId; // count starts at 50
  final String title;
  final String description;
  final String mediaUrl;
  final int likeCount;
  final DateTime timestamp;
  final String ownerUuid;
  final List<Comment> comments;

  ContentItem({
    @required this.contentId,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    @required this.likeCount,
    @required this.timestamp,
    @required this.ownerUuid,
    @required this.comments});
}