// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:eClassify/Utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());

      Map<String, dynamic> result = await Api.get(
        url: Api.getPaymentSettingsApi,
      );



      var data = result['data'];




      emit(GetApiKeysSuccess(
          stripeCurrency: data['Stripe']['currency_code'],
          stripePublishableKey: data['Stripe']['api_key'].toString(),
          stripeSecretKey: ''));
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  dynamic _getDataFromKey(List data, String key) {
    try {
      return data.where((element) => element['type'] == key).first['data'];
    } catch (e) {
      if (e.toString().contains("Bad state")) {
        throw "The key>>> $key is not comming from API";
      }
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
/*  final String razorPayKey;
  final String razorPaySecret;
  final String paystackPublicKey;
  final String paystackSecret;
  final String paystackCurrency;
  final String enabledPaymentGatway;*/
  final String stripeCurrency;
  final String stripePublishableKey;
  final String stripeSecretKey;

  GetApiKeysSuccess({
    /*  required this.razorPayKey,
    required this.razorPaySecret,
    required this.paystackPublicKey,
    required this.paystackSecret,
    required this.paystackCurrency,
    required this.enabledPaymentGatway,*/
    required this.stripeCurrency,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
  });

  @override
  String toString() {
    // return 'GetApiKeysSuccess(razorPayKey: $razorPayKey, razorPaySecret: $razorPaySecret, paystackPublicKey: $paystackPublicKey, paystackSecret: $paystackSecret, paystackCurrency: $paystackCurrency, enabledPaymentGatway: $enabledPaymentGatway, stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey)';
    return 'GetApiKeysSuccess(stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey)';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;

  GetApiKeysFail(this.error);
}
