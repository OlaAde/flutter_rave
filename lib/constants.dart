const String CHARGE_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/charge";
const String VALIDATE_CHARGE_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/validatecharge";
const String REQUERY_ENDPOINT =
    "https://api.ravepay.co/flwv3-pug/getpaidx/api/verify/mpesa";

const String PUBLIC_KEY = 'FLWPUBK-******'; //Change to your Rave Public Key
const String ENCRYPTION_KEY = '********'; //Change to your Rave Encryption Key

const currency = 'UGX';
const paymentType = 'mobilemoneyuganda';
const receivingCountry = 'NG';
const network = 'UGX';
const WEB_HOOK_3DS = 'https://rave-webhook.herokuapp.com/receivepayment';
const MAX_REQUERY_COUNT = 30;
