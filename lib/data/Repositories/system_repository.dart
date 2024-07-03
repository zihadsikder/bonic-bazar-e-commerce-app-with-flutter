import '../../utils/api.dart';

class SystemRepository {
  Future<Map> fetchSystemSettings({required bool isAnonymouse}) async {
    Map<String, dynamic> parameters = {};


    Map<String, dynamic> response = await Api.get(
        queryParameters: parameters,
        url: Api.getSystemSettingsApi,
       );

    return response;
  }
}
