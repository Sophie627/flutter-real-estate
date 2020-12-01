import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_listings/constants.dart';
import 'package:flutter_listings/main.dart';
import 'package:flutter_listings/model/CategoriesModel.dart';
import 'package:flutter_listings/model/ListingModel.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/filtersScreen/FiltersScreen.dart';
import 'package:flutter_listings/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: GOOGLE_API_KEY);

class AddListingScreen extends StatefulWidget {

  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  CategoriesModel _categoryValue = new CategoriesModel();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _tourController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  Future<List<CategoriesModel>> _categoriesFuture;
  Map<String, String> _filters = Map();
  PlacesDetailsResponse _placeDetail;
  List<File> _images = [null];
  List<CategoriesModel> _categories = [];
  String categoria = 'Seleccionar';

  @override
  void initState() {
    _categoriesFuture = _fireStoreUtils.getCategories();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Agregar propiedad'),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: <Widget>[
                  Material(
                    color: isDarkMode(context) ? Colors.black12 : Colors.white,
                    type: MaterialType.canvas,
                    elevation: 2,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, right: 16.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Nombre',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                            decoration: InputDecoration(
                              hintText: 'Ingresa el nombre de la propiedad',
                              isDense: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0), //Divisiones entre SingleChildScrollView
                    child: Material(
                      color:
                          isDarkMode(context) ? Colors.black12 : Colors.white,
                      elevation: 2,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 16),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Descripción',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0), // distancia entre titulo y subtitulo
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              controller: _descController,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Cuéntanos los beneficios de esta propiedad',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: isDarkMode(context) ? Colors.black12 : Colors.white,
                    elevation: 2,
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        ListTile(
                          dense: true,
                          title: Text(
                            'Precio',
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '0\$',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                       Padding(
                         padding: const EdgeInsets.only(left:15.0,right:15.0),
                         child: Row(
                           children: [
                             Text("Categoría",  style: TextStyle(fontSize: 20),),
                             
                              Expanded(
                                                            child: FutureBuilder(
                                  
                                    future: _categoriesFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting)
                                        return CircularProgressIndicator();
                                      if (!snapshot.hasData ||
                                          snapshot.data.isEmpty) {
                                        return Center(
                                            child: Text('No se encontraron categorías'));
                                      } else {
                                        _categories = snapshot.data;
                                        return DropdownButton<CategoriesModel>(
                                            selectedItemBuilder:
                                                (BuildContext context) {
                                              return _categories.map<Widget>(
                                                  (CategoriesModel item) {
                                                return SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      item.name,
                                                    ),
                                                  ),
                                                );
                                              }).toList();
                                            },
                                            hint: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Align(
                                                alignment: FractionalOffset(1.8, 0.6), //alineación de hint seleccionar
                                                child: Text(
                                                  categoria,
                                                ),
                                              ),
                                            ),
                                          
                                            underline: Container(),
                                            items: _categories
                                                .map<
                                                    DropdownMenuItem<
                                                        CategoriesModel>>(
                                                  (category) => DropdownMenuItem<
                                                      CategoriesModel>(
                                                    value: category,
                                                    child: Text(
                                                      category.name,
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            icon: Container(),
                                            onChanged: (CategoriesModel model) {
                                              print(model);
                                                _categoryValue = model;
                                                categoria = _categoryValue.name;
                                              setState(() {
                                              
                                              });
                                            });
                                      }
                                    }),
                              ),
                          
                           ],
                         ),
                       ),
                       ListTile(
                          dense: true,
                          title: Text(
                            'Filtros',
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(_filters.isEmpty
                              ? 'Seleccionar'
                              : 'Editar filtros'),
                          onTap: () async {
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
                            setState(() {});
                            print('${_filters.toString()}');
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Ubicación',
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              _placeDetail != null
                                  ? '${_placeDetail.result.formattedAddress}'
                                  : 'Selecciona un lugar',
                              textAlign: TextAlign.end,
                            ),
                          ),
                          onTap: () async {
                            Prediction p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: 'AIzaSyDv6eOohxKNZqM2HchfYIjqOh09CUifAwE',
                              mode: Mode.fullscreen,
                              language: 'en',
                            );
                            if (p != null)
                              _placeDetail =
                                  await _places.getDetailsByPlaceId(p.placeId);
                            setState(() {});
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Galería de la propiedad',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _images.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  File image = _images[index];
                                  return _imageBuilder(image);
                                }),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _tourController,
                              keyboardType: TextInputType.url,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'URL or virtual tour',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                  child: RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: Text(
                        'Publicar',
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 20),
                      ),
                      color: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () => _postListing()),
                  constraints: BoxConstraints(minWidth: double.infinity)),
            ),
          )
        ],
      ),
    );
  }

  Widget _imageBuilder(File imageFile) {
    bool isLastItem = imageFile == null;

    return GestureDetector(
      onTap: () {
        isLastItem ? _pickImage() : _viewOrDeleteImage(imageFile);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: Color(COLOR_PRIMARY),
          child: isLastItem
              ? Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  _viewOrDeleteImage(File imageFile) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            _images.removeLast();
            _images.remove(imageFile);
            _images.add(null);
            setState(() {});
          },
          child: Text("Elimina la foto"),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(
                context,
                FullScreenImageViewer(
                    imageUrl: 'preview', imageFile: imageFile));
          },
          isDefaultAction: true,
          child: Text("Ver galería"),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancelar"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        "FOTOS",
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Selecciona una de tus imágenes"),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            PickedFile image =
                await _imagePicker.getImage(source: ImageSource.gallery);
            if (image != null) {
              _images.removeLast();
              _images.add(File(image.path));
              _images.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Cámara"),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            PickedFile image =
                await _imagePicker.getImage(source: ImageSource.camera);
            if (image != null) {
              _images.removeLast();
              _images.add(File(image.path));
              _images.add(null);
              setState(() {});
            }
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancelar"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _postListing() async {
    if (_titleController.text.trim().isEmpty) {
      showAlertDialog(
          context,'Propiedad',
           'No tiene titulo la propiedad');
    } else if (_tourController.text.isEmpty) {
      showAlertDialog(context, 'Descripción', 'tourUrl is empty');
    }
    else if (_descController.text.trim().isEmpty) {
      showAlertDialog(context, 'Descripción', 
          'Necesita contarnos algo de la propiedad.');
    } else if (_priceController.text.trim().isEmpty) {
      showAlertDialog(
          context, 'Precio', 'Debes darle un valor a la propiedad.');
     /* else if (_categoryValue != null) {
      showAlertDialog(context, 'Categoría',
          'Debes seleccionar una categoria'); */
    } else if (_filters.isEmpty) {
      showAlertDialog(context, 'Filtros',
          'Por favor indicanos lo que estas necesitando');
    /* } else if (_placeDetail == null) {
      showAlertDialog(context, 'Ubicación',
          'Indicános una ubicación válida de la propiedad.'); */
    } else if (_images.length == 1) {
      showAlertDialog(context, 'Fotos',
          'Compartenos algunas impactantes fotos de la propiedad.');
    } else {
      showProgress(context, 'Subiendo imágenes...', false);
      List<String> _imagesUrls =
          await _fireStoreUtils.uploadListingImages(_images);
      updateProgress('Casi estamos terminando...');
      ListingModel newListing = ListingModel(
          title: _titleController.text.trim(),
          createdAt: Timestamp.now(),
          authorID: MyAppState.currentUser.userID,
          authorName: MyAppState.currentUser.fullName(),
          authorProfilePic: MyAppState.currentUser.profilePictureURL,
          categoryID: _categoryValue.id,
          categoryPhoto: _categoryValue.photo,
          categoryTitle: _categoryValue.title,
          description: _descController.text.trim(),
          price: _priceController.text.trim() + '\$',
          tourURL: _tourController.text,
          /*latitude: _placeDetail.result.geometry.location.lat,
          longitude: _placeDetail.result.geometry.location.lng,*/
           latitude: 5.0,
          longitude:5.0,
          filters: _filters,
          photo: _imagesUrls.first,
          place: "Tienes esta solicitud de aprobación",
          reviewsCount: 0,
          reviewsSum: 0,
          isApproved: false,
          photos: _imagesUrls);
      await _fireStoreUtils.postListing(newListing);
      hideProgress();
      _titleController.clear();
      _descController.clear();
      _priceController.clear();
      _categoryValue = null;
      _filters.clear();
      _placeDetail = null;
      _images.clear();
      _imagesUrls.clear();
      setState(() {});
      showAlertDialog(context, 'Propiedad',
      'Su propiedad se guardó satisfactoriamente');
    }
  }
}
