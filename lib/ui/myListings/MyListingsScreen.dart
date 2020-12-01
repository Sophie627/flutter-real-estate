import 'package:flutter/material.dart';
import 'package:flutter_listings/main.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/addListing/AddListingScreen.dart';
import 'package:flutter_listings/ui/listingDetails/ListingDetailsScreen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../constants.dart';

class MyListingsScreen extends StatefulWidget {
  @override
  _MyListingsScreenState createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  Future<List<ListingModel>> _listingsFuture;
  List<ListingModel> _listings = [];

  @override
  void initState() {
    _listingsFuture = _fireStoreUtils.getMyListings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis propiedades',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<ListingModel>>(
            future: _listingsFuture,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data.isEmpty) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: _emptyState(),
                ));
              } else {
                _listings = snapshot.data;
                return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 16),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      return _buildListingCard(_listings[index]);
                    });
              }
            }),
      ),
    );
  }

  Widget _buildListingCard(ListingModel listing) {
    return GestureDetector(
      onTap: () async {
        bool isListingDeleted = await Navigator.of(context).push(
            new MaterialPageRoute(
                builder: (context) => ListingDetailsScreen(listing: listing)));
        if (isListingDeleted != null && isListingDeleted) {
          _listings.remove(listing);
        }
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                displayImage(listing.photo, 150),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      tooltip:
                          listing.isFav ? 'Quitar de favoritos' : 'Favoritos',
                      icon: Icon(
                        Icons.favorite,
                        color:
                            listing.isFav ? Color(COLOR_PRIMARY) : Colors.white,
                      ),
                      onPressed: () {
                        listing.isFav = !listing.isFav;
                        setState(() {});
                        if (listing.isFav) {
                          MyAppState.currentUser.likedListingsIDs
                              .add(listing.id);
                        } else {
                          MyAppState.currentUser.likedListingsIDs
                              .remove(listing.id);
                        }
                        FireStoreUtils.updateCurrentUser(
                            MyAppState.currentUser);
                      }),
                )
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            listing.title,
            maxLines: 1,
            style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode(context) ? Colors.grey[400] : Colors.grey[800],
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(listing.place, maxLines: 1),
          ),
          RatingBar(
            ignoreGestures: true,
            minRating: .5,
            initialRating: listing.reviewsSum != 0
                ? listing.reviewsSum / listing.reviewsCount
                : 0,
            allowHalfRating: true,
            itemSize: 22,
            glow: false,
            unratedColor: Color(COLOR_PRIMARY).withOpacity(0.5),
            // itemBuilder: (context, index) =>
            //     Icon(Icons.star, color: Color(COLOR_PRIMARY)),
            itemCount: 5,
            onRatingUpdate: (newValue) {},
          )
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Sin propiedades',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text(
          'Agrega una nueva propiedad para que aparezca aquí.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
                child: Text(
                  'Ingresar',
                  style: TextStyle(
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                      fontSize: 18),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
                color: Color(COLOR_PRIMARY),
                onPressed: () => push(context, AddListingScreen())),
          ),
        )
      ],
    );
  }
}
