import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/listingDetails/ListingDetailsScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewScreen extends StatefulWidget {
  final List<ListingModel> listings;
  final bool fromHome;

  const MapViewScreen({Key key, this.listings, this.fromHome})
      : super(key: key);

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  LocationData locationData;
  Future _mapFuture = Future.delayed(Duration(milliseconds: 500), () => true);
  GoogleMapController _mapController;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fromHome
              ? 'Localizar'
              : widget.listings.isNotEmpty
                  ? widget.listings.first.categoryTitle
                  : 'Localizar',
        ),
      ),
      body: FutureBuilder(
          future: _mapFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            }
            return GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: List.generate(
                  widget.listings.length,
                  (index) => Marker(
                      markerId: MarkerId("marker_$index"),
                      position: LatLng(widget.listings[index].latitude,
                          widget.listings[index].longitude),
                      infoWindow: InfoWindow(
                          onTap: () {
                            push(
                                context,
                                ListingDetailsScreen(
                                  listing: widget.listings[index],
                                ));
                          },
                          title: widget.listings[index].title))).toSet(),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: locationData == null
                    ? widget.listings.isNotEmpty
                        ? LatLng(widget.listings.first.latitude,
                            widget.listings.first.longitude)
                        : LatLng(0, 0)
                    : LatLng(locationData.latitude, locationData.longitude),
                zoom: 14.4746,
              ),
              onMapCreated: _onMapCreated,
            );
          }),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (isDarkMode(context))
      _mapController.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');

    if (locationData != null)
      _mapController.moveCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude, locationData.longitude)));
  }

  void _getLocation() async {
    locationData = await getCurrentLocation();
    print('_MapViewScreenState._getLocation');
    if (_mapController != null)
      _mapController.moveCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude, locationData.longitude)));
  }
}
