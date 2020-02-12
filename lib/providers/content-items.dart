import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../models/content-item.dart';

class ContentItems with ChangeNotifier {
  List<ContentItem> _items = [
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
    ContentItem(
        id: '71',
        title: 'Another trick',
        description: 'Backflip in den Sand',
        mediaUrl:
        'https://i.ytimg.com/vi/qu1deqZJ8_A/maxresdefault.jpg',
        /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
        userId: 'ed4f546q',
        comments: [
          Comment(
            id: "152",
            text:
            'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
          ),
          Comment(
            id: "153",
            text: 'Nice!',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 2, 30),*/
          ),
        ],
        likes: [
          'ed4f546q',
          '5a4f546e',
        ]),
    ContentItem(
        id: '72',
        title: 'Yet another tramp salto',
        description: 'Backflip in den Sand',
        mediaUrl:
        'http://realbuzz4.s3.amazonaws.com/photo_field_photos/600x450/d7329c10a660bd47cb9ac8fe75a3f05c677b.jpg',
        /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
        userId: 'ed4f546q',
        comments: [
          Comment(
            id: "154",
            text:
            'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
          ),
          Comment(
            id: "155",
            text: 'Nice!',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 2, 30),*/
          ),
        ],
        likes: [
          'ed4f546q',
          '5a4f546e',
        ]),
    ContentItem(
        id: '73',
        title: 'Its tutorial time.',
        description: 'Backflip in den Sand',
        mediaUrl:
        'https://www.wikihow.com/images/thumb/1/18/Do-Trampoline-Tricks-Step-2.jpg/aid204008-v4-728px-Do-Trampoline-Tricks-Step-2.jpg',
        /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
        userId: '5a4f546e',
        comments: [
          Comment(
            id: "156",
            text:
            'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
          ),
          Comment(
            id: "157",
            text: 'Nice!',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 2, 30),*/
          ),
        ],
        likes: [
          'ed4f546q',
          '5a4f546e',
        ]),
    ContentItem(
        id: '74',
        title: 'Another tutorial baby',
        description: 'Backflip in den Sand',
        mediaUrl:
        'https://www.wikihow.com/images/thumb/6/65/Do-Trampoline-Tricks-Step-4.jpg/aid204008-v4-728px-Do-Trampoline-Tricks-Step-4.jpg',
        /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
        userId: '5a4f546e',
        comments: [
          Comment(
            id: "158",
            text:
            'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
          ),
          Comment(
            id: "159",
            text: 'Nice!',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 2, 30),*/
          ),
        ],
        likes: [
          'ed4f546q',
          '5a4f546e',
        ]),
    ContentItem(
        id: '75',
        title: 'The Whackflip',
        description: 'Backflip in den Sand',
        mediaUrl:
        'http://i.ytimg.com/vi/6qMYH9EOJUo/hqdefault.jpg',
        /*timestamp: DateTime(2019, 1, 1, 12, 0, 0),*/
        userId: 'ed4f546q',
        comments: [
          Comment(
            id: "160",
            text:
            'Sick! Yes, this comment is supposed to be very long so it wraps around multiple lines to test whether the layout stays anchored...',
            userId: '5a4f546e',
            /*timestamp: DateTime(2019, 1, 1, 12, 1, 30),*/
          ),
          Comment(
            id: "161",
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

  List<ContentItem> get items {
    return this._items;
  }

  List<String> getMediaByUserId(String userId) {
    return this
        ._items
        .where((i) => i.userId == userId)
        .map((i) => i.mediaUrl)
        .toList();
  }
}
