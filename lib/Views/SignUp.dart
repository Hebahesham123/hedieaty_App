import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/User_controller.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = UserController();

  String name = '';
  String email = '';
  String password = '';
  String mobile = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter your password' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mobile'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => mobile = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter your mobile' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      await _controller.signUp(
                        name: name,
                        email: email,
                        password: password,
                        mobile: mobile,
                      );
                      Navigator.pushReplacementNamed(context, '/signin');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign-up failed: $e")));
                    }
                  }
                },
                child: Text("Sign Up"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                child: Text("Already have an account? Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
