import 'models/comment.dart';
import 'models/content-item.dart';
import 'models/user.dart';

const DUMMY_USERS = const [
  User(
    id: 'ed4f546q',
    firstName: 'Fleek',
    lastName: 'Boi',
    userName: 'fleekboi',
    description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
    locality: 'Brussels',
    age: 21,
    avatarUrl:
        'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
    follows: ['5a4f546e'],
  ),
  User(
    id: '5a4f546e',
    firstName: 'Jos',
    lastName: 'Dinky',
    userName: 'dinkyj',
    description: 'Hey there, my name is Jos',
    locality: 'Berlin',
    age: 22,
    avatarUrl: 'https://i.pravatar.cc/150?img=57',
    follows: ['ed4f546q'],
  )
];

const DUMMY_CONTENT = const [
ContentItem(
    id: '70',
    title: 'Fleek\'s Backflip',
    description: 'Backflip in den Sand',
    mediaUrl:
    'https://upload.wikimedia.org/wikipedia/commons/b/b3/Backflip.jpg',
    /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
    userId: 'ed4f546q',
    comments: [
      Comment(
        id: "150",
        text:
        'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
        userId: '5a4f546e',
        /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
      ),
      Comment(
        id: "151",
        text: 'Nice!',
        userId: '5a4f546e',
        /*timestamp: DateTime(2019, 1, 1, 12, 2, 30),*/
      ),
    ],
    likes: [
      'ed4f546q',
      '5a4f546e',
    ]),
];

List<User> getDummyUsers() {
  return new List<User>.generate(20, (i) {
    return User(
      firstName: 'Max' + i.toString(),
      lastName: 'Müller' + i.toString(),
      userName: 'max' + i.toString(),
      description: 'Yoo, waassup I am number' + i.toString(),
      locality: 'London',
      age: 21,
      avatarUrl:
          'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
      follows: ['10008', '10009'],
    );
  });
}
/*
List<ContentItem> getDummyPosts() {
  return new List<ContentItem>.generate(20, (i) {
    return ContentItem(
      id: (50 + i).toString(),
      title: 'Sample Post ' + i.toString(),
      description: 'Description',
      mediaUrl: 'https://picsum.photos/400/200',
      likeCount: i,
      timestamp: DateTime(2019, 1, 1, 12, i, 0),
      userId: getDummyUsers()[i],
      comments: [
        Comment(
          commentId: (100 + i).toString(),
          text: 'Comment.',
          owner: getDummyUsers()[1],
          timestamp: DateTime(2019, 1, 1, 12, i, 30),
        ),
        Comment(
          commentId: (100 + (2 * i)).toString(),
          text:
              'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
          owner: getDummyUsers()[1],
          timestamp: DateTime(2019, 1, 1, 12, 2 * i, 30),
        )
      ],
      likes: [
        Like(user: fleekBoi),
        Like(user: dinkyJ),
      ],
    );
  });
}*/
