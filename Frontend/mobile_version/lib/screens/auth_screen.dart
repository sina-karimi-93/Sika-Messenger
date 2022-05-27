import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './home_screen.dart';
import '../providers/user_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = './auth-screen';
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _isSendingRequest = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();

  void _login() async {
    /*
    This method responsible for authenticate user and login him/her.
    First it collect email and password from controllers then checks
    whether the form is valid or not. After that, via UserProvider
    send user credential to server and asks for validation. If it
    returns true then user credential is valid and he/she redirect to
    HomeScreen, if not then a alert dialog will be showed.
    */
    final String email = _emailController.value.text;
    final String password = _passwordController.value.text;
    final form = _formKey.currentState;

    if (form!.validate()) {
      setState(() {
        _isSendingRequest = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bool result = await userProvider.login(email, password);

      setState(() {
        _isSendingRequest = false;
      });

      if (result) {
        // Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        return null;
      }
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 0,
              title: const Text("Error"),
              content: const Text("Your credential is not valid!"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Ok"))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          width: size.width * 0.85,
          height: _isLoginMode ? size.height * 0.42 : size.height * 0.6,
          padding:
              const EdgeInsets.only(top: 20, bottom: 4, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 1,
              // color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              color: Colors.cyan,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                blurRadius: 15,
                spreadRadius: 5,
                color: Colors.cyan,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ============================== Email ==============================
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "E-mail is required!";
                      } else if (!value.contains("@") || !value.contains(".")) {
                        return "Invalid email address";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text("E-mail"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  // ============================== Name ==============================
                  if (!_isLoginMode) const SizedBox(height: 30),
                  if (!_isLoginMode)
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required!";
                        } else if (value.length < 3) {
                          return "Password should be at least 3 charracters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text("Full Name"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  // ============================== Phone Number ==============================
                  if (!_isLoginMode) const SizedBox(height: 30),
                  if (!_isLoginMode)
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required!";
                        } else if (value.length < 12) {
                          return "Password should be at least 12 charracters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text("Phone Number"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  // ============================== Password ==============================
                  const SizedBox(height: 30),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password is required!";
                      } else if (value.length < 4) {
                        return "Password should be at least 4 charracters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Password"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                  // ============================== Re-enter Password ==============================
                  if (!_isLoginMode) const SizedBox(height: 30),
                  if (!_isLoginMode)
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _reEnterPasswordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required!";
                        } else if (value.length < 4) {
                          return "Password should be at least 4 charracters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          label: const Text("Re-enter Password"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                    ),
                  // ============================== Button ==============================
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_isLoginMode) {
                        _login();
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoginMode ? "Login" : "Signup",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isSendingRequest) const SizedBox(width: 10),
                        if (_isSendingRequest)
                          const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 2.5,
                            ),
                          )
                      ],
                    ),
                  ),
                  // ============================== TextButton ==============================
                  TextButton(
                    child: Text(
                      _isLoginMode
                          ? "Create new account"
                          : "Already have an account?",
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }
}
