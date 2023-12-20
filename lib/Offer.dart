import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';

class OfferRidePage extends StatefulWidget {
  @override
  _OfferRidePageState createState() => _OfferRidePageState();
}

class _OfferRidePageState extends State<OfferRidePage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime =
      TimeOfDay(hour: 7, minute: 30); // Default time for the morning ride
  bool isToUniversity = true; // Default direction
  TextEditingController _locationController = TextEditingController();

  TextEditingController _stopsController =
      TextEditingController(); // Controller for stops
  TextEditingController _priceController =
      TextEditingController(); // Controller for price

  String generateUniqueId() {
    var uniqueId = FirebaseFirestore.instance.collection('dummy').doc().id;
    return uniqueId;
  }

  void _showConfirmation(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ride Offered"),
          content: Text(
              "Ride has been Offered Successfully, Track the ride request in YOUR REQUESTS"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog
                Navigator.pushReplacementNamed(context, '/Home');
              },
            ),
          ],
        );
      },
    );

  }

  // Dynamic list to hold the stops
  List<TextEditingController> _stopsControllers = [];

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
            Text('Offer a Ride'),
          ],
        ),
      ),
      body: ListView(children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Select Date (Except Fridays):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(DateFormat("yyyy-MM-dd").format(selectedDate)),
                ),
                SizedBox(height: 20),
                Text(
                  "Select Direction:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('To Ain Shams University'),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: isToUniversity,
                    onChanged: (bool? value) {
                      setState(() {
                        isToUniversity = value!;
                        selectedTime =
                            TimeOfDay(hour: 7, minute: 30); // Morning time
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('From Ain Shams University'),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: isToUniversity,
                    onChanged: (bool? value) {
                      setState(() {
                        isToUniversity = value!;
                        selectedTime =
                            TimeOfDay(hour: 17, minute: 30); // Evening time
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Selected Time: ${selectedTime.format(context)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Your Location',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Add Stops:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _stopsControllers.length,
                  itemBuilder: (context, index) {
                    return TextField(
                      controller: _stopsControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Stop ${index + 1}',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeStop(index),
                        ),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: _addNewStop,
                  child: Text("Add Stop"),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Assuming you have the document ID where the 'Rides' array is stored
                        String documentId =
                            'ycZ5NZGj2B6Xe5ILWb7l'; // Replace with actual document ID
                        if (_locationController.text.isEmpty ||
                            _priceController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Missing Information"),
                                content: Text(
                                    "Please enter both a location and a price to offer a ride."),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        final DateTime now = DateTime.now();
                        final DateTime cutoffMorning = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                22,
                                0)
                            .subtract(Duration(days: 1));
                        final DateTime cutoffEvening = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            13,
                            0);

                        bool isMorningRide = isToUniversity &&
                            selectedTime.hour == 7 &&
                            selectedTime.minute == 30;
                        bool isEveningRide = !isToUniversity &&
                            selectedTime.hour == 17 &&
                            selectedTime.minute == 30;

                        bool canOfferMorningRide =
                            isMorningRide && now.isBefore(cutoffMorning);
                        bool canOfferEveningRide =
                            isEveningRide && now.isBefore(cutoffEvening);

                        if ((isMorningRide && !canOfferMorningRide) ||
                            (isEveningRide && !canOfferEveningRide)) {
                          String message = isMorningRide
                              ? "The cutoff time for offering a morning ride has passed."
                              : "The cutoff time for offering an evening ride has passed.";
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Cannot Offer Ride"),
                                content: Text(message),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("ByPass"),
                                    onPressed: ()  {
                                      Navigator.of(context).pop();
                                      Map<String, dynamic> newRideData = {
                                      'driver': user.uid,
                                      'date': selectedDate.toIso8601String(),
                                      'time': selectedTime.format(context),
                                      'to': isToUniversity
                                          ? 'Ain Shams University'
                                          : _locationController.text,
                                      'from': isToUniversity
                                          ? _locationController.text
                                          : 'Ain Shams University',
                                      'stops': _stopsControllers
                                          .map((c) => c.text)
                                          .toList(),
                                      'price': _priceController.text,
                                      'id': generateUniqueId(),
                                      'Users': {},
                                    };
                                    DocumentReference documentRef =
                                    FirebaseFirestore.instance
                                        .collection('rides')
                                        .doc(documentId);

                                    // Update the 'Rides' array within the document
                                    documentRef.update({
                                      'Rides':
                                      FieldValue.arrayUnion([newRideData])
                                    });

                                    _showConfirmation(this.context);





                                    },
                                  ),
                                ],
                              );
                            },
                          );


                          return;
                        }

                        // Prepare the new ride data
                        Map<String, dynamic> newRideData = {
                          'driver': user.uid,
                          'date': selectedDate.toIso8601String(),
                          'time': selectedTime.format(context),
                          'to': isToUniversity
                              ? 'Ain Shams University'
                              : _locationController.text,
                          'from': isToUniversity
                              ? _locationController.text
                              : 'Ain Shams University',
                          'stops':
                              _stopsControllers.map((c) => c.text).toList(),
                          'price': _priceController.text,
                          'id': generateUniqueId(),
                          'Users': {},
                        };

                        // Reference to the document that contains the 'Rides' array
                        DocumentReference documentRef = FirebaseFirestore
                            .instance
                            .collection('rides')
                            .doc(documentId);

                        // Update the 'Rides' array within the document
                        await documentRef.update({
                          'Rides': FieldValue.arrayUnion([newRideData])
                        });

                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Ride Offered"),
                              content: Text(
                                  "Ride has been Offered Successfully, Track the ride request in YOUR REQUESTS"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        Navigator.pushReplacementNamed(context, '/Home');
                      } else {
                        // Handle the case when the user is not logged in
                        print("User not logged in");
                      }
                    },
                    child: Text("Offer Ride"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _addNewStop() {
    setState(() {
      _stopsControllers.add(TextEditingController());
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stopsControllers.removeAt(index);
    });
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if (day.weekday == DateTime.friday) {
      return false; // Disables selection of Fridays
    }
    return true;
  }
}
