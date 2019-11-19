import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_manager/AppConstants.dart';

class Record {
  final String email;
  final String uid;
  final String firstName;
  final String lastName;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[AppConstants.KEY_FIRST_NAME] != null),
        assert(map[AppConstants.KEY_EMAIL] != null),
        assert(map[AppConstants.KEY_USER_ID] != null),
        uid = map[AppConstants.KEY_USER_ID],
        email = map[AppConstants.KEY_EMAIL],
        firstName = map[AppConstants.KEY_FIRST_NAME],
        lastName = map[AppConstants.KEY_LAST_NAME];


  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


}
