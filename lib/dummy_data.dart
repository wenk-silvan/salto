import 'package:salto/models.dart';

var fleekBoi = User(
  uuid: "10300",
  firstname: 'Fleek',
  lastname: 'Boi',
  username: 'fleekboi',
  userDescription: 'Hey there, my name is Fleek',
  locality: 'Brussels',
  age: 21,
  avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
  follows: ['10008', '10301'],
);

var dinkyJ = User(
  uuid: "10301",
  firstname: 'Jos',
  lastname: 'Dinky',
  username: 'dinkyj',
  userDescription: 'Hey there, my name is Jos',
  locality: 'Berlin',
  age: 22,
  avatarUrl: 'https://i.pravatar.cc/150?img=57',
  follows: ['10008', '10300'],
);

var fleekBackie = ContentItem(
  contentId: '70',
  title: 'Fleek\'s Backflip',
  description: 'Backflip im Garten',
  mediaUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b3/Backflip.jpg',
  likeCount: 25,
  timestamp: DateTime(2019, 1, 1, 12, 0, 0),
  ownerUuid: '10300',
  comments: [
    Comment(
      commentId: "150",
      text: 'Sick!',
      uuid: '10301',
      contentId: '70',
      timestamp: DateTime(2019, 1, 1, 12, 1, 30),
    )
  ]
);

List<User> getDummyUsers(){
  return new List<User>.generate(20, (i) {
    return User(
      uuid: (10000 + i).toString(),
      firstname: 'Max' + i.toString(),
      lastname: 'Müller' + i.toString(),
      username: 'max'+i.toString(),
      userDescription: 'Yoo, waassup I am number' + i.toString(),
      locality: 'London',
      age: 21,
      avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
      follows: ['10008', '10009'],
    );
  });
}

List<ContentItem> getDummyPosts() {
  return new List<ContentItem>.generate(20, (i) {
    return ContentItem(
      contentId: (50 + i).toString(),
      title: 'Backflip' + i.toString(),
      description: 'Backflip im Garten',
      mediaUrl: 'https://picsum.photos/400/200',
      likeCount: i,
      timestamp: DateTime(2019, 1, 1, 12, i, 0),
      ownerUuid: '10008',
      comments: [
        Comment(
            commentId: (100 + i).toString(),
            text: 'starker backie!',
            uuid: (10000 + i).toString(),
            contentId: (50 + i).toString(),
            timestamp: DateTime(2019, 1, 1, 12, i, 30),
        )
      ],
    );
  });
}