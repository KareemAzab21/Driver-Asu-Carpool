import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Profile.dart';
import 'Offer.dart';
import 'Request.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASU CarPool Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      routes: {
        '/Profile':(context)=>EditProfilePage(),
        '/Offer':(context)=> OfferRidePage(),
        '/Home':(context)=> HomePage(),
        '/Request':(context)=>RequestsPage()
      },
    );
  }
}

class HomePage extends StatelessWidget {

  User? user = FirebaseAuth.instance.currentUser;

  Future<String> getUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Reference to Firestore collection
      var usersCollection = FirebaseFirestore.instance.collection('drivers');
      var docSnapshot = await usersCollection.doc(uid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userRow = docSnapshot.data()!;
        return "${userRow['firstname']} ${userRow['lastname']}";
      }
    }
    return "User";
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
            Text('ASU CarPool Service'),
          ],
        ),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Adjust the radius here
                child: Image.asset(
                  'Assets/Home.png',
                  width: 400, // Adjust width and height to make the image larger
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Find a Ride Button
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.search, color: Colors.white),
                label: Text('Offer a Ride'),
                onPressed: () => Navigator.pushReplacementNamed(context, '/Offer'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Styled Manage Account Button
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('Manage Account'),
                onPressed: () => Navigator.pushReplacementNamed(context, '/Profile'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: getUserName(), // the function to get user data
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                } else {
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Welcome ${snapshot.data}', // display the user name
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle 'Home' navigation
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Offer a Ride'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/Offer');

              },
            ),
            ListTile(
              leading: Icon(Icons.watch_later),
              title: Text('Your Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/Request');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Manage Account'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context,'/Profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () async{
                await FirebaseAuth.instance.signOut();
                // Handle 'Sign Out' action
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(context, '/Signout');
                // Implement sign out functionality
              },
            ),
            // ... Add other ListTile widgets if needed
          ],
        ),
      ),
    );
  }
}
