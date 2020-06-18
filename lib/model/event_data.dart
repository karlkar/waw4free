import 'filter_data.dart';

class EventData {
  final String id;
  final String name;
  final String imageUrl;
  final String url;
  final Set<String> categories;
  final String time;
  final String place;

  EventData({
    this.id,
    this.name,
    this.imageUrl,
    this.url,
    this.categories,
    this.time,
    this.place,
  });
  
  bool matchesFilter(FilterData filter) {
    if (filter == null) {
      return true;
    }
    if (filter.text != null) {
      if (!name.toLowerCase().contains(filter.text.toLowerCase())) {
        return false;
      }
    }
    if (filter.places != null) {
      if (!filter.places.contains(place)) {
        return false;
      }
    }
    if (filter.categories != null) {
      for (var filterCategory in filter.categories) {
        if (!categories.contains(filterCategory)) {
          return false;
        }
      }
    }
    return true;
  }
}
