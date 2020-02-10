import 'package:salto/models.dart';

var fleekBoi = User(
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
  description: 'Backflip in den Sand',
  mediaUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b3/Backflip.jpg',
  timestamp: DateTime(2019, 1, 1, 12, 0, 0),
  owner: fleekBoi,
  comments: [
    Comment(
      commentId: "150",
      text: 'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
      owner: dinkyJ,
      timestamp: DateTime(2019, 1, 1, 12, 1, 30),
    ),
    Comment(
      commentId: "151",
      text: 'Nice!',
      owner: dinkyJ,
      timestamp: DateTime(2019, 1, 1, 12, 2, 30),
    ),
  ],
  likeCount: 25,
  likes: [
    Like(user:fleekBoi),
    Like(user:dinkyJ),
  ]
);

List<User> getDummyUsers(){
  return new List<User>.generate(20, (i) {
    return User(
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
      title: 'Sample Post ' + i.toString(),
      description: 'Description',
      mediaUrl: 'https://picsum.photos/400/200',
      likeCount: i,
      timestamp: DateTime(2019, 1, 1, 12, i, 0),
      owner: getDummyUsers()[i],
      comments: [
        Comment(
            commentId: (100 + i).toString(),
            text: 'Comment.',
            owner: getDummyUsers()[1],
            timestamp: DateTime(2019, 1, 1, 12, i, 30),
        ),
        Comment(
          commentId: (100 + (2*i)).toString(),
          text: 'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
          owner: getDummyUsers()[1],
          timestamp: DateTime(2019, 1, 1, 12, 2*i, 30),
        )
      ],
      likes: [
          Like(user:fleekBoi),
          Like(user:dinkyJ),
      ],
    );
  });
}