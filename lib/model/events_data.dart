import 'dart:convert' show utf8;
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import 'event_data.dart';

class EventsData with ChangeNotifier {
  final Map<String, EventData> _items = {};

  RegExp _imageUrlRegexp = RegExp(r"url\('(.*?)'");
  RegExp _idRegexp = RegExp(r"wydarzenie-(.*?)-");
  RegExp _hourRegexp = RegExp(r"(\d\d:\d\d)");

  static const BASE_URL = "https://waw4free.pl";
  static const BASE_CONTENT_URL =
      "$BASE_URL/warszawa-wydarzenia-"; // add date in format YYYY-MM-DD 2019-08-06
  static const DEFAULT_CARD_BG = "https://waw4free.pl/images/boxbg_n.jpg";

  List<EventData> get items {
    return [..._items.values];
  }

  Future<bool> fetchEvents() async {
    _items.clear();
    var curDate = DateTime.now();
    for (var i = 0; i < 10; ++i) {
      final response = await http.get(
          "$BASE_CONTENT_URL${curDate.year}-${curDate.month}-${curDate.day}");

      if (response.statusCode == 200) {
        final parsed = parser.parse(utf8.decode(response.bodyBytes));
        final container = parsed.getElementById("container");
        for (var child in container.children) {
          if (child.localName == "h3") {
            // if we encounter h3 then we are done with events - further events are free entrance
            break;
          }
          if (child.localName != "div" || child.classes.contains("re-box")) {
            // this is an advertisement
            continue;
          }

          final Set<String> categories = _getCategories(child);
          if (categories == null) {
            // We are on element without category (probably add new event tile)
            continue;
          }
          final imageUrl = _getImageUrl(child);
          final title = _getTitle(child);
          final url = _getUrl(child);
          final id = _getId(url);
          final time = _getTime(child);
          final place = _getPlace(child);

          _items.putIfAbsent(
              id,
              () => EventData(
                    id: id,
                    name: title,
                    imageUrl: imageUrl,
                    url: url,
                    categories: categories,
                    time: time,
                    place: place,
                  ));
        }

        notifyListeners();
      } else {
        return false;
      }
      curDate = curDate.add(Duration(days: 1));
    }
    return true;
  }

  String _getImageUrl(dom.Element child) {
    final boxStyle =
        child.getElementsByClassName("box-image").first.attributes['style'];
    if (boxStyle == null) {
      return DEFAULT_CARD_BG;
    } else {
      final imageUrlMatch = _imageUrlRegexp.firstMatch(boxStyle);
      return "$BASE_URL/${imageUrlMatch.group(1)}" ?? DEFAULT_CARD_BG;
    }
  }

  String _getTitle(dom.Element child) {
    final titleAnchor = child
        .getElementsByClassName("box-title")
        .first
        .getElementsByTagName("a")
        .first;
    return titleAnchor.attributes['title'];
  }

  String _getUrl(dom.Element child) {
    final titleAnchor = child
        .getElementsByClassName("box-title")
        .first
        .getElementsByTagName("a")
        .first;
    return "$BASE_URL/${titleAnchor.attributes['href']}";
  }

  String _getId(String url) {
    return _idRegexp.firstMatch(url).group(1);
  }

  Set<String> _getCategories(dom.Element child) {
    final Set<String> categories = {};
    final categoryBoxes = child.getElementsByClassName("box-category");
    if (categoryBoxes == null || categoryBoxes.length == 0) {
      // We are on element without category (probably add new event tile)
      return null;
    }
    for (var categoryDiv in categoryBoxes.first.children) {
      final categoryName = categoryDiv.getElementsByTagName("a").first.text;
      categories.add(categoryName);
    }
    return categories;
  }

  String _getPlace(dom.Element child) {
    final dataBox = child.getElementsByClassName("box-data").first;
    return dataBox.children[1].text;
  }

  String _getTime(dom.Element child) {
    final dataBox = child.getElementsByClassName("box-data").first;
    final text = dataBox.text;
    final hour = _hourRegexp.firstMatch(text);
    if (hour == null) {
      return dataBox.children[0].text;
    } else {
      return "${dataBox.children[0].text}, ${hour.group(1)}";
    }
  }
}
