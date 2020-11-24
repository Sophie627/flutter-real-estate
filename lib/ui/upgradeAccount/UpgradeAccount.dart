import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_listings/services/ConsumableStore.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants.dart';

const bool kAutoConsume = true;

const String _kConsumableId = 'consumable';
const List<String> _kProductIds = [
  'io.instamobile.flutter.android.plan.monthly',
  'io.instamobile.flutter.android.plan.yearly'
];

class UpgradeAccount extends StatefulWidget {
  @override
  _UpgradeAccountState createState() => _UpgradeAccountState();
}

class _UpgradeAccountState extends State<UpgradeAccount> {
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  @override
  void initState() {
    initStoreInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * .85,
        decoration: BoxDecoration(
          color: isDarkMode(context) ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: _upgradeAccount());
  }

  Widget _upgradeAccount() {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          shrinkWrap: true,
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
//            _buildConsumableBox(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    PageController controller = PageController(
      initialPage: 0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: 200,
              child: PageView(
                children: [
                  Image.asset(
                    'assets/images/premium_account_1.png',
                    colorBlendMode: BlendMode.srcOver,
                    color: isDarkMode(context) ? Colors.black38 : null,
                  ),
                  Image.asset(
                    'assets/images/premium_account_2.png',
                    colorBlendMode: BlendMode.srcOver,
                    color: isDarkMode(context) ? Colors.black38 : null,
                  ),
                  Image.asset(
                    'assets/images/premium_account_3.png',
                    colorBlendMode: BlendMode.srcOver,
                    color: isDarkMode(context) ? Colors.black38 : null,
                  ),
                  Image.asset(
                    'assets/images/premium_account_4.png',
                    colorBlendMode: BlendMode.srcOver,
                    color: isDarkMode(context) ? Colors.black38 : null,
                  ),
                  Image.asset(
                    'assets/images/premium_account_5.png',
                    colorBlendMode: BlendMode.srcOver,
                    color: isDarkMode(context) ? Colors.black38 : null,
                  )
                ],
                controller: controller,
              ),
            ),
            Positioned(
              bottom: 0,
              child: SmoothPageIndicator(
                controller: controller,
                count: 5,
                effect: ScrollingDotsEffect(
                    dotWidth: 6,
                    dotHeight: 6,
                    dotColor:
                        isDarkMode(context) ? Colors.white54 : Colors.black54,
                    activeDotColor: Color(COLOR_PRIMARY)),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Sección VIP',
            style: TextStyle(fontSize: 25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cuando te suscribes, obtienes acceso a reportes, estadística, más características, '
            'Insignia VIP que garantiza tu oferta real.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDarkMode(context) ? Colors.white54 : Colors.black45),
          ),
        ),
        Stack(
          children: stack,
        )
      ],
    );
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(Set.from(_kProductIds));
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    //getting empty product list here
    print('products ${productDetailResponse.productDetails.length}');

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Intentando conectar...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'Esatamos ' + (_isAvailable ? 'Disponibles' : 'No disponibles') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('No conectado',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly?'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Obteniendo productos...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Productos a la venta'));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text('Es necesario un acceso especial a este menú.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verity the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? Icon(Icons.check)
                : FlatButton(
                    child: Text(productDetails.price),
                    color: Colors.green[800],
                    textColor: Colors.white,
                    onPressed: () {
                      PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          applicationUserName: null,
                          sandboxTesting: true);
                      if (productDetails.id == _kConsumableId) {
                        _connection.buyConsumable(
                            purchaseParam: purchaseParam,
                            autoConsume: kAutoConsume || Platform.isIOS);
                      } else {
                        _connection.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }
                    },
                  ));
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Encontrando productos...'))));
    }
    if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
      return Card();
    }
    final ListTile consumableHeader =
        ListTile(title: Text('Productos comprados'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      Divider(),
      GridView.count(
        crossAxisCount: 5,
        children: tokens,
        shrinkWrap: true,
        padding: EdgeInsets.all(16.0),
      )
    ]));
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID);
      List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }
}

Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) {
  // IMPORTANT!! Always verify a purchase before delivering the product.
  // For the purpose of an example, we directly return true.
  return Future<bool>.value(true);
}
