// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eClassify/Ui/screens/chat/chat_screen.dart';
import 'package:eClassify/app/routes.dart';

import 'package:eClassify/data/cubits/chatCubits/delete_message_cubit.dart';
import 'package:eClassify/data/model/data_output.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/Repositories/Item/item_repository.dart';
import '../../data/cubits/chatCubits/load_chat_messages.dart';
import '../../data/model/item/item_model.dart';

import '../../exports/main_export.dart';
import '../helper_utils.dart';

class LocalAwsomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();

  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
      null,
      [
        NotificationChannel(
            channelKey: Constant.notificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            importance: NotificationImportance.High,
            ledColor: Colors.grey)
      ],
      channelGroups: [],
    );
    listenTap(context);
  }

  void listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  createNotification(
      {required RemoteMessage notificationData, required bool isLocked}) async {
    try {
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          title: notificationData.data["title"],
          // icon: AppIcons.aboutUs,
          hideLargeIconOnExpand: true,
          summary:
              notificationData.data["type"] == "chat" ? "New Message" : null,
          locked: isLocked,
          payload: Map.from(notificationData.data),
          autoDismissible: true,
          body: notificationData.data["body"],
          wakeUpScreen: true,
          notificationLayout: notificationData.data["type"] == "chat"
              ? NotificationLayout.Messaging
              : NotificationLayout.Default,
          groupKey: notificationData.data["id"],
          channelKey: Constant.notificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: Constant.notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload;

    if (payload?['type'] == "chat") {
      var username = payload?['user_name'];
      var itemImage = payload?['item_image'];
      var itemName = payload?['item_name'];
      var userProfile = payload?['user_profile'];
      var senderId = payload?['user_id'];
      var itemId = payload?['item_id'];
      var date = payload?['created_at'];
      var itemOfferId = payload?['item_offer_id'];
      var itemPrice= payload?['item_price'];
      var itemOfferPrice= payload?['item_offer_amount'];
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => LoadChatMessagesCubit(),
                  ),
                  BlocProvider(
                    create: (context) => DeleteMessageCubit(),
                  ),
                ],
                child: Builder(builder: (context) {
                  return ChatScreen(
                    profilePicture: userProfile??"",
                    userName: username ?? "",
                    itemImage: itemImage ?? "",
                    itemTitle: itemName ?? "",
                    userId: senderId ?? "",
                    itemId: itemId ?? "",
                    date: date ?? "",
                    itemOfferId: int.parse(itemOfferId!),
                    itemPrice: int.parse(itemPrice!),
                    itemOfferPrice:int.parse(itemOfferPrice!) ,
                  );
                }),
              );
            },
          ));
        },
      );
    } else {
      String id = receivedAction.payload?["id"] ?? "";

      DataOutput<ItemModel> item =
          await ItemRepository().fetchItemFromItemId(int.parse(id));

      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.goToNextPage(
              Routes.itemDetails, Constant.navigatorKey.currentContext!, false,
              args: {
                'itemData': item.modelList[0],
                'itemsList': item.modelList,
                'fromMyItem': false,
              });
        },
      );
    }
  }
}
