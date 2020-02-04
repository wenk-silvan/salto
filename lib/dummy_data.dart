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

  User({this.uuid,this.username,this.firstname,this.lastname,this.userDescription, this.locality, this.age, this.avatarUrl, this.follows});

  static List<User> getDummyUsers(){
    return new List<User>.generate(20, (i) {
      return User(
        uuid: (10000 + i).toString(),
        firstname: 'Max' + i.toString(),
        lastname: 'Müller' + i.toString(),
        userDescription: 'Yoo, waassup I am number' + i.toString(),
        locality: 'London',
        age: 21,
        avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
        follows: ['10008', '10009'],
      );
    });
  }
}

class Comment {
  final String commentId; // count starts at 100
  final String text;
  final String uuid;
  final String contentId;
  final DateTime timestamp;

  Comment(this.commentId,this.text,this.uuid,this.contentId,this.timestamp);
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

  ContentItem({this.contentId, this.title, this.description, this.mediaUrl, this.likeCount, this.timestamp, this.ownerUuid, this.comments});

  static List<ContentItem> getDummyPosts() {
    return new List<ContentItem>.generate(20, (i) {
      return ContentItem(
        contentId: (50 + i).toString(),
        title: 'Backflip' + i.toString(),
        description: 'Backflip im Garten',
        mediaUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b3/Backflip.jpg',
        likeCount: i,
        timestamp: DateTime(2019, 1, 1, 12, i, 0),
        ownerUuid: '10008',
        comments: [
          Comment(
              (100 + i).toString(), 'starker backie!', (10000 + i).toString(),
              (50 + i).toString(), DateTime(2019, 1, 1, 12, i, 30))
        ],
      );
    });
  }
}



