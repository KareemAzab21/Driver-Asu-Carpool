import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Reference to Firestore collection
      var usersCollection = FirebaseFirestore.instance.collection('drivers');
      var docSnapshot = await usersCollection.doc(uid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userRow = docSnapshot.data()!;
        _firstNameController.text=userRow['firstname'];
        _lastNameController.text=userRow['lastname'];
        _passwordController.text='';
      }
    }

  }

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: Image.asset(
                'Assets/asu.png',
                fit: BoxFit.cover,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 8), // For spacing between the logo and title
            Text('Edit Your Profile'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTextField(_firstNameController, "First Name"),
            SizedBox(height: 20),
            _buildTextField(_lastNameController, "Last Name"),
            SizedBox(height: 20),
            _buildTextField(_passwordController, "Password", isPassword: true),
            SizedBox(height: 40),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.blue,
              iconSize: 30.0,
              onPressed: () async{
                if(_passwordController.text=='')
                  {
                    await firestore.collection("drivers").doc(currentUser!.uid)
                        .update({
                      'firstname':_firstNameController.text,
                      'lastname':_lastNameController.text
                    });

                  }
                else{
                  await firestore.collection("drivers").doc(currentUser!.uid)
                      .update({
                    'firstname':_firstNameController.text,
                    'lastname':_lastNameController.text
                  });
                  currentUser!.updatePassword(_passwordController.text);
                }
                Navigator.pushReplacementNamed(context, '/Home');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
