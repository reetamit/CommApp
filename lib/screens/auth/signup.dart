import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/screens/auth/agreement_dialog.dart';
import 'package:flutter_app/screens/dashboard.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({super.key});

  @override
  _SignUpFormScreenState createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addresscontroller = TextEditingController();
  final _zipcodecontroller = TextEditingController();
  final _passwordController = TextEditingController();
  String _agreementStatus = 'Please accept the terms to continue.';
  bool didAgree = false;

  bool _obscurePassword = true;
  // allow multiple selections
  final Set<String> _selectedInterests = {};
  String errormessage = '';
  Position? _currentPosition;

  final List<String> _interests = [
    'Tutoring',
    'Health Care',
    'Cleaning Support',
  ];

  void _showTermsDialog() async {
    final didAgree = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return const AgreementDialog();
      },
    );

    if (didAgree != null) {
      setState(() {
        _agreementStatus = didAgree
            ? 'You have accepted the terms.'
            : 'You have declined the terms.';
      });
      // Handle the user's choice, e.g., save it to shared preferences
      // or navigate to a new screen.
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Requests location permission and gets the current position.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      if (mounted) {
        Get.snackbar(
          "Permission Needed",
          "We use your location to show nearby volunteers.",
          onTap: (snack) async {
            await Geolocator.openLocationSettings();
          },
        ).show();
        //ScaffoldMessenger.of(context).showSnackBar(
        // const SnackBar(content: Text('Location services are disabled.')),
        //);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return;
    }

    // Permissions granted, now get the current position.
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      print(
        'Current Position: Lat:${position.latitude}, Lon:${position.longitude}',
      );
      //_findNearbyLocations();
    });
  }

  void register() async {
    // Here you would typically send the data to a backend or save it locally
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final phone = _phoneController.text;
    final email = _emailController.text;
    final password = _passwordController.text; // Optional field
    final interests = _selectedInterests.toList();
    try {
      await authServiceNotifier.value.register(
        email: email,
        password: password,
      );
      // If sign-in is successful, navigate to the Home page
      if (mounted) {
        //TODO:Store the other profile details to database

        Map<String, dynamic> userData = {
          Words.profilefn: firstName,
          Words.profilelm: lastName,
          Words.profileph: phone,
          Words.profilemail: email,
          Words.profilead: _addresscontroller.text,
          Words.profilezc: _zipcodecontroller.text,
          Words.profileil: interests,
          Words.profilelg: _currentPosition?.longitude ?? 0.0,
          Words.profilelt: _currentPosition?.latitude ?? 0.0,
          Words.profilecc: 0,
        };
        await DatabaseService().create(path: Words.profileData, data: userData);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errormessage = e.message ?? 'Invalid email';
      });
    }
    // Here you would add code to save this data to a CSV file or database
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp Form'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
      //appBar: AppBar(title: Text('SignUp')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter first name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter last name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter phone' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addresscontroller,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter Address'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _zipcodecontroller,
                      decoration: const InputDecoration(labelText: 'Zipcode'),
                      keyboardType:
                          TextInputType.number, // Change keyboard type
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter Zipcode'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interests',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          ..._interests.map(
                            (interest) => CheckboxListTile(
                              title: Text(interest),
                              value: _selectedInterests.contains(interest),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(_agreementStatus, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: _showTermsDialog,
                      style: OutlinedButton.styleFrom(
                        // Optional: Customize the border properties
                        side: const BorderSide(
                          color: Colors.black, // The color of the border
                          width: 2.0, // The width of the border
                        ),
                        // Optional: Customize the text color
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.transparent,
                        // Optional: Customize the shape (e.g., add rounded corners)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Click here to view Terms and Conditions',
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedInterests.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select at least one interest',
                                ),
                              ),
                            );
                            return;
                          }
                          if (_agreementStatus ==
                              'You have declined the terms.') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please read and accept terms and conditions!',
                                ),
                              ),
                            );
                            return;
                          }
                          // Call register function
                          register();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('SignUp record saved.'),
                            ),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
