import 'dart:convert' show utf8;

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import '../model/event_data.dart';
import '../model/event_details.dart';

class EventDetailsSource {

  RegExp _datePattern = RegExp(r"(\d\d\d\d-\d\d?-\d\d?)");

  Future<EventDetails> fetchEventDetails(EventData eventData) async {
    final response = await http.get(eventData.url);
    if (response.statusCode == 200) {
      final parsed = parser.parse(utf8.decode(response.bodyBytes));
      final article = parsed.getElementsByClassName("article").first;
      final spans = article.getElementsByTagName("span");
      String address;
      for (var span in spans) {
        if (span.attributes['itemprop'] == "address") {
          address = span.text;
          continue;
        }
        if (span.attributes['itemprop'] == "name") {
          address = span.text;
          break;
        }
      }
      var description =
          article.getElementsByClassName("article_text").first.text;
      var sourceUrl = article
          .getElementsByClassName("article_footer")
          .first
          .getElementsByTagName("a")
          .first
          .attributes['href'];

      final anchors = article
          .getElementsByClassName("article_data")[0]
          .getElementsByTagName("a");
      String startDate;
      String endDate;
      for (var anchor in anchors) {
        final match = _datePattern.firstMatch(anchor.attributes['href']);
        if (match == null) {
          continue;
        }
        if (startDate == null) {
          startDate = match.group(1);
        } else {
          endDate = match.group(1);
          break;
        }
      }

      return EventDetails(
        startDate: startDate,
        endDate: endDate,
        description: description,
        location: address,
        sourceUrl: sourceUrl,
      );
    }
    return null;
  }
}
