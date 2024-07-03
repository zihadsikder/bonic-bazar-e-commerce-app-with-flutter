import 'package:eClassify/Utils/logger.dart';
import 'package:flutter/material.dart';

import '../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';
import '../../utils/api.dart';
import '../../utils/hive_utils.dart';
import '../model/chat/chated_user_model.dart';
import '../model/data_output.dart';

class ChatRepostiory {
  BuildContext? _setContext;

  void setContext(BuildContext context) {
    _setContext = context;
  }

  Future<DataOutput<ChatedUser>> fetchBuyerChatList(int page) async {
    /* Map<String, dynamic> response = await Api.get(
        url: Api.getChatListApi, queryParameters: {*/ /*"page": page, */ /*"type": "buyer"});*/

    Map<String, dynamic> response = await Api.get(
        url: Api.getChatListApi,
        queryParameters: {"type": "buyer", "page": page});

    List<ChatedUser> modelList = (response['data']['data'] as List).map(
      (e) {
        return ChatedUser.fromJson(e);
      },
    ).toList();

    return DataOutput(total: response['data']['total'], modelList: modelList);
  }

  Future<DataOutput<ChatedUser>> fetchSellerChatList(int page) async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getChatListApi,
        queryParameters: {"page": page, "type": "seller"});

    List<ChatedUser> modelList = (response['data']["data"] as List).map(
      (e) {
        return ChatedUser.fromJson(e /*, context: _setContext*/);
      },
    ).toList();

    return DataOutput(
        total: response['data']['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<ChatMessage>> getMessagesApi(
      {required int page, required int itemOfferId}) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.chatMessagesApi,
      queryParameters: {
        "item_offer_id": itemOfferId,
        "page": page,
      },
    );

    List<ChatMessage> modelList = (response['data']['data'] as List).map(
      (result) {
        int senderId = result['sender_id'];
        String message = result['message'];
        String file = result['file'];
        String audio = result['audio'];
        String createdAt = result['created_at'];
        int id = result['id'];

        return ChatMessage(
          key: ValueKey(id),
          message: message,
          senderId: senderId,
          createdAt: createdAt,
          file: file,
          audio: audio,
          itemOfferId: id,
          updatedAt: createdAt,
        );
      },
    ).toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<Map<String, dynamic>> sendMessageApi(
      {required int itemOfferId,
      required String message,
      dynamic audio,
      dynamic attachment}) async {
    Map<String, dynamic> parameters = {
      "message": message,
      "item_offer_id": itemOfferId,
      "file": attachment,
      "audio": audio
    };

    if (attachment == null) {
      parameters.remove("file");
    }
    if (audio == null) {
      parameters.remove("audio");
    }


    Logger.error(parameters, name: "CHAT PARAMS");
    Map<String, dynamic> map =
        await Api.post(url: Api.sendMessageApi, parameter: parameters);

    return map;
  }
}
