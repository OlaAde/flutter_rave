class RequeryResponse {
  String status;
  Data data;

  RequeryResponse.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    status = json['status'];
    data = Data.fromJson(json['data']);
  }

  @override
  String toString() {
    return 'status:$status, data:$data';
  }
}

class Data {
  String chargeResponseCode;
  String status;
  String flwRef;
  int amount;
  String currency;

  Data.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }
    status = json['status'];
    chargeResponseCode = json['chargeResponseCode'];
    flwRef = json['flwref'];
    amount = json['amount'];
    currency = json['currency'];

    if (chargeResponseCode == null) {
      chargeResponseCode = json['chargecode'];
    }
  }

  @override
  String toString() {
    return 'Data{chargeResponseCode: $chargeResponseCode, status: $status, flwRef: $flwRef, amount: $amount, currency: $currency}';
  }
}
