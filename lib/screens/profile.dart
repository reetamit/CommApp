import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/models/database_service.dart';
import 'package:flutter_app/models/gradient_theme.dart';

class ProfileFormScreen extends StatefulWidget {
  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  //final _passwordController = TextEditingController();
  //bool _obscurePassword = true;
  // allow multiple selections
  Set<String> _selectedInterests = {};

  final List<String> _interests = [
    'Tutoring',
    'Health Care',
    'Cleaning Support',
  ];

  Future<void> _fetchData() async {
    final userEmail =
        authServiceNotifier.value.currentUser?.email ?? 'Email not found';

    /*DataSnapshot? snapshot = await DatabaseService().read(
      path: Words.profileData,
    );

    if (snapshot != null) {
      print(snapshot.value);
      final Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;
      _firstNameController.text = values['firstName'];
    }*/

    Map<String, dynamic>? userProfile = await DatabaseService().getDataByEmail(
      email: userEmail,
      path: Words.profileData,
    );

    if (userProfile != null) {
      _firstNameController.text = userProfile[Words.profilefn];
      _lastNameController.text = userProfile[Words.profilelm];
      _emailController.text = userProfile[Words.profilemail];
      _phoneController.text = userProfile[Words.profileph];

      _selectedInterests = userProfile[Words.profileil]
          .whereType<String>()
          .toSet();
      setState(() {}); // Refresh UI with fetched data
    }
  }

  // This function is called only once.
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void logout() async {
    try {
      await authServiceNotifier.value.signOut();
      print('Log out succcessfully');
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Profile Form')),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
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
              /*TextFormField(
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
                  // Password is optional for new profiles, but if provided enforce length
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),*/
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
                    //await _saveToCsv();
                    if (!mounted) return;
                    //ScaffoldMessenger.of(context).showSnackBar(
                    //  SnackBar(content: Text('Profile saved to CSV')),
                    //);
                    // clear form fields and controllers
                    //_formKey.currentState!.reset();
                    //_firstNameController.clear();
                    //_lastNameController.clear();
                    //_phoneController.clear();
                    //_emailController.clear();
                    //setState(() {
                    //  _selectedInterests.clear();
                    //});
                  }
                },
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text('Save Profile'),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
