import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_listings/constants.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/addListing/AddListingScreen.dart';
import 'package:flutter_listings/ui/filtersScreen/FiltersScreen.dart';
import 'package:flutter_listings/ui/listingDetails/ListingDetailsScreen.dart';
import 'package:flutter_listings/ui/mapView/MapViewScreen.dart';

class CategoryListingsScreen extends StatefulWidget {
  final String categoryID;
  final String categoryName;

  const CategoryListingsScreen({Key key, this.categoryID, this.categoryName})
      : super(key: key);

  @override
  _CategoryListingsScreenState createState() => _CategoryListingsScreenState();
}

class _CategoryListingsScreenState extends State<CategoryListingsScreen> {
  Future<List<ListingModel>> _listingsFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<ListingModel> _list = [];
  Map<String, String> _filters = Map();

  @override
  void initState() {
    _listingsFuture =
        _fireStoreUtils.getListingsByCategoryID(widget.categoryID, _filters);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(COLOR_PRIMARY),
          child: Icon(
            Icons.filter_list,
            color: isDarkMode(context) ? Colors.black : Colors.white,
          ),
          tooltip: 'Filter',
          onPressed: () async {
            _filters = await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return FiltersScreen(filtersValue: _filters);
              },
            );
            if (_filters == null) _filters = Map();
//            setState(() {});
          }),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.map,
              ),
              onPressed: () {
                if (_list.first.categoryTitle.isEmpty) {
                  _list.first.categoryTitle = widget.categoryName;
                }
                push(context, MapViewScreen(listings: _list, fromHome: false));
              })
        ],
        title: Text(
          widget.categoryName,
        ),
      ),
      body: FutureBuilder<List<ListingModel>>(
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
            _list = snapshot.data;
            return ListView.builder(
              itemBuilder: (context, index) {
                ListingModel _listing = snapshot.data[index];
                return Container(
                  height: MediaQuery.of(context).size.height / 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        bool isListingDeleted = await Navigator.of(context)
                            .push(new MaterialPageRoute(
                            builder: (context) =>
                                ListingDetailsScreen(listing: _listing)));
                        if (isListingDeleted != null && isListingDeleted) {
                          snapshot.data.remove(_listing);
                          setState(() {});
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 5,
                            child: displayImage(_listing.photo,
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width / 5),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _listing.title,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode(context)
                                            ? Colors.grey[300]
                                            : Color(0xFF464646)),
                                  ),
                                  Text(
                                    'Added on ${formatReviewTimestamp(_listing.createdAt.seconds)}',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[500]),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        _listing.place,
                                        style: TextStyle(fontSize: 14, color:
                                        Colors.grey),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _listing.price,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context)
                                      ? Colors.grey[300]
                                      : Color(0xFF464646),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data.length,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 60),
            );
          }
        },
        initialData: [],
        future: _listingsFuture,
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 30),
        Text('Sin propiedades',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text(
          'Agregue una nueva propiedad para que aparezca aquí una vez que el administrador la apruebe.',
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
                  'Agregar propiedad',
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
