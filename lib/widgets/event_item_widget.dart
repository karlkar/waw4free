import 'package:flutter/material.dart';

import '../model/event_data.dart';
import '../screens/event_details_screen.dart';

class EventItemWidget extends StatelessWidget {
  static const double _circularRadius = 15;
  static const double _padding = 8;
  static const double _textPadding = 8;
  static const double _itemHeight = 150;

  final EventData eventData;

  const EventItemWidget({Key key, this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Card(
        elevation: 7.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_circularRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(_circularRadius),
          onTap: () => Navigator.of(context).pushNamed(
            EventDetailsScreen.namedRoute,
            arguments: eventData,
          ),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(_circularRadius),
                  topRight: const Radius.circular(_circularRadius),
                ),
                child: Hero(
                  tag: eventData.id,
                  child: Image.network(
                    eventData.imageUrl,
                    fit: BoxFit.cover,
                    height: _itemHeight,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_textPadding),
                child: Text(
                  eventData.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(
                            width: _padding,
                          ),
                          Flexible(
                            child: Text(
                              eventData.time,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.place,
                            color: Theme.of(context).primaryColor,
                          ),
                          FittedBox(
                            child: Text(eventData.place),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventData.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.all(_textPadding / 2),
                          child: Chip(
                            backgroundColor: Theme.of(context).accentColor,
                            label: Text(
                              category,
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
