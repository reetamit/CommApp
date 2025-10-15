import 'package:flutter/material.dart';
import 'package:flutter_app/models/gradient_theme.dart';
import 'package:flutter_app/models/light_mode.dart';

class AboutUs extends StatelessWidget {
  String about_us =
      '''Welcome to Community Connect \nwhere Local voices, Global impacts.''';

  String about_para =
      '''We’re a community-powered platform built to connect people who care with causes that matter. Whether you're looking to lend a hand at a local shelter, tutor students online, clean up a park, or support a nonprofit’s mission, our app makes volunteering simple, meaningful, and accessible. Our Mission To empower individuals and organizations to create positive change through shared time,skills, and heart. What we do connect volunteers with opportunities that match their passions and availability support nonprofits by amplifying their reach and streamlining volunteer coordination build community by fostering relationships rooted in service, empathy, and impact why it matters. We believe that small acts of kindness can spark big transformations. By making it easier to get involved, we’re helping build a world where everyone contributes— and everyone belongs.
    
Join us. Be part of the change.''';

  String contact_us = '''
  Build by Reetam Biswas
  Get in Touch : reetamit@gmail.com
  Let's Talk      : 617-880-9546

  We Love to Hear From You!''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.light),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                about_us,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              //Text(about_para,style: TextStyle(fontSize: 13)),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                about_para,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
              //Text(about_para,style: TextStyle(fontSize: 13)),
            ),
            SizedBox(height: 5),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Padding(padding: EdgeInsetsGeometry.all(10)),
                ClipRRect(
                  // The value (e.g., 8.0) controls how rounded the corners are.
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit
                        .cover, // Optional: ensures the image fills the space
                  ),
                ),
                //Padding(padding: EdgeInsetsGeometry.all(10)),
                //Icon(Icons.chat, color: AppColors.primaryBlue, size: 25),
                //Padding(padding: EdgeInsetsGeometry.all(10)),
                Text(
                  'Contact Us\n',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),

                Text(
                  contact_us,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                ),
                Padding(padding: EdgeInsetsGeometry.all(10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
