import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import for Firebase Messaging
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key); // Updated constructor

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _residentialAddress = '';
  String _officeAddress = '';
  String _password = '';
  bool _isLoading = false;
  String? _error;

  // Fetch the device token for FCM notifications
  Future<String?> _getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void _register() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch the device token
      String? deviceToken = await _getDeviceToken();

      String? result = await authService.register(
        name: _name,
        email: _email,
        phone: _phone,
        residentialAddress: _residentialAddress,
        officeAddress: _officeAddress,
        password: _password,
        deviceToken: deviceToken, // Pass the token to the auth service
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        setState(() {
          _error = result;
        });
      } else {
        // Successful registration handled by AuthGate
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_error != null)
                    Container(
                      color: Colors.amberAccent,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (val) {
                      setState(() => _name = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      setState(() => _email = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter an email' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      setState(() => _phone = val);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Residential Address'),
                    onChanged: (val) {
                      setState(() => _residentialAddress = val);
                    },
                    validator: (val) => val!.isEmpty
                        ? 'Please enter your residential address'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Office Address'),
                    onChanged: (val) {
                      setState(() => _officeAddress = val);
                    },
                    validator: (val) => val!.isEmpty
                        ? 'Please enter your office address'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => _password = val);
                    },
                    validator: (val) => val!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register, child: const Text('Register')),
                  const SizedBox(height: 20),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Already have an account? Login'))
                ],
              ),
            ))));
  }
}
