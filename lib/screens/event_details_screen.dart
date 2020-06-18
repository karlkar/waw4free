import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/event_data.dart';
import '../model/event_details.dart';
import '../sources/event_details_source.dart';
import '../sources/favorites_source.dart';

const _API_KEY = "AIzaSyBwmwMZawjBB8vNKl35xZfSJRkGnoAdYZk";

class EventDetailsScreen extends StatelessWidget {
  static const namedRoute = "/event-details";
  final EventData _eventData;

  EventDetailsScreen(this._eventData);

  String _getDateText(EventData eventData, EventDetails eventDetails) {
    if (eventDetails.endDate == null) {
      return eventDetails.startDate;
    } else {
      return "${eventDetails.startDate} - ${eventDetails.endDate}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventDetailsSource = EventDetailsSource();
    return Scaffold(
      floatingActionButton: _FavoriteIcon(_eventData.id),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _eventData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: _eventData.id,
                child: Image.network(
                  _eventData.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              FutureBuilder<EventDetails>(
                future: eventDetailsSource.fetchEventDetails(_eventData),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            _getDateText(_eventData, snapshot.data),
                            style: Theme.of(context).textTheme.title,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.0),
                          _MapLoadingWidget(snapshot.data.location),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              _ActionButtonWidget(
                                label: "Strona",
                                url: snapshot.data.sourceUrl,
                              ),
                              RaisedButton(
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          child: ExtendedImage.network(
                                            _eventData.imageUrl,
                                            excludeFromSemantics: false,
                                            enableSlideOutPage: true,
                                            fit: BoxFit.contain,
                                            mode: ExtendedImageMode.Gesture,
                                            initGestureConfigHandler: (state) {
                                              return GestureConfig(
                                                  minScale: 1.0,
                                                  animationMinScale: 0.7,
                                                  maxScale: 3.0,
                                                  animationMaxScale: 3.5,
                                                  speed: 1.0,
                                                  inertialSpeed: 100.0,
                                                  initialScale: 1.0,
                                                  inPageView: false);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text("Foto"),
                              ),
                            ],
                          ),
                          Text(snapshot.data.description),
                          SizedBox(height: 50),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      height: 200,
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FavoriteIcon extends StatefulWidget {
  final String eventId;

  _FavoriteIcon(this.eventId);

  @override
  __FavoriteIconState createState() => __FavoriteIconState();
}

class __FavoriteIconState extends State<_FavoriteIcon> {
  bool _isFavorite = false;
  final FavoritesSource _favoritesSource = FavoritesSource();

  @override
  void initState() {
    _favoritesSource.isFavorite(widget.eventId).then((isFavorite) {
      setState(() {
        _isFavorite = isFavorite;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        bool success;
        if (_isFavorite) {
          success = await _favoritesSource.removeFavorite(widget.eventId);
        } else {
          success = await _favoritesSource.addFavorite(widget.eventId);
        }
        if (success) {
          setState(() {
            _isFavorite = !_isFavorite;
          });
        }
      },
      child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
    );
  }
}

class _ActionButtonWidget extends StatelessWidget {
  final String label;
  final String url;

  const _ActionButtonWidget({this.label, this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: canLaunch(url),
      builder: (BuildContext ctx, AsyncSnapshot<bool> futureResult) {
        final buttonActive = futureResult.hasData &&
            futureResult.data != null &&
            futureResult.data;
        return RaisedButton(
          child: Text(label),
          onPressed: buttonActive
              ? () async {
                  await launch(url);
                }
              : null,
        );
      },
    );
  }
}

class _MapLoadingWidget extends StatelessWidget {
  final String location;

  const _MapLoadingWidget(this.location);

  static const _imageHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: GestureDetector(
        onTap: () async {
          await launch(MapsLauncher.createQueryUrl(location));
        },
        child: Image.network(
          "https://maps.googleapis.com/maps/api/staticmap?center=$location&zoom=14&size=600x300&maptype=roadmap&markers=color:red|$location&key=$_API_KEY",
          height: _imageHeight,
          fit: BoxFit.cover,
          frameBuilder: (BuildContext context, Widget child, int frame,
              bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            } else {
              return Container(
                height: _imageHeight,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    child,
                    AnimatedOpacity(
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      opacity: frame == null ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
