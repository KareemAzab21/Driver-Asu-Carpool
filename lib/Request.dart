import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsPage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's ID
    User? currentUser = FirebaseAuth.instance.currentUser;


    Future<String> getUserName() async {
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
    Stream<List<Map<String, dynamic>>> requestStream() {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Stream.value([]); // Return an empty stream if the user is not logged in
      }

      // Listen for real-time updates in the 'requests' document for the current user
      return FirebaseFirestore.instance
          .collection('requests')
          .doc(currentUser.uid)
          .snapshots()
          .map((requestSnapshot) {
        if (!requestSnapshot.exists || !requestSnapshot.data()!.containsKey('Requests')) {
          return []; // Return an empty list if the document or key 'Requests' does not exist
        }

        List<dynamic> requestsArray = requestSnapshot.get('Requests');
        // Transform the dynamic list to a list of maps
        return requestsArray.map<Map<String, dynamic>>((requestItem) {
          return {
            'fromLocation': requestItem['fromLocation'],
            'toLocation': requestItem['toLocation'],
            'date': requestItem['date'],
            'time': requestItem['time'],
            'driver': requestItem['driver'],
            'price': requestItem['price'] is int ? (requestItem['price'] as int).toDouble() : requestItem['price'],
            'status': requestItem['status'],
            'user':requestItem['user'],
            'username':requestItem['username'],
            'id':requestItem['id'],

          };
        }).toList();
      });
    }

    Future<void> updateRideStatusInHistory(Map<String, dynamic> rideToUpdate, String newStatus) async {
      var historyDocRef = FirebaseFirestore.instance.collection('history').doc(rideToUpdate['user']);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var historySnapshot = await transaction.get(historyDocRef);

        if (historySnapshot.exists && historySnapshot.data()!.containsKey('History')) {
          var historyData = historySnapshot.data();
          var historyArray = List<Map<String, dynamic>>.from(historyData!['History']);

          // Find the index of the ride to update
          var index = historyArray.indexWhere((ride) =>
          ride['id'] == rideToUpdate['id']
          );

          // If found, update the status of the ride
          if (index != -1) {
            historyArray[index]['status'] = newStatus;
          } else {
            // Handle the case where the ride is not found
            print("Ride not found in history.");
             return;
          }

          // Write the updated history array back to Firestore
          transaction.set(historyDocRef, {'History': historyArray}, SetOptions(merge: true));
        } else {
          // Handle the case where the History key doesn't exist, or the document doesn't exist
          print("No history found for this user.");
        }
      }).catchError((error) {
        print("Error updating ride status in history: $error");
      });
    }

    Future<void> appendUserIdToRideUsers(String rideId, String userId) async {
      // Reference to the Firestore collection where rides are stored
      var ridesCollectionRef = FirebaseFirestore.instance.collection('rides');

      // Transaction to read and write atomically to the database
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get all ride documents from the collection
        var querySnapshot = await ridesCollectionRef.get();
        for (var doc in querySnapshot.docs) {
          // Get the current ride data
          var rideData = doc.data();
          var ridesList = List<Map<String, dynamic>>.from(rideData['Rides']);

          // Find the index of the ride with the matching ID
          var rideIndex = ridesList.indexWhere((ride) => ride['id'] == rideId);
          if (rideIndex != -1) {
            // If the ride is found, append the userId to its 'Users' list
            var usersList = List<String>.from(ridesList[rideIndex]['Users'] ?? []);
            if (!usersList.contains(userId)) {
              usersList.add(userId);
            }
            // Update the 'Users' list in the ride
            ridesList[rideIndex]['Users'] = usersList;
            // Update the ride document
            transaction.update(doc.reference, {'Rides': ridesList});
            return;
          }
        }
        throw Exception("Ride with ID $rideId not found.");
      }).catchError((error) {
        print("Error appending user to ride: $error");
      });
    }



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
            Text('Your Requests'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: requestStream(), // Use the separate function here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No requests found'));
          }

          var requestData = snapshot.data!;

          // Build the list of cards
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requestData.length,
            itemBuilder: (context, index) {
              var request = requestData[index];

              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Assuming you have a variable `userName` that holds the user's name
                      Text(
                        'User: ${request['username']}', // Replace $userName with the variable that holds the actual name
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey, // Choose a color that fits your app theme
                        ),
                      ),
                      SizedBox(height: 8.0), // Space between the name and the ride details
                      Text(
                        'From: ${request['fromLocation']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'To: ${request['toLocation']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Price: ${request['price']}',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Time: ${request['time']}',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      Divider(color: Colors.grey[300], height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green[700]),
                            iconSize: 30.0, // Adjust the icon size here
                            onPressed: () async {
                              String dateTimeString = request['date']; // Example date-time from screenshot
                              String timeString = request['time']; // Example time in 12-hour format

// Extract the date part from the dateTimeString
                              String dateString = dateTimeString.split("T")[0]; // "2023-12-13"

// Convert 12-hour format time to 24-hour format
                              int hour = int.parse(timeString.split(":")[0]);
                              int minute = int.parse(timeString.split(":")[1].split(" ")[0]);
                              String amPm = timeString.split(" ")[1];
                              if (amPm == "PM" && hour != 12) {
                                hour = hour + 12;
                              } else if (amPm == "AM" && hour == 12) {
                                hour = 0;
                              }
                              DateTime rideDateTime = DateTime(
                                  int.parse(dateString.split("-")[0]), // Year
                                  int.parse(dateString.split("-")[1]), // Month
                                  int.parse(dateString.split("-")[2]), // Day
                                  hour,
                                  minute
                              );

// Combine date and time into a single DateTime object
                              DateTime cutoff=DateTime.now();
                              if (rideDateTime.hour == 7 && rideDateTime.minute == 30) { // Morning ride
                                cutoff = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 23, 30).subtract(Duration(days: 1));
                              } else if (rideDateTime.hour == 17 && rideDateTime.minute == 30) { // Evening ride
                                cutoff = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 16, 30);
                              } else {
                                // Handle other cases or set a default cutoff
                              }

                              // Check if current time is after the cutoff
                              if (DateTime.now().isAfter(cutoff)){
                                String message = 'Cutoff time has passed';

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Cannot Accept a Ride"),
                                      content: Text(message),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("ByPass"),
                                          onPressed: ()  async{
                                            Navigator.of(context).pop();
                                            await FirebaseFirestore.instance
                                                .collection('requests')
                                                .doc(currentUser?.uid)
                                                .update({
                                              'Requests': FieldValue.arrayRemove([request])
                                            });

                                            updateRideStatusInHistory(request, 'Accepted');
                                            appendUserIdToRideUsers(request['id'],request['user']);






                                          },
                                        ),
                                        TextButton(onPressed:(){
                                          Navigator.pop(context);
                                        }, child: Text('OK'))
                                      ],
                                    );
                                  },
                                );


                                return;
                              }
                              // Handle accept action
                              try {
                                // Delete the request from the 'requests' collection
                                await FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(currentUser?.uid)
                                    .update({
                                  'Requests': FieldValue.arrayRemove([request])
                                });

                                updateRideStatusInHistory(request, 'Accepted');
                                appendUserIdToRideUsers(request['id'],request['user']);

                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to approve request: $e')),
                                );
                              }
                            }
                          ),
                          SizedBox(width: 16.0), // Spacing between the buttons
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red[700]),
                            iconSize: 30.0, // Adjust the icon size here
                            onPressed: ()async {
                              // Handle reject action
                              try {
                                // Delete the request from the 'requests' collection
                                await FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(currentUser?.uid)
                                    .update({
                                  'Requests': FieldValue.arrayRemove([request])
                                });


                                updateRideStatusInHistory(request, 'Rejected');



                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to reject request: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/Home');// Close the drawer
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
