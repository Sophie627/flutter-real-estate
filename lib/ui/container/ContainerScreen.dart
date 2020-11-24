import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_listings/constants.dart';
import 'package:flutter_listings/main.dart';
import 'package:flutter_listings/model/User.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/addListing/AddListingScreen.dart';
import 'package:flutter_listings/ui/categories/CategoriesScreen.dart';
import 'package:flutter_listings/ui/conversationsScreen/ConversationsScreen.dart';
import 'package:flutter_listings/ui/home/HomeScreen.dart';
import 'package:flutter_listings/ui/mapView/MapViewScreen.dart';
import 'package:flutter_listings/ui/profile/ProfileScreen.dart';
import 'package:flutter_listings/ui/search/SearchScreen.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Home, Conversations, Categories, Search, Profile }

class ContainerScreen extends StatefulWidget {
  final User user;
  static bool onGoingCall = false;

  ContainerScreen({Key key, @required this.user}) : super(key: key);

  @override
  _ContainerState createState() {
    return _ContainerState(user);
  }
}

class _ContainerState extends State<ContainerScreen> {
  final User user;
  DrawerSelection _drawerSelection = DrawerSelection.Home;
  String _appBarTitle = 'Inicio';

  int _selectedTapIndex = 0;

  _ContainerState(this.user);

  Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _currentWidget = HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: user,
      child: Scaffold(
        bottomNavigationBar: Platform.isIOS
            ? BottomNavigationBar(
                currentIndex: _selectedTapIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      {
                        setState(() {
                          _selectedTapIndex = 0;
                          _drawerSelection = DrawerSelection.Home;
                          _appBarTitle = 'Inicio';
                          _currentWidget = HomeScreen();
                        });
                        break;
                      }
                    case 1:
                      {
                        setState(() {
                          _selectedTapIndex = 1;
                          _drawerSelection = DrawerSelection.Categories;
                          _appBarTitle = 'Categories';
                          _currentWidget = CategoriesScreen();
                        });
                        break;
                      }
                    case 2:
                      {
                        setState(() {
                          _selectedTapIndex = 2;
                          _drawerSelection = DrawerSelection.Conversations;
                          _appBarTitle = 'Conversations';
                          _currentWidget = ConversationsScreen(
                            user: user,
                          );
                        });
                        break;
                      }
                    case 3:
                      {
                        setState(() {
                          _selectedTapIndex = 3;
                          _drawerSelection = DrawerSelection.Search;
                          _appBarTitle = 'Buscar';
                          _currentWidget = SearchScreen();
                        });
                        break;
                      }
                  }
                },
                unselectedItemColor: Colors.grey,
                selectedItemColor: Color(COLOR_PRIMARY),
                items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), title: Text('Inicio')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.category), title: Text('Categorías')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.message),
                        title: Text('Chat')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search), title: Text('Buscar')),
                  ])
            : null,
        drawer: Platform.isIOS
            ? null
            : Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Consumer<User>(
                      builder: (context, user, _) {
                        return DrawerHeader(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              displayCircleImage(
                                  user.profilePictureURL, 75, false),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  user.fullName(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    user.email,
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Color(COLOR_PRIMARY),
                          ),
                        );
                      },
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Home,
                        title: Text('Inicio'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Home;
                            _appBarTitle = 'Inicio';
                            _currentWidget = HomeScreen();
                          });
                        },
                        leading: Icon(Icons.home),
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                          selected:
                              _drawerSelection == DrawerSelection.Categories,
                          leading: Icon(Icons.category),
                          title: Text('Categorías'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _drawerSelection = DrawerSelection.Categories;
                              _appBarTitle = 'Categorías';
                              _currentWidget = CategoriesScreen();
                            });
                          }),
              ),
              ListTileTheme(
                style: ListTileStyle.drawer,
                selectedColor: Color(COLOR_PRIMARY),
                child: ListTile(
                  selected:
                  _drawerSelection == DrawerSelection.Conversations,
                  leading: Icon(Icons.message),
                  title: Text('Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _drawerSelection = DrawerSelection.Conversations;
                      _appBarTitle = 'Chat';
                      _currentWidget = ConversationsScreen(
                        user: user,
                      );
                    });
                  },
                ),
              ),
              ListTileTheme(
                style: ListTileStyle.drawer,
                selectedColor: Color(COLOR_PRIMARY),
                child: ListTile(
                    selected: _drawerSelection == DrawerSelection.Search,
                    title: Text('Buscar'),
                    leading: Icon(Icons.search),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _drawerSelection = DrawerSelection.Search;
                        _appBarTitle = 'Buscar';
                        _currentWidget = SearchScreen();
                      });
                    }),
              ),
              ListTileTheme(
                style: ListTileStyle.drawer,
                selectedColor: Color(COLOR_PRIMARY),
                child: ListTile(
                    selected: _drawerSelection == DrawerSelection.Profile,
                    title: Text('Perfil'),
                    leading: Icon(Icons.account_circle),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _drawerSelection = DrawerSelection.Profile;
                        _appBarTitle = 'Perfil';
                        _currentWidget = ProfileScreen(
                          user: MyAppState.currentUser,
                        );
                      });
                    }),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Platform.isIOS
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: user)));
                      setState(() {});
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(360),
                      child: FadeInImage(
                          fit: BoxFit.cover,
                          placeholder:
                              Image.asset('assets/images/placeholder.jpg')
                                  .image,
                          image: NetworkImage(
                            user.profilePictureURL,
                          )),
                    ),
                  ),
                )
              : null,
          actions: skipNulls([
            _currentWidget is HomeScreen
                ? IconButton(
                    tooltip: 'Adicionar a la lista',
                    icon: Icon(
                      Icons.add,
                    ),
                    onPressed: () => push(context, AddListingScreen()))
                : null,
            _currentWidget is HomeScreen
                ? IconButton(
                    tooltip: 'Mapa',
                    icon: Icon(
                      Icons.map,
                    ),
                    onPressed: () => push(
                      context,
                      MapViewScreen(
                        listings: HomeScreenState.listings,
                        fromHome: true,
                      ),
                    ),
                  )
                : null
          ]),
          title: Text(
            _appBarTitle,
          ),
        ),
        body: _currentWidget,
      ),
    );
  }

}
