import 'package:meta/meta.dart';
class User {
  final String username;
  final String firstname;
  final String lastname;
  final String userDescription;
  final String locality;
  final int age;
  final String avatarUrl;
  final List<String> follows;

  User({
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
  final User owner;
  final DateTime timestamp;

  Comment({
    @required this.commentId,
    @required this.text,
    @required this.owner,
    @required this.timestamp,
  });
}

class Like {
  final User user;

  Like({
    @required this.user
  });
}

class ContentItem {
  final String contentId; // count starts at 50
  final String title;
  final String description;
  final String mediaUrl;
  final DateTime timestamp;
  final User owner;
  final List<Comment> comments;
  final int likeCount;
  final List<Like> likes;

  ContentItem({
    @required this.contentId,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    @required this.timestamp,
    @required this.owner,
    @required this.comments,
    @required this.likeCount,
    @required this.likes,
  });

  bool isLikedBy(User user){
    return likes.any((like) => user.username == like.user.username);
  }
}