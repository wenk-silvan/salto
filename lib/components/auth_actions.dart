import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/users.dart';

enum AuthMode { Signup, Login, Reset }

class AuthActions extends StatefulWidget {
  @override
  _AuthActionsState createState() => _AuthActionsState();
}

class _AuthActionsState extends State<AuthActions> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();

  void _addNewUser() {
    try {
        Provider.of<Auth>(context, listen: false).addUser(User(
        followers: [],
        firstName: this._firstNameController.text,
        follows: [],
        lastName: this._lastNameController.text,
        locality: '',
        userName: this._userNameController.text,
        uuid: Provider.of<Auth>(context, listen: false).userId,
        age: 0,
        avatarUrl: 'http://wilkinsonschool.org/wp-content/uploads/2018/10/user-default-grey.png',
        description: '',
        id: '',
      ), Provider.of<Users>(context));
    } catch (error) {
      Provider.of<Auth>(context, listen: false).logout();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occured!'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ));
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      }
      else if (_authMode == AuthMode.Signup) {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
        this._addNewUser();
      }
      else {
        await Provider.of<Auth>(context, listen: false).resetPassword(
          _authData['email'].trim()
        );
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Password reset email sent.')
        ));
        this._switchAuthMode();
      }
    } on HttpException catch (error) {
      var errorMessage = 'Auhentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      HttpException.showErrorDialog(errorMessage, context);
    } catch (error) {
      var errorMessage = 'Could not authenticate you. Please try again later.';
      HttpException.showErrorDialog(errorMessage, context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: this._formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'User Name'),
                  controller: this._userNameController,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                    if (value.length < 3)
                      return 'User name is to short.';
                    else if (value.length > 20)
                      return 'User name is to long.';
                    else if (value.contains(' '))
                      return 'Cannot contain whitespaces.';
                  }
                      : null,
                ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'First Name'),
                  controller: this._firstNameController,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                    if (value.length < 3) {
                      if (value.length < 3) {
                        return 'First name is to short.';
                      } else if (value.length > 20)
                        return 'First name is to long.';
                    }
                  }
                      : null,
                ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  controller: this._lastNameController,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                    if (value.length < 3) {
                      if (value.length < 3) {
                        return 'Last name is to short.';
                      } else if (value.length > 20)
                        return 'Last name is to long.';
                    }
                  }
                      : null,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@'))
                    return 'Invalid email!';
                  else if (value.contains(' '))
                    return 'Cannot contain whitespaces.';
                },
                onSaved: (value) {
                  _authData['email'] = value;
                },
              ),
              if (_authMode == AuthMode.Login || _authMode == AuthMode.Signup)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5)
                      return 'Password is too short!';
                    else if (value.contains(' '))
                      return 'Cannot contain whitespaces.';
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
              if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                  }
                      : null,
                ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                RaisedButton(
                  child:
                  Text(_authMode == AuthMode.Login ? 'LOGIN' : _authMode == AuthMode.Signup ? 'SIGN UP' : 'Reset Password'),
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color,
                ),
              FlatButton(
                child: Text(
                    '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                onPressed: _switchAuthMode,
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textColor: Theme.of(context).primaryColor,
              ),
              if (_authMode == AuthMode.Login)
                FlatButton(
                child: Text(
                    'Reset Password'),
                onPressed: () {
                  setState(() {
                    this._authMode = AuthMode.Reset;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
