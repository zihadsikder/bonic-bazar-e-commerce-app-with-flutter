import 'dart:developer';
import 'dart:io';

import '../../utils/api.dart';
import '../model/data_output.dart';
import '../model/subscription_pacakage_model.dart';

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPacakges() async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getPackageApi,
        queryParameters: {if (Platform.isIOS) "platform": "ios"});

    List<SubscriptionPackageModel> modelList = (response['data'] as List)
        .map((element) => SubscriptionPackageModel.fromJson(element))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<void> subscribeToPackage(
      int packageId, bool isPackageAvailable) async {
    try {
      Map<String, dynamic> parameters = {
        Api.packageId: packageId,
        if (isPackageAvailable) 'flag': 1,
      };
      // if (isPackageAvailable) {
      //   parameters['flag'] = 1;
      // }

      await Api.post(url: Api.userPurchasePackageApi, parameter: parameters);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
