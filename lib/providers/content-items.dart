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
