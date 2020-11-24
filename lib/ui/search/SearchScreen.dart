import 'package:flutter/material.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/addListing/AddListingScreen.dart';
import 'package:flutter_listings/ui/listingDetails/ListingDetailsScreen.dart';

import '../../constants.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  Future<List<ListingModel>> _listingsFuture;
  List<ListingModel> _filteredListings = [];
  List<ListingModel> _listings = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _listingsFuture = _fireStoreUtils.getListings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
            child: TextField(
              onChanged: _onSearch,
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  isDense: true,
                  fillColor:
                      isDarkMode(context) ? Colors.grey[700] : Colors.grey[200],
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(360),
                      ),
                      borderSide: BorderSide(style: BorderStyle.none)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(360),
                      ),
                      borderSide: BorderSide(style: BorderStyle.none)),
                  hintText: 'Buscar propiedades',
                  suffixIcon: IconButton(
                    focusColor:
                        isDarkMode(context) ? Colors.white : Colors.black,
                    iconSize: 20,
                    icon: Icon(Icons.close),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _onSearch('');
                      setState(() {});
                    },
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
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
                    if (_searchController.text.isNotEmpty &&
                        _filteredListings.isEmpty) {
                      return _emptyQueryResult();
                    }
                    _listings = snapshot.data;
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredListings.isEmpty
                            ? _listings.length
                            : _filteredListings.length,
                        itemBuilder: (context, index) {
                          return _buildListingCard(_filteredListings.isEmpty
                              ? _listings[index]
                              : _filteredListings[index]);
                        });
                  }
                }),
          )
        ],
      ),
    );
  }

  _onSearch(String text) {
    _filteredListings.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _listings.forEach((listing) {
      if (listing.title.toLowerCase().contains(text.toLowerCase())) {
        _filteredListings.add(listing);
      }
    });
    setState(() {});
  }

  Widget _buildListingCard(ListingModel listingModel) {
    return Container(
      height: MediaQuery.of(context).size.height / 7,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            bool isListingDeleted = await Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        ListingDetailsScreen(listing: listingModel)));
            if (isListingDeleted != null && isListingDeleted) {
              _listings.remove(listingModel);
              setState(() {});
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 4,
                child: displayImage(
                    listingModel.photo, MediaQuery.of(context).size.width / 4),
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
                        listingModel.title,
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        'Creado el ${formatReviewTimestamp(listingModel.createdAt.seconds)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            listingModel.place,
                            style: TextStyle(fontSize: 15),
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
                    listingModel.price,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            ],
          ),
        ),
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

  Widget _emptyQueryResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 30),
        Text('No Result',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text(
          'No listing matches the used keyword, Try another keyword.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
