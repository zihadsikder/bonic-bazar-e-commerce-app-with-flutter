// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:eClassify/Utils/payment/gatways/stripe_service.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../utils/Extensions/extensions.dart';

import '../../../utils/helper_utils.dart';

class PaymentGateways {
  static openEnabled(BuildContext context, dynamic price, dynamic package) {
    stripe(context, packageId: package, price: double.parse(price.toString()), paymentIntent: '');
  }

  static String generateReference(String email) {
    late String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else if (Platform.isAndroid) {
      platform = 'A';
    }
    String reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  static Future<void> stripe(BuildContext context,
      {required double price,
      required int packageId,
      required dynamic paymentIntent}) async {

   String paymentTransactionId = paymentIntent["payment_transaction_id"]
        .toString();
    String paymentIntentId =
    paymentIntent["id"].toString();
    String clientSecret = paymentIntent["client_secret"];


     await StripeService.payWithPaymentSheet(
      bcontext: context,
      merchantDisplayName: Constant.appName,
      amount: paymentIntent["amount"].toString(),
      currency: AppSettings.stripeCurrency,
      clientSecret:clientSecret,
      paymentIntentId: paymentIntentId,
    );

    /*StripeService.payWithPaymentSheet(

      paymentIntent: paymentIntent,
      context: context,
     *//* onError: (message) {},
      onSuccess: () {
        _purchase(context);
      },*//*
    );*/
  }

  static Future<void> _purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          context
              .read<FetchSystemSettingsCubit>()
              .fetchSettings(isAnonymouse: false);
          context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

          HelperUtils.showSnackBarMessage(context, "success".translate(context),
              type: MessageType.success, messageDuration: 5);

          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context, "purchaseFailed".translate(context),
          type: MessageType.error);
    }
  }
}

// class PaymentService {
//   BuildContext? _context;
//   SubscriptionPackageModel? _modal;
//   String? _targetGatwayKey;
//   Gatway? _currentGatway;
//   set targetGatwayKey(String key) {
//     _targetGatwayKey = key;
//   }

//   PaymentService setPackage(SubscriptionPackageModel modal) {
//     _modal = modal;
//     return this;
//   }

//   PaymentService setContext(BuildContext context) {
//     _context = context;
//     return this;
//   }

//   PaymentService attachedGatways(List<Gatway> paymentGatways) {
//     if (_targetGatwayKey == null) {
//       throw "Please set target gatway key";
//     }
//     for (Gatway gatway in paymentGatways) {
//       if (gatway.key == _targetGatwayKey) {
//         _currentGatway = gatway;
//       }
//     }
//     return this;
//   }

//   void pay() async {
//     if (_context == null) {
//       throw "Please call setContext before use this";
//     }
//     if (_modal == null) {
//       throw "Please call setPackage";
//     }
//     if (_currentGatway == null) {
//       throw "please attach gatways";
//     }
//     _currentGatway!.instance.setPackage(_modal!).pay(_context!);
//   }
// }
