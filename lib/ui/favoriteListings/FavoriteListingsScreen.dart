import 'package:flutter/material.dart';
import 'package:flutter_listings/constants.dart';
import 'package:flutter_listings/main.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/listingDetails/ListingDetailsScreen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FavoriteListingScreen extends StatefulWidget {
  @override
  _FavoriteListingScreenState createState() => _FavoriteListingScreenState();
}

class _FavoriteListingScreenState extends State<FavoriteListingScreen> {
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  Future<List<ListingModel>> _listingsFuture;
  List<ListingModel> _listings = [];

  @override
  void initState() {
    _listingsFuture = _fireStoreUtils.getFavoriteListings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoritos',
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
                print('_FavoriteListingScreenState.build');
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
        if (!listing.isFav) _listings.remove(listing);
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
                      tooltip: 'Quitar de favoritos',
                      icon: Icon(
                        Icons.favorite,
                        color: Color(COLOR_PRIMARY),
                      ),
                      onPressed: () {
                        MyAppState.currentUser.likedListingsIDs
                            .remove(listing.id);
                        _listings.remove(listing);
                        setState(() {});
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
          // ignore: missing_required_param
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
            // Icon(Icons.star, color: Color(COLOR_PRIMARY)),
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
        Text('Sin Favoritos',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text(
          'Todos tus listados favoritos aparecerán aquí una vez que hagas clic en el boton ❤ .',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
