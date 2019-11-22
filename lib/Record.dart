import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_manager/AppConstants.dart';

class Record {
  String email;
  String uid;
  String employeeId;
  String firstName;
  String lastName;
  String qrData;
  DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[AppConstants.KEY_FIRST_NAME] != null),
        assert(map[AppConstants.KEY_LAST_NAME] != null),
        assert(map[AppConstants.KEY_EMAIL] != null),
        assert(map[AppConstants.KEY_EMPLOYEE_ID] != null),
        assert(map[AppConstants.KEY_USER_ID] != null),
        uid = map[AppConstants.KEY_USER_ID],
        email = map[AppConstants.KEY_EMAIL],
        employeeId = map[AppConstants.KEY_EMPLOYEE_ID],
        qrData = map['qrData'],
        firstName = map[AppConstants.KEY_FIRST_NAME],
        lastName = map[AppConstants.KEY_LAST_NAME];

  Record.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    employeeId = json['employeeId'];
    qrData = json['qrData'];
    email = json['email'];
  }

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() {
    return '{"email": "$email", "uid": "$uid", "firstName": "$firstName","employeeId": "$employeeId", "lastName": "$lastName", "qrData": "$qrData", "reference": "$reference"}';
  }
}
