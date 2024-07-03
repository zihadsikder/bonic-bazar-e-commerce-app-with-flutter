import '../../utils/api.dart';
import '../model/data_output.dart';
import '../model/enquiry_status.dart';

class EnquiryRepository {
  Future<DataOutput<EnquiryStatus>> fetchMyEnquiry(
      {required int page}) async {
    try {
      Map<String, dynamic> parameters = {
        Api.page: page
      };
      Map<String, dynamic> response = await Api.get(
          url: Api.getItemApiEnquiry, queryParameters: parameters);

      List<EnquiryStatus> modelList = (response['data'] as List)
          .map((e) => EnquiryStatus.fromJson(e))
          .toList();
      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEnquiry(String itemId) async {
    Map<String, dynamic> parameters = {
      Api.actionType: "0",
      Api.itemId: itemId,
    };

    await Api.post(url: Api.setItemEnquiryApi, parameter: parameters);
  }

  Future<void> deleteEnquiry(int id) async {
    await Api.post(url: Api.deleteInquiryApi, parameter: {Api.id: id});
  }
}
