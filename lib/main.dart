import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/events_data.dart';
import 'model/filters_data.dart';
import 'screens/event_details_screen.dart';
import 'screens/overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventsData>(
          builder: (ctx) => EventsData(),
        ),
        ChangeNotifierProvider<FiltersData>(
          builder: (ctx) => FiltersData(),
        )
      ],
      child: MaterialApp(
        title: 'Waw4Free',
        theme: ThemeData(
          primaryColor: Colors.indigo,
          accentColor: Colors.lightBlue,
        ),
        initialRoute: OverviewScreen.namedRoute,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case EventDetailsScreen.namedRoute:
              return MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(settings.arguments));
            case OverviewScreen.namedRoute:
              return MaterialPageRoute(builder: (context) => OverviewScreen());
          }
          return null;
        },
      ),
    );
  }
}
