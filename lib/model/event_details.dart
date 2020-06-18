import 'package:flutter/foundation.dart';

class EventDetails {
  final String startDate;
  final String endDate;
  final String description;
  final String location;
  final String sourceUrl;

  EventDetails({
    @required this.startDate,
    @required this.endDate,
    @required this.description,
    @required this.location,
    @required this.sourceUrl,
  });
}
