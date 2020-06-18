class FilterData {
  final Set<String> categories;
  final Set<String> places;
  final String text;
  final DateTime startDate;
  final DateTime endDate;
  final bool favorites;

  FilterData({
    this.text,
    this.places,
    this.categories,
    this.startDate,
    this.endDate,
    this.favorites = false,
  });

  FilterData copyWith(
      {String text,
      Set<String> places,
      Set<String> categories,
      DateTime startDate,
      DateTime endDate,
      bool favorites}) {
    if (text == null) {
      text = this.text;
    }
    if (places == null) {
      places = this.places;
    }
    if (categories == null) {
      categories = this.categories;
    }
    if (startDate == null) {
      startDate = this.startDate;
    }
    if (endDate == null) {
      endDate = this.endDate;
    }
    if (favorites == null) {
      favorites = this.favorites;
    }
    return FilterData(
      text: text,
      places: places,
      categories: categories,
      startDate: startDate,
      endDate: endDate,
      favorites: favorites,
    );
  }
}
