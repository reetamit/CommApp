import 'package:flutter/material.dart';

class AgreementDialog extends StatelessWidget {
  const AgreementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms and Conditions'),
      content: const SingleChildScrollView(
        child: Text('''1. Acceptance of Terms
By downloading, registering, or using the app, users agree to comply with these Terms and Conditions. If they do not agree, they must not use the app.
2. Eligibility
Users must be at least 13 years old (or the minimum age required by local law) to use the app. Parental consent may be required for minors.
3. User Accounts
	•	Users must provide accurate information during registration.
	•	Users are responsible for maintaining the confidentiality of their login credentials.
	•	The app reserves the right to suspend or terminate accounts for violations.
4. Volunteer Opportunities
	•	The app connects users with volunteer opportunities posted by organizations or individuals.
	•	The app does not guarantee the accuracy, safety, or legality of any opportunity.
	•	Users participate at their own risk and are encouraged to verify details independently.
5. Code of Conduct
Users agree to:
	•	Treat others with respect and kindness.
	•	Not post or share offensive, harmful, or illegal content.
	•	Not impersonate others or misrepresent their identity.
6. Content Ownership
	•	Users retain ownership of content they post but grant the app a non-exclusive license to use, display, and distribute it within the app.
	•	The app may remove content that violates these terms.
7. Privacy
	•	The app collects and uses personal data in accordance with its [Privacy Policy].
	•	Users consent to the collection and use of their data for app functionality and communication.
8. Third-Party Links
The app may contain links to third-party websites or services. The app is not responsible for their content or practices.
9. Limitation of Liability
The app is provided "as is" without warranties. The app is not liable for any damages arising from use, including but not limited to injury, loss of data, or missed opportunities.
10. Termination
The app may suspend or terminate access at any time for violations of these terms or for operational reasons.
11. Changes to Terms
The app may update these terms at any time. Continued use after changes constitutes acceptance of the new terms.
12. Governing Law
These terms are governed by the laws of [Your Jurisdiction], without regard to conflict of law principles.
'''),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // This is the crucial line. Pass `false` when declining.
            Navigator.of(context).pop(false);
          },
          child: const Text('Decline'),
        ),
        TextButton(
          onPressed: () {
            // This is the crucial line. Pass `true` when accepting.
            Navigator.of(context).pop(true);
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
