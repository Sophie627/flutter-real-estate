import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_listings/model/CategoriesModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/categoryListings/CategoryListingsScreen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<List<CategoriesModel>> _categoriesFuture;

  @override
  void initState() {
    _categoriesFuture = FireStoreUtils().getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CategoriesModel>>(
          future: _categoriesFuture,
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
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () => push(
                            context,
                            CategoryListingsScreen(
                                categoryID: snapshot.data[index].id,
                                categoryName: snapshot.data[index].name)),
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                snapshot.data[index].name,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 17),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                  image:
                                  NetworkImage(snapshot.data[index].photo),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.darken))),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 15),
        Text('Sin Categorías',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text(
          'Todas las categorías se mostrarán aquí una vez que el administrador las agregue.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 15)
      ],
    );
  }
}
