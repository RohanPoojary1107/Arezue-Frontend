/// Auth file that contains all verifications and connections with firebase
///
/// the purpose of this file is so that we can use the functions in this file to communicate with firebase

import 'package:arezue/employer/employer.dart';
import 'package:arezue/services/http.dart';
import 'package:arezue/jobseeker/jobseeker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

abstract class BaseAuth {
  Future signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future createUserWithEmailAndPassword(
      // Create user with the email and password
      String name,
      String email,
      String password,
      String company,
      String type);
  Future<String> currentUser();
  Future<void> signOut();
  Future sendPasswordResetEmail(String email);
  Jobseeker userFromFirebaseUser(FirebaseUser user);
  Future<bool> checkEmailVerification();
  Future<void> sendEmailVerification();
}

class Auth implements BaseAuth {
  String dbID, userType;
  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance; //this will get FirebaseAuth from a
  Requests request = new Requests();

  Future sendPasswordResetEmail(String email) async {
    // Sends password reset email
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Done";
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> sendEmailVerification() async {
    // Sends email verification email
    var user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  @override
  Future createUserWithEmailAndPassword(String name, String email,
      String password, String company, String type) async {
    // Creates user if the email does not exist
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    try {
      await user.sendEmailVerification();
      Future<int> status;
      if (type == "employer") {
        status = request.postRequest("employer", {'firebaseID' : user.uid,
        'email' : email, 'name' : name, 'company' : company});
      } else {
        status = request.postRequest("jobseeker", {'firebaseID' : user.uid,
          'email' : email, 'name' : name});
      }
      if ((await status) == 200) {
        signOut();
        return user;
      } else if ((await status) == 400) {
        print("User could not be created");
        user.delete();
        return null;
      } else {
        user.delete();
        print("server error");
        return null;
      }
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
      return null;
    }
  }

  Future<bool> checkEmailVerification() async {
    // Checks to see if user verified their email or not
    FirebaseUser user = await _firebaseAuth.currentUser();
    bool flag;
    if (user == null) {
      flag = false;
    } else {
      flag = user.isEmailVerified;
    }
    return flag;
  }

  Future<String> currentUser() async {
    // returns the current users database ID
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? dbID : null;
  }

  @override
  Future signInWithEmailAndPassword(String email, String password) async {
    // Signs the user with the email and password
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    try {
      if (user.isEmailVerified) {
        var url = 'https://api.daffychuy.com/api/v1/init';
        var response = await http.post(url, body: {'firebaseID': user.uid});
        var parsedResponse = json.decode(response.body);
        dbID = parsedResponse['payload']['uid'];
        userType = parsedResponse['payload']['user_type'];
        int statusCode = response.statusCode;
        if ((statusCode) == 200) {
          print(userType);
          if (userType == "employer") {
            return Employer.fromJson(parsedResponse);
          } else {
            return Jobseeker.fromJson(parsedResponse);
          }
        } else if (statusCode == 400) {
          print("User not found");
          return null;
        } else {
          print("Server error");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("An error occured while logging in");
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    // Signs the user out
    return _firebaseAuth.signOut();
  }

  @override
  Jobseeker userFromFirebaseUser(FirebaseUser user) {
    // TODO: implement userFromFirebaseUser
    return null;
  }
}
