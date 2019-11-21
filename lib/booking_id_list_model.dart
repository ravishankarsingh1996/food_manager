
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppConstants.dart';

class BookingId {
  final List<dynamic> id;
  final DocumentReference reference;

  BookingId.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map[AppConstants.KEY_BOOKING_LIST] != null),
        id = map[AppConstants.KEY_BOOKING_LIST];


  BookingId.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


}
