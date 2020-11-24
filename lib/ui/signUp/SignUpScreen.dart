import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_listings/model/User.dart' as location;
import 'package:flutter_listings/model/User.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:flutter_listings/ui/container/ContainerScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:location/location.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../constants.dart';
import '../../main.dart';

File _image;

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  GlobalKey<FormState> _key = new GlobalKey();
  String firstName,
      lastName,
      email,
      mobile,
      password,
      confirmPassword,
      _phoneNumber,
      _verificationID;
  LocationData signUpLocation;
  bool _validate = false,
      signInWithPhoneNumber = false,
      _isPhoneValid = false,
      _codeSent = false;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: formUI(),
          ),
        ),
      ),
    );
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _imagePicker.getLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file.path);
      });
    }
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "Adiciona tu foto de perfil",
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
            setState(() {
              _image = File(image.path);
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Cámara"),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            PickedFile image =
                await _imagePicker.getImage(source: ImageSource.camera);
            setState(() {
              _image = File(image.path);
            });
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

  Widget formUI() {
    return new Column(
      children: <Widget>[
        new Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Crea una nueva',
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            )),
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
          child: Visibility(
            visible: !_codeSent,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade400,
                  child: ClipOval(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: _image == null
                          ? Image.asset(
                              'assets/images/placeholder.jpg',
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _image,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  left: 80,
                  right: 0,
                  child: FloatingActionButton(
                      backgroundColor: Color(COLOR_ACCENT),
                      child: Icon(
                        Icons.camera_alt,
                        color:
                            isDarkMode(context) ? Colors.black : Colors.white,
                      ),
                      mini: true,
                      onPressed: _onCameraClick),
                )
              ],
            ),
          ),
        ),
        Visibility(
          visible: !_codeSent,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                cursorColor: Color(COLOR_PRIMARY),
                textAlignVertical: TextAlignVertical.center,
                validator: validateName,
                controller: _firstNameController,
                onSaved: (String val) {
                  firstName = val;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  contentPadding:
                      new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Nombre',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200]),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_codeSent,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                validator: validateName,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Color(COLOR_PRIMARY),
                onSaved: (String val) {
                  lastName = val;
                },
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Apellido',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200]),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: signInWithPhoneNumber && !_codeSent,
          child: Padding(
            padding: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.grey[200])),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) =>
                _phoneNumber = number.phoneNumber,
                onInputValidated: (bool value) => _isPhoneValid = value,
                ignoreBlank: true,
                autoValidate: true,
                inputDecoration: InputDecoration(
                  hintText: 'Número de teléfono',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                inputBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                initialValue: PhoneNumber(isoCode: 'CO'),
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
            ),
          ),
        ),
        Visibility(
          visible: signInWithPhoneNumber && _codeSent,
          child: Padding(
            padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
            child: PinCodeTextField(
              appContext: context,
              onChanged: (_) {},
              onTap: () {},
              length: 6,
              textInputType: TextInputType.phone,
              backgroundColor: Colors.transparent,
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 40,
                  activeColor: Color(COLOR_PRIMARY),
                  activeFillColor: Colors.grey[100],
                  selectedFillColor: Colors.transparent,
                  selectedColor: Color(COLOR_PRIMARY),
                  inactiveColor: Colors.grey[600],
                  inactiveFillColor: Colors.transparent),
              enableActiveFill: true,
              onCompleted: (v) {
                _submitCode(v);
              },
            ),
          ),
        ),
        Visibility(
          visible: !signInWithPhoneNumber,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                cursorColor: Color(COLOR_PRIMARY),
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                validator: validateEmail,
                onSaved: (String val) {
                  email = val;
                },
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Correo electrónico',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200]),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !signInWithPhoneNumber,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                obscureText: true,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                controller: _passwordController,
                validator: validatePassword,
                onSaved: (String val) {
                  password = val;
                },
                style: TextStyle(fontSize: 18.0),
                cursorColor: Color(COLOR_PRIMARY),
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Clave',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200]),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !signInWithPhoneNumber,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _sendToServer();
                },
                obscureText: true,
                validator: (val) =>
                    validateConfirmPassword(_passwordController.text, val),
                onSaved: (String val) {
                  confirmPassword = val;
                },
                style: TextStyle(fontSize: 18.0),
                cursorColor: Color(COLOR_PRIMARY),
                decoration: InputDecoration(
                  contentPadding:
                  new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  fillColor: Colors.white,
                  hintText: 'Confirma la clave',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme
                        .of(context)
                        .errorColor),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200]),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !signInWithPhoneNumber || !_codeSent,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: RaisedButton(
                color: Color(COLOR_PRIMARY),
                child: Text(
                  signInWithPhoneNumber ? 'Envíame un código' : 'Regístrate',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                textColor: isDarkMode(context) ? Colors.black : Colors.white,
                splashColor: Color(COLOR_PRIMARY),
                onPressed: () => _signUp(),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'O',
              style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              signInWithPhoneNumber = !signInWithPhoneNumber;
            });
          },
          child: Text(
            signInWithPhoneNumber
                ? 'Inicia sesión con tu correo eletrónico'
                : 'Inicia sesión con tu teléfono',
            style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1),
          ),
        )
      ],
    );
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'Estamos creando tu cuenta, por favor espera...', false);
      var profilePicUrl = '';
      try {
        AuthResult result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim());
        if (_image != null) {
          updateProgress('Actualizando la imagen');
          profilePicUrl = await FireStoreUtils()
              .uploadUserImageToFireStorage(_image, result.user.uid);
        }
        User user = User(
            email: email.trim(),
            firstName: firstName,
            school: '',
            isVip: false,
            isAdmin: false,
            likedListingsIDs: [],
            lastOnlineTimestamp: Timestamp.now(),
            bio: '',
            age: '',
            phoneNumber: '',
            userID: result.user.uid,
            active: true,
            lastName: lastName,
            photos: [],
            showMe: true,
            location: location.Location(
                latitude: signUpLocation.latitude,
                longitude: signUpLocation.longitude),
            signUpLocation: location.Location(
                latitude: signUpLocation.latitude,
                longitude: signUpLocation.longitude),
            settings: Settings(
              pushNewMessages: true,
              pushNewMatchesEnabled: true,
              pushSuperLikesEnabled: true,
              pushTopPicksEnabled: true,
              genderPreference: 'Female',
              gender: 'Male',
              distanceRadius: '10',
              showMe: true,
            ),
            fcmToken: await FirebaseMessaging().getToken(),
            profilePictureURL: profilePicUrl);
        await FireStoreUtils.firestore
            .collection(USERS)
            .document(result.user.uid)
            .setData(user.toJson())
            .catchError((onError) {
          print(onError);
        });
        hideProgress();
        MyAppState.currentUser = user;
        pushAndRemoveUntil(context, ContainerScreen(user: user), false);
      } catch (error) {
        hideProgress();
        (error as PlatformException).code != 'ERROR_EMAIL_ALREADY_IN_USE'
            ? showAlertDialog(context, 'Error', 'Couldn\'t sign up')
            : showAlertDialog(context, 'Error',
                'Este correo electrónico ya existe, ingresa otro por favor.');
        print(error.toString());
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _image = null;
    super.dispose();
  }

  _signUp() async {
    signUpLocation = await getCurrentLocation();
    if (signUpLocation != null) {
      signInWithPhoneNumber
          ? _submitPhoneNumber(_phoneNumber)
          : _sendToServer();
    } else {
      _scaffoldState.currentState.showSnackBar(SnackBar(
        content: Text('Esto es necesario para registrarte.'),
        duration: Duration(seconds: 6),
      ));
    }
  }

  _submitPhoneNumber(String phoneNumber) {
    if (_isPhoneValid) {
      //send code
      setState(() {
        _codeSent = true;
      });
      FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(minutes: 2),
          verificationCompleted: (AuthCredential phoneAuthCredential) {},
          verificationFailed: (AuthException error) {
            print('${error.message}');
          },
          codeSent: (String verificationId, [int forceResendingToken]) {
            _verificationID = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _scaffoldState.currentState.showSnackBar(SnackBar(
                content: Text('Code '
                    'Por favor solicita otro código')));
            setState(() {
              _codeSent = false;
            });
          });
    }
  }

  void _submitCode(String code) async {
    showProgress(context, 'Saliendo...', false);
    try {
      AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: _verificationID, smsCode: code);
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((AuthResult authResult) async {
        User user = await FireStoreUtils().getCurrentUser(authResult.user.uid);
        if (user == null) {
          _createUserFromPhoneLogin(authResult.user.uid);
        } else {
          MyAppState.currentUser = user;
          hideProgress();
          pushAndRemoveUntil(context, ContainerScreen(user: user), false);
        }
      });
    } catch (exception) {
      hideProgress();
      String message = 'Ocurrio algo, intentalo nuevamente.';
      switch ((exception as PlatformException).code) {
        case 'ERROR_INVALID_CREDENTIAL':
          message = 'Código invalido o no existe';
          break;
        case 'ERROR_USER_DISABLED':
          message = 'Usuario deshabilitado';
          break;
        default:
          message = 'Ocurrio algo, intentalo nuevamente.';
          break;
      }
      _scaffoldState.currentState
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _createUserFromPhoneLogin(String userID) async {
    var profilePicUrl = '';
    if (_image != null) {
      updateProgress('Uploading image, Please wait...');
      profilePicUrl =
          await FireStoreUtils().uploadUserImageToFireStorage(_image, userID);
    }
    User user = User(
        firstName: _firstNameController.text ?? 'Anonymous',
        lastName: _lastNameController.text ?? 'User',
        email: '',
        profilePictureURL: profilePicUrl,
        active: true,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken(),
        photos: [],
        age: '',
        bio: '',
        isVip: false,
        isAdmin: false,
        likedListingsIDs: [],
        lastOnlineTimestamp: Timestamp.now(),
        phoneNumber: _phoneNumber,
        school: '',
        settings: Settings(
            distanceRadius: '',
            gender: 'Male',
            genderPreference: 'All',
            pushNewMatchesEnabled: true,
            pushNewMessages: true,
            pushSuperLikesEnabled: true,
            pushTopPicksEnabled: true,
            showMe: true),
        showMe: true,
        location: location.Location(
            latitude: signUpLocation.latitude,
            longitude: signUpLocation.longitude),
        signUpLocation: location.Location(
            latitude: signUpLocation.latitude,
            longitude: signUpLocation.longitude),
        userID: userID);
    await FireStoreUtils.firestore
        .collection(USERS)
        .document(userID)
        .setData(user.toJson())
        .then((onValue) {
      MyAppState.currentUser = null;
      MyAppState.currentUser = user;
      hideProgress();
      pushAndRemoveUntil(context, ContainerScreen(user: user), false);
    });
  }
}
