import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:intl/intl.dart'; // For date formatting
import '../functions/form_data.dart'; // Adjust import according to your structure

class PersonalInfoPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  PersonalInfoPage({
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _strandController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<String> strands = ['TVL', 'HUMSS', 'ABM'];

  @override
  void initState() {
    super.initState();
    // Load values from FormData
    _fullNameController.text = FormData().fullName;
    _strandController.text = FormData().strand;
    _birthdayController.text = FormData().birthday;
    _addressController.text = FormData().address;

    // Add listeners to save input in real-time
    _fullNameController.addListener(() {
      FormData().fullName = _fullNameController.text;
    });
    _strandController.addListener(() {
      FormData().strand = _strandController.text;
    });
    _birthdayController.addListener(() {
      FormData().birthday = _birthdayController.text;
    });
    _addressController.addListener(() {
      FormData().address = _addressController.text;
    });
  }

  Future<void> _selectBirthday(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  void _confirmSignUp() {
    if (_fullNameController.text.isEmpty ||
        _strandController.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Prepare the confirmation message
    String message = '''
Please confirm the following information:
- Email: ${widget.emailController.text}
- Username: ${widget.usernameController.text}
- Password: ${widget.passwordController.text}
- Full Name: ${_fullNameController.text}
- Strand: ${_strandController.text}
- Birthday: ${_birthdayController.text}
- Address: ${_addressController.text}
''';

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Up'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and don't save
              Navigator.of(context).pop(); // Close dialog (No)
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              // Proceed to next step on 'Yes'
              Navigator.of(context).pop(); // Close dialog
              // You can navigate to the main page or perform sign-up action here
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "Personify Yourself!",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Add in your personal details here',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Full Name Field
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                hintText: 'Enter Full Name here...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(r'\d')), // Disallow numbers
              ],
            ),
            SizedBox(height: 20),

            // Strand ComboBox with Icon
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Strand',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _strandController.text.isEmpty
                      ? null
                      : _strandController.text,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  isExpanded: true,
                  items: strands.map((String strand) {
                    return DropdownMenuItem<String>(
                      value: strand,
                      child: Row(
                        children: [
                          Icon(Icons.school,
                              color: Colors.white), // Strand icon
                          SizedBox(width: 10),
                          Text(strand, style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _strandController.text = newValue!;
                    });
                  },
                  dropdownColor: Colors.blue[800]?.withOpacity(0.9),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  hint: Text('Select Strand',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Birthday Field
            GestureDetector(
              onTap: () => _selectBirthday(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday (MM/DD/YYYY)',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue[800]?.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[800]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[800]!),
                    ),
                    hintText: 'MM/DD/YYYY...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                hintText: 'Barangay, City...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.location_on, color: Colors.white),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: _confirmSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Terms and Conditions
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(text: 'By signing up, you agree to\n'),
                  TextSpan(
                    text: 'I-READ\'s Terms of Service and Privacy Policy.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Define action for tapping the terms link
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            // Full Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LinearProgressIndicator(
                value: 1.0, // Full progress for the last page
                backgroundColor: Colors.grey[400],
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
