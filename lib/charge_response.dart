class ChargeResponse {
  String status;
  String message;
  Data data;

  ChargeResponse.fromJson(Map<String, dynamic> json, bool isFirstQuery) {
    if (json == null) {
      return;
    }
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  @override
  String toString() {
    return 'status: $status, message: $message, date: $data';
  }
}

class Data {
  String suggested_auth;
  String chargeResponseCode;
  String authModelUsed;
  String flwRef;
  String txRef;
  String chargeResponseMessage;
  String authurl;
  String appFee;
  String currency;
  String charged_amount;
  String validateInstruction;
  String redirectUrl;
  String validateInstructions;
  String amount;
  String status;

  //For timeout
  String ping_url;
  int wait;

  Data.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    if (json['response'] != null) {
      json = json['response'].cast<Map<String, dynamic>>();
    }
    txRef = json['txRef'];
    flwRef = json['flwRef'];
    redirectUrl = json['redirectUrl'];
    amount = json['amount'].toString();
    charged_amount = json['charged_amount'].toString();
    appFee = json['appfee'].toString();
    chargeResponseCode = json['chargeResponseCode'];
    chargeResponseMessage = json['chargeResponseMessage'];
    authModelUsed = json['authModelUsed'];
    currency = json['currency'];
    suggested_auth = json['suggested_auth'];
    validateInstruction = json['validateInstruction'];
    validateInstructions = json['validateInstructions'];
    ping_url = json['ping_url'];
    wait = json['wait'];
    status = json['status'];
    authurl = json['authurl'];
  }

  @override
  String toString() {
    return 'Data{suggested_auth: $suggested_auth, chargeResponseCode: $chargeResponseCode, authModelUsed: $authModelUsed, flwRef: $flwRef, txRef: $txRef, chargeResponseMessage: $chargeResponseMessage, authurl: $authurl, appFee: $appFee, currency: $currency, charged_amount: $charged_amount, validateInstruction: $validateInstruction, redirectUrl: $redirectUrl, validateInstructions: $validateInstructions, amount: $amount, status: $status, ping_url: $ping_url, wait: $wait}';
  }

}
