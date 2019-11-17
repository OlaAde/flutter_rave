import 'dart:async';

import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rave/charge_response.dart';
import 'package:flutter_rave/constants.dart';
import 'package:flutter_rave/mobile_money_payload.dart';
import 'package:flutter_rave/networking.dart';
import 'package:flutter_rave/requery_response.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _phoneController = TextEditingController();
  String _phoneErrorText;
  var firstName = 'user',
      lastName = 'Using',
      amount = 500,
      email = 'user@gmail.com',
      _userDismissedDialog = false,
      _requeryUrl,
      _queryCount = 0,
      _reQueryTxCount = 0,
      _waitDuration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          'Flutter Rave',
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: TextField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              decoration: InputDecoration(
                errorText: _phoneErrorText,
                hintText: 'Mobile Wallet Number',
                hintStyle: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey.shade500,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _processMtnMM,
            child: Container(
              child: Text(
                'PAY',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              margin: EdgeInsets.only(
                  left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
              padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processMtnMM() {
    _phoneErrorText = '';
    if (_validatePhoneNumber(_phoneController.text) != null) {
      setState(() {
        _phoneErrorText = _validatePhoneNumber(_phoneController.text);
      });
      return;
    }

    var phone = _addCountryCodeSuffixToNumber('+256', _phoneController.text);
    _showMobileMoneyProcessingDialog();
    _initiateMobileMoneyPaymentFlow(phone);
  }

  void _initiateMobileMoneyPaymentFlow(String phone) async {
    _userDismissedDialog = false;
    String deviceId = await DeviceId.getID;

    MobileMoneyPayload payload = MobileMoneyPayload(
        PBFPubKey: PUBLIC_KEY,
        currency: currency,
        payment_type: paymentType,
        country: receivingCountry,
        amount: '$amount',
        email: email,
        phonenumber: phone,
        network: network,
        firstname: firstName,
        lastname: lastName,
        txRef: "MC-" + DateTime.now().toString(),
        orderRef: "MC-" + DateTime.now().toString(),
        is_mobile_money_ug: '1',
        device_fingerprint: deviceId,
        redirect_url: WEB_HOOK_3DS);

    var requestBody = payload.encryptJsonPayload(ENCRYPTION_KEY, PUBLIC_KEY);

    var response = await postToEndpointWithBody(
        '$CHARGE_ENDPOINT?use_polling=1', requestBody);

    if (response == null) {
      _showToast(context, 'Payment processing failed. Please try again later.');
      _dismissMobileMoneyDialog(false);
    } else {
      _continueProcessingAfterCharge(response, true);
    }
  }

  _showToast(BuildContext context, String textInput, {Color backgroundColor}) {
    if (mounted) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(textInput),
        duration: Duration(milliseconds: 1000),
        backgroundColor: backgroundColor ?? Colors.black87,
      ));
    }
  }

  Future<void> _showMobileMoneyProcessingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mobile Money'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'A push notification is being sent to your phone, please complete the transaction by entering your pin.'),
                SizedBox(
                  height: 8.0,
                ),
                SpinKitThreeBounce(
                  color: Colors.grey.shade900,
                  size: 20.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                _dismissMobileMoneyDialog(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _dismissMobileMoneyDialog(bool dismissedByUser) {
    _userDismissedDialog = dismissedByUser;
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  String _validatePhoneNumber(String phone) {
    String pattern = r'(^[0+](?:[0-9] ?){6,14}[0-9]$)';
    RegExp regExp = RegExp(pattern);
    if (phone.length == 0) {
      return "Enter mobile number";
    } else if (!regExp.hasMatch(phone.trim())) {
      return "Enter valid mobile number";
    }
    return null;
  }

  String _addCountryCodeSuffixToNumber(String countryCode, String phoneNumber) {
    if (phoneNumber[0] == '0') {
      return countryCode + phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  void _continueProcessingAfterCharge(
      Map<String, dynamic> response, bool firstQuery) async {
    var chargeResponse = ChargeResponse.fromJson(response, firstQuery);

    if (chargeResponse.data != null && chargeResponse.data.flwRef != null) {
      _requeryTx(chargeResponse.data.flwRef);
    } else {
      if (chargeResponse.status == 'success' &&
          chargeResponse.data.ping_url != null) {
        _waitDuration = chargeResponse.data.wait;
        _requeryUrl = chargeResponse.data.ping_url;
        Timer(Duration(milliseconds: chargeResponse.data.wait), () {
          _chargeAgainAfterDuration(chargeResponse.data.ping_url);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'pending') {
        Timer(Duration(milliseconds: _waitDuration), () {
          _chargeAgainAfterDuration(_requeryUrl);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'completed' &&
          chargeResponse.data.flwRef != null) {
        _requeryTx(chargeResponse.data.flwRef);
      } else {
        _showToast(
            context, 'Payment processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      }
    }
  }

  void _requeryTx(String flwRef) async {
    if (!_userDismissedDialog && _reQueryTxCount < MAX_REQUERY_COUNT) {
      _reQueryTxCount++;
      final requeryRequestBody = {"PBFPubKey": PUBLIC_KEY, "flw_ref": flwRef};

      var response =
          await postToEndpointWithBody(REQUERY_ENDPOINT, requeryRequestBody);

      if (response == null) {
        _showToast(
            context, 'Payment processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      } else {
        var requeryResponse = RequeryResponse.fromJson(response);

        if (requeryResponse.data == null) {
          _showToast(
              context, 'Payment processing failed. Please try again later.');
          _dismissMobileMoneyDialog(false);
        } else if (requeryResponse.data.chargeResponseCode == '02' &&
            requeryResponse.data.status != 'failed') {
          _onPollingComplete(flwRef);
        } else if (requeryResponse.data.chargeResponseCode == '00') {
          _onPaymentSuccessful();
        } else {
          _showToast(
              context, 'Payment processing failed. Please try again later.');
          _dismissMobileMoneyDialog(false);
        }
      }
    } else if (_reQueryTxCount == MAX_REQUERY_COUNT) {
      _showToast(
          context, 'Payment processing timeout. Please try again later.');
      _dismissMobileMoneyDialog(false);
    }
  }

  void _chargeAgainAfterDuration(String url) async {
    if (!_userDismissedDialog) {
      _queryCount++;
      print('Charging Again after $_queryCount Charge calls');
      var response = await getResponseFromEndpoint(url);

      if (response == null) {
        _showToast(
            context, 'Payment processing failed. Please try again later.');
        _dismissMobileMoneyDialog(false);
      } else {
        _continueProcessingAfterCharge(response, false);
      }
    }
  }

  void _onPollingComplete(String flwRef) {
    Timer(Duration(milliseconds: 5000), () {
      _requeryTx(flwRef);
    });
  }

  void _onPaymentSuccessful() async {
    _showPaymentSuccessfulDialog();
  }

  void _showPaymentSuccessfulDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.done,
                  color: Colors.blue,
                  size: MediaQuery.of(context).size.width / 6,
                ),
              ),
              Text(
                'Payment completed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(
                height: 12.0,
              ),
              Text(
                'You have successfully completed your payment!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(
                height: 12.0,
              ),
              GestureDetector(
                onTap: () {
                  //Proceed to the next action after successful payment
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      left: 32.0, right: 32.0, top: 8.0, bottom: 16.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        });
  }
}
