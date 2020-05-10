import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/models/http_exception.dart';

class EditPost extends StatefulWidget {
  final ContentItem post;

  EditPost(this.post);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String _updatingTitle;
  String _updatingDescription;

  @override
  void initState() {
    _updatingTitle = widget.post.title;
    _updatingDescription = widget.post.description;
    super.initState();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Container(
        height: 180,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              initialValue: widget.post.title,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              focusNode: _titleFocusNode,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_descriptionFocusNode),
              onSaved: (value) => _updatingTitle = value,
            ),
            TextFormField(
              initialValue: widget.post.description,
              decoration: const InputDecoration(labelText: 'Description'),
              textInputAction: TextInputAction.done,
              focusNode: _descriptionFocusNode,
              onFieldSubmitted: (_) => _saveForm(),
              onSaved: (value) => _updatingDescription = value,
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                FlatButton(
                  child: const Text('Update'),
                  onPressed: _saveForm,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _saveForm() async {
    final _contentData = Provider.of<ContentItems>(context, listen: false);
    try {
      Navigator.of(context).pop();
      _form.currentState.save();
      if (_updatingTitle == widget.post.title && _updatingDescription == widget.post.description) return;
      final _updated = ContentItem(
        id: widget.post.id,
        title: _updatingTitle,
        userId: widget.post.userId,
        likes: widget.post.likes,
        mediaUrl: widget.post.mediaUrl,
        timestamp: widget.post.timestamp,
        description: _updatingDescription,
      );
      final data = {
        'title': _updatingTitle,
        'description': _updatingDescription,
      };
      _contentData.updatePost(data, widget.post.id);
      final index = _contentData.items.indexOf(widget.post);
      _contentData.items.removeAt(index);
      _contentData.items.insert(index, _updated);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.message, context);
    }
  }
}
