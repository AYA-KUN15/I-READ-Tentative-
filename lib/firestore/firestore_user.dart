import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUser {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(
      String email, String password, Map<String, dynamic> userData) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Save user data to Firestore without createdAt timestamp
    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(userData);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (FirebaseAuth.instance.currentUser?.uid == userId) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  Future<QuerySnapshot> checkEmailExists(String email) async {
    return await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
