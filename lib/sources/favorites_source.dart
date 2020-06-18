import 'package:shared_preferences/shared_preferences.dart';

class FavoritesSource {

  Future<List<String>> get favorites async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("FAVORITES") ?? [];
  }

  Future<bool> isFavorite(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList("FAVORITES") ?? [];
    return favorites.contains(eventId);
  }

  Future<bool> addFavorite(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favorites = prefs.getStringList("FAVORITES") ?? [];
    favorites.add(eventId);
    return prefs.setStringList("FAVORITES", favorites);
  }

  Future<bool> removeFavorite(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList("FAVORITES") ?? [];
    favorites.remove(eventId);
    return prefs.setStringList("FAVORITES", favorites);
  }
}