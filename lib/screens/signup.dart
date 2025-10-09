import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/screens/dashboard.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/models/location_service.dart';
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
      //appBar: AppBar(title: Text('SignUp Form')),
      //appBar: AppBar(title: Text('SignUp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter phone' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 16),
              // Password field (masked)
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
                  // Password is optional for new SignUps, but if provided enforce length
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addresscontroller,
                decoration: InputDecoration(labelText: 'Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Address' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _zipcodecontroller,
                decoration: InputDecoration(labelText: 'Zipcode'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Zipcode' : null,
              ),
              SizedBox(height: 16),
              // Multiple selectable interests using checkboxes
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interests',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedInterests.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select at least one interest'),
                        ),
                      );
                      return;
                    }
                    // Call register function
                    register();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('SignUp record saved.')),
                    );
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => HomeScreen()));
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
