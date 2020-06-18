import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/events_data.dart';
import '../model/filters_data.dart';
import '../sources/favorites_source.dart';
import '../widgets/event_item_widget.dart';

class OverviewScreen extends StatefulWidget {
  static const namedRoute = "/";

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _favoriteView = false;

  @override
  void initState() {
    _refreshEvents();
    super.initState();
  }

  Future<bool> _refreshEvents() {
    return Provider.of<EventsData>(context, listen: false).fetchEvents();
  }

  void _onFilterClicked(BuildContext context) {
    showModalBottomSheet(
      elevation: 8.0,
      context: context,
      builder: (BuildContext ctx) {
        return _FilterModalDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waw4Free"),
        actions: <Widget>[
          IconButton(
            icon: Icon(_favoriteView ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              Provider.of<FiltersData>(context, listen: false)
                  .setFavorites(!_favoriteView);
              setState(() {
                _favoriteView = !_favoriteView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _onFilterClicked(context),
          ),
        ],
      ),
      body: _MainWidget(_refreshEvents),
    );
  }
}

class _MainWidget extends StatelessWidget {
  final Function _refreshEvents;

  _MainWidget(this._refreshEvents);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: Consumer<EventsData>(
        builder: (BuildContext ctx, EventsData events, progressIndicator) {
          return Consumer<FiltersData>(
            builder: (BuildContext ctx, FiltersData filters, _) {
              var filteredEvents = events.items
                  .where((event) => event.matchesFilter(filters.filterData));
              return FutureBuilder(
                future: FavoritesSource().favorites,
                initialData: [],
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (filters.filterData.favorites &&
                      snapshot.hasData &&
                      snapshot.data != null) {
                    filteredEvents = filteredEvents
                        .where((event) => snapshot.data.contains(event.id));
                  }
                  return filteredEvents.isEmpty
                      ? progressIndicator
                      : ListView.builder(
                          itemBuilder: (BuildContext ctx, int index) {
                            final item = filteredEvents.toList()[index];
                            return EventItemWidget(
                              key: Key(item.id),
                              eventData: item,
                            );
                          },
                          itemCount: filteredEvents.length,
                        );
                },
              );
            },
          );
        },
        child: const Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}

typedef Set<String> SetCreator();
typedef void OnChange(Set<String> set);

class _SetPickerWidget extends StatefulWidget {
  final String buttonLabel;
  final IconData iconData;
  final SetCreator setCreator;
  final OnChange onChange;

  _SetPickerWidget({
    @required this.buttonLabel,
    @required this.iconData,
    @required this.setCreator,
    @required this.onChange,
    initialData,
  }) {
    chosenElements.addAll(initialData);
  }

  final Set<String> chosenElements = {};

  @override
  _SetPickerWidgetState createState() => _SetPickerWidgetState();
}

class _SetPickerWidgetState extends State<_SetPickerWidget> {
  @override
  Widget build(BuildContext context) {
    final dropdownItems = widget
        .setCreator()
        .where((category) => !widget.chosenElements.contains(category))
        .map((String elem) => DropdownMenuItem(
              value: elem,
              child: Text(elem),
            ))
        .toList()
          ..sort((drop1, drop2) => drop1.value.compareTo(drop2.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(widget.iconData),
            SizedBox(width: 8.0),
            DropdownButton<String>(
              hint: Text(widget.buttonLabel),
              onChanged: (String element) {
                setState(() {
                  widget.chosenElements.add(element);
                });
                widget.onChange(widget.chosenElements);
              },
              value: null,
              items: dropdownItems,
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.chosenElements.map((element) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Chip(
                  backgroundColor: Theme.of(context).accentColor,
                  label: Text(
                    element,
                    style: Theme.of(context).textTheme.body1,
                  ),
                  deleteIconColor: Theme.of(context).errorColor,
                  deleteIcon: const Icon(Icons.delete),
                  onDeleted: () {
                    setState(() {
                      widget.chosenElements.remove(element);
                    });
                    widget.onChange(widget.chosenElements);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FilterModalDialog extends StatefulWidget {
  @override
  __FilterModalDialogState createState() => __FilterModalDialogState();
}

class __FilterModalDialogState extends State<_FilterModalDialog> {
  final TextEditingController _textController = TextEditingController();
  final Set<String> _chosenCategories = {};
  final Set<String> _chosenPlaces = {};

  DateTime _startDate;
  DateTime _endDate;

  @override
  void initState() {
    final filterData =
        Provider.of<FiltersData>(context, listen: false).filterData;
    if (filterData != null) {
      _textController.text = filterData.text;
      if (filterData.categories != null) {
        _chosenCategories
          ..clear()
          ..addAll(filterData.categories);
      }
      if (filterData.places != null) {
        _chosenPlaces
          ..clear()
          ..addAll(filterData.places);
      }
      if (filterData.startDate != null) {
        _startDate = filterData.startDate;
      }
      if (filterData.endDate != null) {
        _endDate = filterData.endDate;
      }
    }
    if (_startDate == null) {
      _startDate = DateTime.now();
    }
    if (_endDate == null) {
      _endDate = DateTime.now().add(Duration(days: 7));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final eventsData = Provider.of<EventsData>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.text_fields),
                SizedBox(width: 8.0),
                Flexible(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: "Text"),
                  ),
                ),
              ],
            ),
            _SetPickerWidget(
              buttonLabel: "Wybierz kategorię",
              iconData: Icons.category,
              initialData: _chosenCategories,
              setCreator: () =>
                  eventsData.items.map((event) => event.categories).reduce(
                        (Set<String> all, Set<String> cur) => all..addAll(cur),
                      ),
              onChange: (Set<String> set) {
                _chosenCategories
                  ..clear()
                  ..addAll(set);
              },
            ),
            _SetPickerWidget(
              buttonLabel: "Wybierz dzielnicę",
              iconData: Icons.place,
              initialData: _chosenPlaces,
              setCreator: () =>
                  eventsData.items.map((event) => event.place).toSet(),
              onChange: (Set<String> set) {
                _chosenPlaces
                  ..clear()
                  ..addAll(set);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    DateTime startDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().add(Duration(days: -1)),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                    );
                    if (startDate != null) {
                      setState(() {
                        _startDate = startDate;
                      });
                    }
                  },
                  child: Text("${DateFormat.yMd().format(_startDate)}"),
                ),
                RaisedButton(
                  onPressed: () async {
                    DateTime endDate = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime.now().add(Duration(days: -1)),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                    );
                    if (endDate != null) {
                      setState(() {
                        _endDate = endDate;
                      });
                    }
                  },
                  child: Text("${DateFormat.yMd().format(_endDate)}"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    String textFilter;
                    if (_textController.text.isNotEmpty) {
                      textFilter = _textController.text;
                    }
                    Set<String> placesFilter;
                    if (_chosenPlaces.isNotEmpty) {
                      placesFilter = _chosenPlaces;
                    }
                    Set<String> categoriesFilter;
                    if (_chosenCategories.isNotEmpty) {
                      categoriesFilter = _chosenCategories;
                    }
                    Provider.of<FiltersData>(context, listen: false).setFilters(
                      textFilter,
                      placesFilter,
                      categoriesFilter,
                      _startDate,
                      _endDate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Filtruj"),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                      _chosenCategories.clear();
                      _chosenPlaces.clear();
                      _startDate = DateTime.now();
                      _endDate = DateTime.now().add(Duration(days: 7));
                    });
                  },
                  child: const Text("Wyczyść"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
