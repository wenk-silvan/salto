import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Timestamp extends StatelessWidget {
  DateTime timestamp;

  Timestamp(this.timestamp);

  @override
  Widget build(BuildContext context) {
    Duration delta = DateTime.now().difference(timestamp);
    TextStyle style = TextStyle(color: Colors.grey, fontSize: 12);
    if(delta.inDays > 0)
      return Text(DateFormat('dd.MM.yyyy').format(this.timestamp),
          style: style);
    if(delta.inHours > 0)
      return Text("${delta.inHours} ${delta.inHours == 1 ? "hour" : "hours"} ago",
          style: style);
    if(delta.inMinutes > 0)
      return Text("${delta.inMinutes} ${delta.inMinutes == 1 ? "min" : "mins"} ago",
          style: style);
    return Text("just now",
        style: style);
  }
}
