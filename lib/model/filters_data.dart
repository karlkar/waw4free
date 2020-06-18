import 'package:flutter/foundation.dart';

import 'filter_data.dart';

class FiltersData with ChangeNotifier {
  FilterData _filterData = FilterData();

  FilterData get filterData {
    return _filterData;
  }

  void setFilters(
    String text,
    Set<String> place,
    Set<String> categories,
    DateTime startDate,
    DateTime endDate,
  ) {
    _filterData = FilterData(
      text: text,
      places: place,
      categories: categories,
      startDate: startDate,
      endDate: endDate,
      favorites: _filterData.favorites
    );
    notifyListeners();
  }

  void setFavorites(bool favorites) {
    _filterData = _filterData.copyWith(favorites: favorites);
    notifyListeners();
  }
}
