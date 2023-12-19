import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;



  void _register() async {
    // Implement your registration logic here
    print("Register");
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Please enter a valid name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !RegExp(r'^\d{2}p\d{4}@eng\.asu\.edu\.eg$').hasMatch(value)) {
      return 'Email must be in the format of xxpxxx@eng.asu.edu.eg';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    CollectionReference drivers = FirebaseFirestore.instance.collection('drivers');
    return Scaffold(
      body: SingleChildScrollView( // Wrap your content with a SingleChildScrollView to avoid overflow
        child:Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: Image.asset(
                              'Assets/asu.png', // Path to your image
                              width: 80.0, // Set the width of the image
                              height: 80.0, // Set the height of the image
                              fit: BoxFit.cover, // Cover ensures the image fills the space, might crop if not a square
                            ),
                          ),
                          const SizedBox(width: 10.0), // Provide some horizontal spacing
                          Text(
                            "ASU Car Pool Service",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _firstController,
                      decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          )
                      ),
                      validator: _validateName,
                    ),
                    TextFormField(
                      controller: _lastController,
                      decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          )
                      ),
                      validator: _validateName,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          )
                      ),
                      validator: _validateEmail,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          )
                      ),
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    SizedBox(height: 40),
                    Container(
                      height: 40,
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        shadowColor: Colors.greenAccent,
                        color: Colors.blueAccent,
                        elevation: 7,
                        child: GestureDetector(
                            onTap: () async{
                              if (_formKey.currentState!.validate()) {
                                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                                String uid = userCredential.user!.uid; // Get the newly created user's UID
                                drivers.doc(uid).set(
                                    {
                                      'firstname': _firstController.text,
                                      'lastname': _lastController.text,
                                      'email': _emailController.text
                                    }


                                );

                                DocumentReference docRef = firestore.collection('requests').doc(uid);

                                docRef.get().then((docSnapshot) {
                                  // Check if the document exists
                                  if (!docSnapshot.exists) {
                                    // If the document does not exist, create it empty
                                    docRef.set({'Requests':{}});
                                  }
                                });

                                FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text).then((value) {
                                  Navigator.pushReplacementNamed(context, '/Home');
                                });
                              }
                            },
                            child: Center(
                                child: Text(
                                    'SIGNUP',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat'
                                    )
                                )
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              'Go Back',
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline
                              )
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
