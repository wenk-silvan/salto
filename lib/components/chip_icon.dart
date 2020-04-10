import 'package:flutter/material.dart';

class ChipIcon extends StatelessWidget {
  IconData icon;
  String text;
  BuildContext ctx;
  Function onPressed;

  ChipIcon(this.icon, this.text, this.ctx, [this.onPressed]);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        children: <Widget>[
          this.onPressed != null ?
            IconButton(
              icon: Icon(
                icon,
                color: Theme.of(ctx).textTheme.title.color,
              ),
              onPressed: this.onPressed,
            )
          :
            Icon(
              icon,
              color: Theme.of(ctx).textTheme.title.color,
            ),
          SizedBox(
              width: 5
          ),
          Text(text,
              style: TextStyle(color: Theme
                  .of(ctx)
                  .textTheme
                  .title
                  .color)),
        ],
      ),
      backgroundColor: Theme
          .of(ctx)
          .primaryColor,
    );
  }
}
