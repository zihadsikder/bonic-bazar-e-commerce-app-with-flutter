import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/data/cubits/chatCubits/delete_message_cubit.dart';
import 'package:eClassify/Utils/customHeroAnimation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/routes.dart';
import '../../../data/Repositories/Item/item_repository.dart';
import '../../../data/cubits/chatCubits/load_chat_messages.dart';
import '../../../data/cubits/chatCubits/send_message.dart';
import '../../../data/helper/widgets.dart';
import '../../../data/model/data_output.dart';

import '../../../data/model/item/item_model.dart';
import '../../../exports/main_export.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Notification/chat_message_handler.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/transparant_route.dart';
import 'chatAudio/widgets/chat_widget.dart';
import 'chatAudio/widgets/record_button.dart';

int totalMessageCount = 0;

ValueNotifier<bool> showDeletebutton = ValueNotifier<bool>(false);

ValueNotifier<int> selectedMessageid = ValueNotifier<int>(-5);

class ChatScreen extends StatefulWidget {
  final String? from;
  final int itemOfferId;
  final int itemOfferPrice;
  final int itemPrice;
  final String profilePicture;
  final String userName;
  final String itemImage;
  final String itemTitle;
  final String userId; //for which we are messageing
  final String itemId;
  final String date;

  const ChatScreen(
      {super.key,
      required this.profilePicture,
      required this.userName,
      required this.itemImage,
      required this.itemTitle,
      required this.userId,
      required this.itemId,
      required this.date,
      this.from,
      required this.itemOfferId,
      required this.itemPrice,
      required this.itemOfferPrice});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _recordButtonAnimation = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
  );
  TextEditingController controller = TextEditingController();
  PlatformFile? messageAttachment;
  bool isFetchedFirstTime = false;
  double scrollPositionWhenLoadMore = 0;
  late Stream<PermissionStatus> notificationStream = notificationPermission();
  late StreamSubscription notificationStreamSubsctription;
  bool isNotificationPermissionGranted = true;
  bool showRecordButton = true;
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(
      () {
        if (_pageScrollController.offset >=
            _pageScrollController.position.maxScrollExtent) {
          if (context.read<LoadChatMessagesCubit>().hasMoreChat()) {
            setState(() {});
            context.read<LoadChatMessagesCubit>().loadMore();
          }
        }
      },
    );

  @override
  void initState() {
    context.read<LoadChatMessagesCubit>().load(
          itemOfferId: widget.itemOfferId,
        );

    //currentlyChatItemId = widget.itemId;
    //currentlyChatingWith = widget.userId;
    notificationStreamSubsctription =
        notificationStream.listen((PermissionStatus permissionStatus) {
      isNotificationPermissionGranted = permissionStatus.isGranted;
      if (mounted) {
        setState(() {});
      }
    });
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        showRecordButton = false;
      } else {
        showRecordButton = true;
      }
      setState(() {});
    });
    super.initState();
  }

  Stream<PermissionStatus> notificationPermission() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield* Permission.notification.request().asStream();
    }
  }

  @override
  void dispose() {
    notificationStreamSubsctription.cancel();
    super.dispose();
  }

  List<String> supportedImageTypes = [
    'jpeg',
    'jpg',
    'png',
    'gif',
    'webp',
    'animated_webp',
  ];

  @override
  Widget build(BuildContext context) {
    var chatBackground = "assets/chat_background/light.svg";
    var attachmentMIME = "";
    if (messageAttachment != null) {
      attachmentMIME =
          (messageAttachment?.path?.split(".").last.toLowerCase()) ?? "";
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        //currentlyChatingWith = "";
        showDeletebutton.value = false;

        //currentlyChatItemId = "";
        notificationStreamSubsctription.cancel();
        ChatMessageHandler.flushMessages();
        return;
      },
      /*  onWillPop: () async {
        currentlyChatingWith = "";
        showDeletebutton.value = false;

        currentlyChatItemId = "";
        notificationStreamSubsctription.cancel();
        ChatMessageHandler.flushMessages();
        return true;
      },*/
      child: SafeArea(
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (messageAttachment != null) ...[
                    if (supportedImageTypes.contains(attachmentMIME)) ...[
                      Container(
                        decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            border: Border.all(
                                color: context.color.borderColor, width: 1.5)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      UiUtils.showFullScreenImage(context,
                                          provider: FileImage(File(
                                            messageAttachment?.path ?? "",
                                          )));
                                    },
                                    child: Image.file(
                                      File(
                                        messageAttachment?.path ?? "",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(messageAttachment?.name ?? ""),
                                Text(HelperUtils.getFileSizeString(
                                  bytes: messageAttachment!.size,
                                ).toString()),
                              ],
                            )
                          ],
                        ),
                      )
                    ] else ...[
                      Container(
                        color: context.color.secondaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child:
                              AttachmentMessage(url: messageAttachment!.path!),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  BottomAppBar(
                    padding: const EdgeInsetsDirectional.all(10),
                    elevation: 5,
                    color: context.color.secondaryColor,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          // IconButton(
                          //     onPressed: () async {
                          //       if (messageAttachment == null) {
                          //         FilePickerResult? pickedAttachment =
                          //             await FilePicker.platform.pickFiles(
                          //           allowMultiple: false,
                          //         );

                          //         messageAttachment =
                          //             pickedAttachment?.files.first;
                          //         setState(() {});
                          //       } else {
                          //         messageAttachment = null;
                          //         setState(() {});
                          //       }
                          //     },
                          //     icon: messageAttachment != null
                          //         ? const Icon(Icons.close)
                          //         : const RotatedBox(
                          //             quarterTurns: 3,
                          //             child: Icon(Icons.attachment))),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              cursorColor: context.color.territoryColor,
                              onTap: () {
                                showDeletebutton.value = false;
                              },
                              textInputAction: TextInputAction.newline,
                              minLines: 1,
                              maxLines: null,
                              decoration: InputDecoration(
                                suffixIconColor: context.color.textLightColor,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (messageAttachment == null) {
                                      FilePickerResult? pickedAttachment =
                                          await FilePicker.platform.pickFiles(
                                        allowMultiple: false,
                                      );

                                      messageAttachment =
                                          pickedAttachment?.files.first;
                                      showRecordButton = false;
                                      setState(() {});
                                    } else {
                                      messageAttachment = null;
                                      showRecordButton = true;
                                      setState(() {});
                                    }
                                  },
                                  icon: messageAttachment != null
                                      ? const Icon(Icons.close)
                                      : Transform.rotate(
                                          angle: -3.14 / 5.0,
                                          child: const Icon(
                                            Icons.attachment,
                                          ),
                                        ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: context.color.territoryColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                        color: context.color.territoryColor)),
                                hintText: "writeHere".translate(context),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 9.5,
                          ),

                          if (showRecordButton)
                            RecordButton(
                              controller: _recordButtonAnimation,
                              callback: (path) {
                                if (Constant.isDemoModeOn) {
                                  HelperUtils.showSnackBarMessage(
                                      context,
                                      "thisActionNotValidDemo"
                                          .translate(context));
                                  return;
                                }

                                //This is adding Chat widget in stream with BlocProvider , because we will need to do api process to store chat message to server, when it will be added to list it's initState method will be called
                                ChatMessageHandler.add(
                                  BlocProvider(
                                    create: (context) => SendMessageCubit(),
                                    child: ChatMessage(
                                        key: ValueKey(DateTime.now()
                                            .toString()
                                            .toString()),
                                        message: controller.text,
                                        senderId:
                                            int.parse(HiveUtils.getUserId()!),
                                        createdAt: DateTime.now().toString(),
                                        isSentNow: true,
                                        audio: path,
                                        itemOfferId: widget.itemOfferId,
                                        file: "",
                                        updatedAt: DateTime.now().toString()),
                                  ),
                                );
                                totalMessageCount++;

                                setState(() {});
                              },
                              isSending: false,
                            ),
                          if (!showRecordButton)
                            GestureDetector(
                              onTap: () {
                                if (Constant.isDemoModeOn) {
                                  HelperUtils.showSnackBarMessage(
                                      context,
                                      "thisActionNotValidDemo"
                                          .translate(context));
                                  return;
                                }
                                showDeletebutton.value = false;

                                //if file is selected then user can send message without text
                                if (controller.text.trim().isEmpty &&
                                    messageAttachment == null) return;
                                //This is adding Chat widget in stream with BlocProvider , because we will need to do api process to store chat message to server, when it will be added to list it's initState method will be called

                                ChatMessageHandler.add(
                                  BlocProvider(
                                    key: ValueKey(
                                        DateTime.now().toString().toString()),
                                    create: (context) => SendMessageCubit(),
                                    child: ChatMessage(
                                      key: ValueKey(
                                          DateTime.now().toString().toString()),
                                      message: controller.text,
                                      senderId:
                                          int.parse(HiveUtils.getUserId()!),
                                      createdAt: DateTime.now().toString(),
                                      isSentNow: true,
                                      updatedAt: DateTime.now().toString(),
                                      audio: "",
                                      file: messageAttachment != null
                                          ? messageAttachment?.path
                                          : "",
                                      itemOfferId: widget.itemOfferId,
                                    ),
                                  ),
                                );
                                totalMessageCount++;
                                controller.text = "";
                                messageAttachment = null;
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: context.color.territoryColor,
                                child: Icon(
                                  Icons.send,
                                  color: context.color.buttonColor,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              type: MaterialType.circle,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: UiUtils.getSvg(AppIcons.arrowLeft,
                      fit: BoxFit.none, color: context.color.textDefaultColor),
                ),
              ),
            ),
            backgroundColor: context.color.secondaryColor,
            elevation: 0,
            iconTheme: IconThemeData(color: context.color.territoryColor),
            bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(isNotificationPermissionGranted ? 63 : 98),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Divider(
                    color: context.color.borderColor.darken(40),
                    thickness: 1,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    color: context.color.secondaryColor,
                    height: 63,
                    child: Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.none,
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                Widgets.showLoader(context);

                                DataOutput<ItemModel> dataOutput =
                                    await ItemRepository().fetchItemFromItemId(
                                        int.parse(widget.itemId));

                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Widgets.hideLoder(context);
                                    Navigator.pushNamed(
                                        context, Routes.adDetailsScreen,
                                        arguments: {
                                          "model": dataOutput.modelList[0],
                                        });
                                  },
                                );
                              } catch (e) {
                                Widgets.hideLoder(context);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: SizedBox(
                                width: 47,
                                height: 47,
                                child: UiUtils.getImage(
                                  widget.itemImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            width: 10), // Adding horizontal space between items
                        Expanded(
                          child: Container(
                            color: context.color.secondaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.itemTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  )
                                      .color(context.color.textDefaultColor)
                                      .size(context.font.large),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 15.0),
                                  child: Text(
                                    Constant.currencySymbol.toString() +
                                        widget.itemPrice
                                            .toString(), // Replace with your item price
                                  )
                                      .color(context.color.textDefaultColor)
                                      .size(context.font.large)
                                      .bold(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isNotificationPermissionGranted
                      ? SizedBox.shrink()
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: Container(
                            width: context.screenWidth,
                            color: const Color.fromARGB(255, 151, 151, 151),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text("turnOnNotification".translate(context)),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            actions: [
              ValueListenableBuilder(
                valueListenable: showDeletebutton,
                builder: (context, value, child) {
                  if (value == false) return const SizedBox.shrink();
                  return IconButton(
                      onPressed: () {
                        UiUtils.showBlurredDialoge(context,
                            dialoge: BlurredDialogBox(
                                onAccept: () async {
                                  if (Constant.isDemoModeOn) {
                                    HelperUtils.showSnackBarMessage(
                                        context,
                                        "thisActionNotValidDemo"
                                            .translate(context));
                                    return;
                                  }
                                  context
                                      .read<DeleteMessageCubit>()
                                      .delete((selectedMessageid.value));
                                  showDeletebutton.value = false;
                                },
                                title: "areYouSure".translate(context),
                                content: Text(
                                    "msgWillNotRecover".translate(context))));
                      },
                      icon: SvgPicture.asset(
                        AppIcons.delete,
                        colorFilter: ColorFilter.mode(
                            context.color.territoryColor, BlendMode.srcIn),
                      ));
                },
              ),
            ],
            title: FittedBox(
              fit: BoxFit.none,
              child: Row(
                children: [
                  widget.profilePicture == ""
                      ? CircleAvatar(
                          backgroundColor: context.color.territoryColor,
                          child: SvgPicture.asset(
                            AppIcons.profile,
                            colorFilter: ColorFilter.mode(
                                context.color.buttonColor, BlendMode.srcIn),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              TransparantRoute(
                                barrierDismiss: true,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      color: const Color.fromARGB(69, 0, 0, 0),

                                      // child: Hero(
                                      //   tag: "RR",
                                      //   transitionOnUserGestures: true,
                                      //   flightShuttleBuilder: (flightContext,
                                      //       animation,
                                      //       flightDirection,
                                      //       fromHeroContext,
                                      //       toHeroContext) {
                                      //     return CircleAvatar(
                                      //       backgroundImage:
                                      //           CachedNetworkImageProvider(
                                      //         widget.profilePicture,
                                      //       ),
                                      //     );
                                      //   },
                                      //   child: CircleAvatar(
                                      //     backgroundImage:
                                      //         CachedNetworkImageProvider(
                                      //       widget.profilePicture,
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: CustomImageHeroAnimation(
                            type: CImageType.Network,
                            image: widget.profilePicture,
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                widget.profilePicture,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: context.screenWidth * 0.35,
                    child: Text(widget.userName)
                        .color(context.color.textColorDark)
                        .size(context.font.normal),
                  )
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              SvgPicture.asset(
                chatBackground,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              BlocListener<DeleteMessageCubit, DeleteMessageState>(
                listener: (context, state) {
                  if (state is DeleteMessageSuccess) {
                    ChatMessageHandler.removeMessage(state.id);
                    showDeletebutton.value = false;
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    showDeletebutton.value = false;
                  },
                  child: BlocConsumer<LoadChatMessagesCubit,
                      LoadChatMessagesState>(
                    listener: (context, state) {
                      if (state is LoadChatMessagesSuccess) {
                        ChatMessageHandler.loadMessages(
                            state.messages, context);
                        totalMessageCount = state.messages.length;
                        isFetchedFirstTime = true;
                        setState(() {});
                      }
                    },
                    builder: (context, state) {
                      return Stack(
                        children: [
                          StreamBuilder(
                              stream: ChatMessageHandler.getChatStream(),
                              builder: (context, AsyncSnapshot snapshot) {
                                Widget? loadingMoreWidget;
                                if (state is LoadChatMessagesSuccess) {
                                  if (state.isLoadingMore) {
                                    loadingMoreWidget =
                                        Text("loading".translate(context));
                                  }
                                }

                                if (snapshot.connectionState ==
                                        ConnectionState.active ||
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  if ((snapshot.data as List).isEmpty) {
                                    return offerWidget();
                                  }

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      loadingMoreWidget ??
                                          const SizedBox.shrink(),
                                      Expanded(
                                        child: ListView.builder(
                                          reverse: true,
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          controller: _pageScrollController,
                                          addAutomaticKeepAlives: true,
                                          itemCount: snapshot.data.length,
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          itemBuilder: (context, index) {
                                            // final adjustedIndex =   index - 1;
                                            dynamic chat =
                                                (snapshot.data as List)
                                                    .elementAt(index);

                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (index ==
                                                    ((snapshot.data as List)
                                                            .length -
                                                        1))
                                                  offerWidget(),
                                                chat
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return offerWidget();
                              }),
                          if ((state is LoadChatMessagesInProgress))
                            Center(
                              child: UiUtils.progress(),
                            )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  offerWidget() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
          height: 71,
          margin: EdgeInsets.only(top: 15, bottom: 15, right: 15),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(
                  color: context.color.territoryColor.withOpacity(0.3)),
              color: context.color.territoryColor.withOpacity(0.17),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(0),
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("yourOffer".translate(context))
                  .color(context.color.textDefaultColor.withOpacity(0.5)),
              Text(widget.itemPrice.toString())
                  .bold()
                  .size(context.font.larger)
                  .color(context.color.textDefaultColor)
            ],
          )),
    );
  }
}
