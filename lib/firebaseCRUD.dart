//This is a master file that contains all CREATE, READ, UPDATE, and DELETE functions that relate to the remote DB,
//Make sure to import this file across the project
import 'package:cloud_firestore/cloud_firestore.dart';

// ***ACTIVITY COLLECTION***
// activity has a cost, eventDate, eventName, location (string), and tripId 
Future<void> createActivity(Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('activity').add(data);
}

Future<DocumentSnapshot> readActivity(String documentId) async {
  return await FirebaseFirestore.instance.collection('activity').doc(documentId).get();
}

Future<void> updateActivity(String documentId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('activity').doc(documentId).update(data);
}

Future<void> deleteActivity(String documentId) async {
  await FirebaseFirestore.instance.collection('activity').doc(documentId).delete();
}


// ***BUDGET COLLECTION***
// Budget has totalBudget, totalLeft, totalSpent, tripId
Future<void> createBudget(Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('budget').add(data);
}

Future<DocumentSnapshot> readBudget(String documentId) async {
  return await FirebaseFirestore.instance.collection('budget').doc(documentId).get();
}

Future<void> updateBudget(String documentId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('budget').doc(documentId).update(data);
}


Future<void> deleteBudget(String documentId) async {
  await FirebaseFirestore.instance.collection('budget').doc(documentId).delete();
}

// ***POSTS*** we may have to refactor this later on
// post has content, location, postImage (link in a string), timestamp, and a userId
Future<void> createPost(Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('posts').add(data);
}

Future<DocumentSnapshot> readPost(String documentId) async {
  return await FirebaseFirestore.instance.collection('posts').doc(documentId).get();
}

Future<void> updatePost(String documentId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('posts').doc(documentId).update(data);
}

Future<void> deletePost(String documentId) async {
  await FirebaseFirestore.instance.collection('posts').doc(documentId).delete();
}

// ***TRIPS***
// Trips has budgetId, endTime, startTime, tripName, and userID

Future<void> createTrip(Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('trips').add(data);
}

Future<DocumentSnapshot> readTrip(String documentId) async {
  return await FirebaseFirestore.instance.collection('trips').doc(documentId).get();
}

Future<void> updateTrip(String documentId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('trips').doc(documentId).update(data);
}

Future<void> deleteTrip(String documentId) async {
  await FirebaseFirestore.instance.collection('trips').doc(documentId).delete();
}

// ***Users***
// Users has Password, Username, and userId
// HUZ, look into firebase Auth, lets try and integrate it 
Future<void> createUser(Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('users').add(data);
}

Future<DocumentSnapshot> readUser(String documentId) async {
  return await FirebaseFirestore.instance.collection('users').doc(documentId).get();
}

Future<void> updateUser(String documentId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('users').doc(documentId).update(data);
}

Future<void> deleteUser(String documentId) async {
  await FirebaseFirestore.instance.collection('users').doc(documentId).delete();
}
