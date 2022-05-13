import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:track_star/Login/auth_service.dart';

enum AuthState {
  loggedOut,
  loggedIn,
}

// class Login extends StatelessWidget {
//   const Login({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final authService = context.watch<AuthService>();
//     return Scaffold(
//       body: Container(
//         margin: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
//         child: Authentication(authService: authService),
//         color: Colors.white,
//       ),
//     );
//   }
// }

// class Authentication extends StatefulWidget {
//   const Authentication({Key? key, required this.authService}) : super(key: key);
//   final AuthService authService;
//
//   @override
//   State<Authentication> createState() => _AuthenticationState();
// }
//
// class _AuthenticationState extends State<Authentication> {
//   AuthState get authState => widget.authService.loginState;
//
//   @override
//   Widget build(BuildContext context) {
//     switch (authState) {
//       case AuthState.loggedOut:
//         return EmailForm(
//           callback: (email) => widget.authService.verifyEmail(email, (e) {
//             _showErrorDialog(context, 'Invalid email', e);
//           })
//         );
//       case AuthState.password:
//         return PasswordForm(
//           email: widget.authService.email!,
//           login: (email, password) {
//             widget.authService.signInWithEmailAndPassword(email, password, (e) {
//               _showErrorDialog(context, 'Failed to sign in', e);
//             });
//           },
//         );
//       case AuthState.register:
//         return RegisterForm(
//           email: widget.authService.email!,
//           cancel: () {
//             widget.authService.cancelRegistration();
//           },
//           registerAccount: (email, displayName, password) {
//             widget.authService.registerAccount(email, displayName, password, (e) {
//               _showErrorDialog(context, 'Failed to create account', e);
//             });
//           },
//         );
//       default:
//         return Row(
//           children: const [
//             Text("Internal error, this shouldn't happen..."),
//           ],
//         );
//     }
//   }
//
//   void _showErrorDialog(BuildContext context, String title, Exception e) {
//     showDialog<void>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 24),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(
//                   '${(e as dynamic).message}',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text(
//                 'Ok',
//                 style: TextStyle(color: Colors.deepPurple),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class EmailForm extends StatefulWidget {
  const EmailForm({Key? key, required this.callback}) : super(key: key);
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Login or sign up'),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            widget.callback(_controller.text);
                          }
                        },
                        child: const Text('NEXT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    Key? key,
    required this.registerAccount,
    required this.cancel,
    required this.email,
  }) : super(key: key);
  final String email;
  final void Function(String email, String displayName, String password)
  registerAccount;
  final void Function() cancel;
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Create account'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        hintText: 'Name (optional)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your email address to continue';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.cancel,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.registerAccount(
                                _emailController.text,
                                _displayNameController.text,
                                _passwordController.text,
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordForm extends StatefulWidget {
  const PasswordForm({
    Key? key,
    required this.login,
    required this.email,
  }) : super(key: key);
  final String email;
  final void Function(String email, String password) login;
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sign in'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your email address to continue';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          },
                          child: const Text('Sign in'),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
