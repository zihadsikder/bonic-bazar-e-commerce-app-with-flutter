// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:eClassify/Ui/screens/Home/home_screen.dart';
import 'package:eClassify/Ui/screens/Item/makeAnOfferItemScreen.dart';
import 'package:eClassify/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:eClassify/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/data/cubits/chatCubits/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chatCubits/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favoriteCubit.dart';
import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/model/chat/chated_user_model.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:eClassify/utils/AppIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Utils/api.dart';
import '../../Utils/cloudState/cloud_state.dart';
import '../../Utils/helper_utils.dart';
import '../../Utils/ui_utils.dart';
import '../../data/cubits/Report/item_report_cubit.dart';
import '../../data/cubits/chatCubits/delete_message_cubit.dart';
import '../../data/cubits/chatCubits/load_chat_messages.dart';
import '../../data/cubits/chatCubits/send_message.dart';
import '../../data/cubits/favorite/manageFavCubit.dart';
import '../../data/cubits/item/change_my_items_status_cubit.dart';
import '../../data/cubits/item/delete_item_cubit.dart';
import '../../data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'AdBannderScreen.dart';
import 'Chat/chat_screen.dart';
import 'Home/Widgets/grid_list_adapter.dart';
import 'Home/Widgets/home_sections_adapter.dart';
import 'Item/add_item_screen/Widgets/PdfViewer.dart';
import 'Report/report_item_screen.dart';
import 'Widgets/Errors/no_internet.dart';
import 'Widgets/Errors/something_went_wrong.dart';
import 'Widgets/shimmerLoadingContainer.dart';
import 'google_map_screen.dart';

class AdDetailsScreen extends StatefulWidget {
  final ItemModel model;

  //final String from;

  const AdDetailsScreen({
    super.key,
    required this.model,
    /*required this.from*/
  });

  @override
  AdDetailsScreenState createState() => AdDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FetchMyItemsCubit(),
                ),
              ],
              child: AdDetailsScreen(
                model: arguments?['model'],
                // from: arguments?['from'],
              ),
            ));
  }
}

class AdDetailsScreenState extends CloudState<AdDetailsScreen> {
  //ImageView
  int currentPage = 0;
  bool? isFeaturedLimit;
  List<String> selectedFeaturedAdsOptions = [];

  bool isShowReportAds = true;
  final PageController pageController = PageController();
  final List<String?> images = [];
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late final ScrollController _pageScrollController = ScrollController();

  /* [
    "http://eclassify.thewrteam.in/storage/packages/M5t66y5DRVVOrxH7xjDoOg3PJnxavUqjZI1ILlHn.jpg",
    "http://eclassify.thewrteam.in/storage/custom_field/655c7b73c8952.jpg",
    "http://eclassify.thewrteam.in/storage/packages/M5t66y5DRVVOrxH7xjDoOg3PJnxavUqjZI1ILlHn.jpg",

  ]; */
  //ImageView

/*  late final String from =
      widget.from;*/ //"MyAds";//TODO: set it as an argument with Route

  late final ItemModel model = widget.model;

  late bool isAddedByMe = (widget.model.user?.id != null
          ? widget.model.user?.id.toString()
          : widget.model.userId) ==
      HiveUtils.getUserId();

  bool isFeaturedWidget = true;

  int? categoryId;

  @override
  void initState() {
    super.initState();

    if (!isAddedByMe) {
      context.read<FetchItemReportReasonsListCubit>().fetch();
    }
    categoryId = widget.model.category != null
        ? widget.model.category?.id
        : widget.model.categoryId;

    setItemClick();
    //ImageView
    combineImages();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    context.read<FetchRelatedItemsCubit>().fetchRelatedItems(categoryId!);
    _pageScrollController.addListener(_pageScroll);
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchRelatedItemsCubit>().hasMoreData()) {
        context
            .read<FetchRelatedItemsCubit>()
            .fetchRelatedItemsMore(categoryId!);
      }
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      model.latitude ?? 0,
      model.longitude ?? 0,
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    super.dispose();
  }

  void combineImages() {
    images.add(model.image);
    if (model.galleryImages != null && model.galleryImages!.isNotEmpty) {
      for (var element in model.galleryImages!) {
        images.add(element.image);
      }
    }
  }

  void setItemClick() {
    if (!isAddedByMe) {
      context.read<ItemTotalClickCubit>().itemTotalClick(model.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.secondaryDetailsColor,
        ),
        child: Scaffold(
          appBar: UiUtils.buildAppBar(
            context,
            backgroundColor: context.color.secondaryDetailsColor,
            showBackButton: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: isAddedByMe &&
                            (model.status != "sold out" &&
                                model.status != "review")
                        ? 30.0
                        : 15),
                child: IconButton(
                  onPressed: () {
                    HelperUtils.share(context, model.id!);
                  },
                  icon: Icon(
                    Icons.share,
                    size: 24,
                    color: context.color.textDefaultColor,
                  ),
                ),
              ),
              if (isAddedByMe &&
                  (model.status != "sold out" && model.status != "review"))
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => DeleteItemCubit(),
                    ),
                    BlocProvider(
                      create: (context) => ChangeMyItemStatusCubit(),
                    ),
                  ],
                  child: Builder(builder: (context) {
                    return BlocListener<DeleteItemCubit, DeleteItemState>(
                      listener: (context, deleteState) {
                        if (deleteState is DeleteItemSuccess) {
                          HelperUtils.showSnackBarMessage(context,
                              "deleteItemSuccessMsg".translate(context));
                          context.read<FetchMyItemsCubit>().deleteItem(model);
                          Navigator.pop(context, "refresh");
                        } else if (deleteState is DeleteItemFailure) {
                          HelperUtils.showSnackBarMessage(
                              context, deleteState.errorMessage);
                        }
                      },
                      child: BlocListener<ChangeMyItemStatusCubit,
                          ChangeMyItemStatusState>(
                        listener: (context, changeState) {
                          if (changeState is ChangeMyItemStatusSuccess) {
                            HelperUtils.showSnackBarMessage(
                                context, changeState.message);
                            Navigator.pop(context, "refresh");
                          } else if (changeState is ChangeMyItemStatusFailure) {
                            HelperUtils.showSnackBarMessage(
                                context, changeState.errorMessage);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Container(
                            height: 24,
                            width: 24,
                            alignment: Alignment.center,
                            child: PopupMenuButton(
                              color: context.color.territoryColor,
                              offset: Offset(-12, 15),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(17),
                                  bottomRight: Radius.circular(17),
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.more,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                    context.color.textDefaultColor,
                                    BlendMode.srcIn),
                              ),
                              itemBuilder: (context) => [
                                if (model.status == "active" ||
                                    model.status == "approved")
                                  if (!model.isFeature!)
                                    PopupMenuItem(
                                      onTap: () {
                                        Future.delayed(Duration.zero, () {
                                          if (Constant.isDemoModeOn) {
                                            HelperUtils.showSnackBarMessage(
                                                context,
                                                UiUtils.getTranslatedLabel(
                                                    context,
                                                    "thisActionNotValidDemo"));
                                            return;
                                          }
                                            context
                                                .read<ChangeMyItemStatusCubit>()
                                                .changeMyItemStatus(
                                                    id: model.id!,
                                                    status: 'featured');

                                        });
                                      },
                                      child:
                                          Text("featureAd".translate(context))
                                              .color(context.color.buttonColor),
                                    ),
                                if (model.status == "active" ||
                                    model.status == "approved")
                                  PopupMenuItem(
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        if (Constant.isDemoModeOn) {
                                          HelperUtils.showSnackBarMessage(
                                              context,
                                              UiUtils.getTranslatedLabel(
                                                  context,
                                                  "thisActionNotValidDemo"));
                                          return;
                                        }
                                          context
                                              .read<ChangeMyItemStatusCubit>()
                                              .changeMyItemStatus(
                                                  id: model.id!,
                                                  status: 'inactive');

                                      });
                                    },
                                    child: Text("deactivate".translate(context))
                                        .color(context.color.buttonColor),
                                  ),
                                if (model.status == "active" ||
                                    model.status == "inactive" ||
                                    model.status == "approved")
                                  PopupMenuItem(
                                    child: Text("lblremove".translate(context))
                                        .color(context.color.buttonColor),
                                    onTap: () async {
                                      var delete =
                                          await UiUtils.showBlurredDialoge(
                                        context,
                                        dialoge: BlurredDialogBox(
                                          title:
                                              "deleteBtnLbl".translate(context),
                                          content: Text(
                                            "deleteitemwarning"
                                                .translate(context),
                                          ),
                                        ),
                                      );
                                      if (delete == true) {
                                        Future.delayed(
                                          Duration.zero,
                                          () {
                                            if (Constant.isDemoModeOn) {
                                              HelperUtils.showSnackBarMessage(
                                                  context,
                                                  UiUtils.getTranslatedLabel(
                                                      context,
                                                      "thisActionNotValidDemo"));
                                              return;
                                            }
                                              context
                                                  .read<DeleteItemCubit>()
                                                  .deleteItem(model.id!);

                                          },
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
          backgroundColor: context.color.secondaryDetailsColor,
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: bottomButtonWidget()),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  setImageViewer(),
                  if (isAddedByMe) setLikesAndViewsCount(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(model.name!)
                        .size(context.font.large)
                        .setMaxLines(lines: 2)
                        .color(context.color.textDefaultColor),
                  ),
                  setPriceAndStatus(),

                  if (model.address != null) setAddress(isDate: true),
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor.withOpacity(0.1)),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Container(
                      height: 85,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: context.color.textDefaultColor
                                  .withOpacity(0.1))),

                      // Set the height of the banner container

                      // Height of the banner ad container
                      alignment: Alignment.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ),
                  if (isAddedByMe)
                    if (!model.isFeature!) createFeaturesAds(),
                  if (model.customFields!.isNotEmpty)
                    Divider(
                        thickness: 1,
                        color: context.color.textDefaultColor.withOpacity(0.1)),

                  customFields(),
                  //detailsContainer Widget
                  //Dynamic Ads here
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor.withOpacity(0.1)),
                  setDescription(),
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor.withOpacity(0.1)),
                  if (!isAddedByMe && model.user != null) setSellerDetails(),
                  //Dynamic Ads here
                  setLocation(),
                  /*     Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 3),
                    child: Container(
                      height: 85,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: context.color.borderColor.darken(40))),

                      // Set the height of the banner container

                      // Height of the banner ad container
                      alignment: Alignment.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ),*/
                  //Dynamic Ads here

                  if (!isAddedByMe) setReportAd(),
                  relatedAds(),
                  // const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ));
  }

  Widget relatedAds() {
    return BlocBuilder<FetchRelatedItemsCubit, FetchRelatedItemsState>(
        builder: (context, state) {
      if (state is FetchRelatedItemsInProgress) {
        return relatedItemShimmer();
      }
      if (state is FetchRelatedItemsFailure) {
        if (state.errorMessage is ApiException) {
          if (state.errorMessage == "no-internet") {
            return NoInternet(
              onRetry: () {
                context
                    .read<FetchRelatedItemsCubit>()
                    .fetchRelatedItems(categoryId!);
              },
            );
          }
        }

        return const SomethingWentWrong();
      }

      if (state is FetchRelatedItemsSuccess) {
        if (state.itemModel.isEmpty || state.itemModel.length == 1) {
          return SizedBox.shrink();
        }

        return buildRelatedListWidget(state);
      }

      return const SizedBox.square();
    });
  }

  Widget buildRelatedListWidget(FetchRelatedItemsSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("relatedAds".translate(context))
              .size(context.font.large)
              .bold(weight: FontWeight.w600)
              .setMaxLines(lines: 1),
          SizedBox(
            height: 15,
          ),
          GridListAdapter(
            type: ListUiType.List,
            height: MediaQuery.of(context).size.height / 3.5.rh(context),
            controller: _pageScrollController,
            listAxis: Axis.horizontal,
            listSaperator: (BuildContext p0, int p1) => const SizedBox(
              width: 14,
            ),
            isNotSidePadding: true,
            builder: (context, int index) {
              ItemModel? item = state.itemModel[index];

              if (item.id != model.id) {
                return ItemCard(
                  item: item,
                  width: 162,
                );
              } else {
                return SizedBox.shrink();
              }
            },
            total: state.itemModel.length,
          ),
        ],
      ),
    );
  }

  Widget relatedItemShimmer() {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: const CustomShimmer(
                  height: 200,
                  width: 300,
                ),
              );
            }));
  }

  Widget createFeaturesAds() {
    if (model.status == "active" || model.status == "approved") {
      return BlocListener<FetchUserPackageLimitCubit,
          FetchUserPackageLimitState>(
        listener: (context, state) {
          if (state is FetchUserPackageLimitFailure) {
            UiUtils.noPackageAvailableDialog(context);
          }
          if (state is FetchUserPackageLimitInSuccess) {
            createFeaturedDialog(model);
          }
        },
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 500),
          crossFadeState: isFeaturedWidget
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            height: 116,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.color.territoryColor.withOpacity(0.1),
              border: Border.all(color: context.color.borderColor.darken(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: SvgPicture.asset(
                    AppIcons.createAddIcon,
                    height: 74,
                    width: 62,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${"featureYourAdsAttractMore".translate(context)}\n${"clientsAndSellFaster".translate(context)}",
                        style: TextStyle(
                          color:
                              context.color.textDefaultColor.withOpacity(0.7),
                          fontSize: context.font.large,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          context
                              .read<FetchUserPackageLimitCubit>()
                              .fetchUserPackageLimit(
                                  packageType: "advertisement");
                        },
                        child: Container(
                          height: 33,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: context.color.territoryColor,
                          ),
                          child: Text(
                            "createFeaturedAd".translate(context),
                            style: TextStyle(
                              color: context.color.secondaryColor,
                              fontSize: context.font.small,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          secondChild: SizedBox.shrink(),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

/*  Widget createFeaturesAds() {
    if (model.status == "active" || model.status == "approved") {
      return BlocListener<FetchUserPackageLimitCubit,
          FetchUserPackageLimitState>(
        listener: (context, state) {
          if (state is FetchUserPackageLimitFailure) {
            UiUtils.noPackageAvailableDialog(context);
          }
          if (state is FetchUserPackageLimitInSuccess) {
            createFeaturedDialog(model);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          height: 116,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.color.territoryColor.withOpacity(0.1),
            border: Border.all(color: context.color.borderColor.darken(30)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: SvgPicture.asset(
                  AppIcons.createAddIcon,
                  height: 74,
                  width: 62,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${"featureYourAdsAttractMore".translate(context)}\n${"clientsAndSellFaster".translate(context)}",
                      style: TextStyle(
                        color: context.color.textDefaultColor.withOpacity(0.7),
                        fontSize: context.font.large,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        context
                            .read<FetchUserPackageLimitCubit>()
                            .fetchUserPackageLimit(
                                packageType: "advertisement");
                      },
                      child: Container(
                        height: 33,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.color.territoryColor,
                        ),
                        child: Text(
                          "createFeaturedAd".translate(context),
                          style: TextStyle(
                            color: context.color.secondaryColor,
                            fontSize: context.font.small,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }*/

  Widget customFields() {
    return Wrap(
      children: [
        ...List.generate(model.customFields!.length, (index) {
          if (model.customFields![index].value!.isNotEmpty) {
            return SizedBox(
              width: (context.screenWidth / 2) - (sidePadding / 2) - 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: model.customFields![index].name,
                    child: Text((model.customFields?[index].name) ?? "")
                        .setMaxLines(lines: 1)
                        .size(context.font.small)
                        .color(context.color.textDefaultColor.withOpacity(0.5)),
                  ),
                  valueContent(model.customFields![index].value),
                  /*((model.customFields![index].value![0].toString())
                              .startsWith("http") ||
                          (model.customFields![index].value![0].toString())
                              .startsWith("https"))
                      ? Text(model.customFields![index].value![0]
                              .toString()
                              .split("/")
                              .last)
                          .setMaxLines(lines: 3)
                          .color(context.color.textDefaultColor)
                      : Text(model.customFields![index].value![0].toString())
                          .color(context.color.textDefaultColor),*/
                  const SizedBox(
                    height: 12,
                  )
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        })
      ],
    );
  }

  Widget valueContent(List<dynamic>? value) {
    if (((value![0].toString()).startsWith("http") ||
        (value[0].toString()).startsWith("https"))) {
      if ((value[0].toString()).toLowerCase().endsWith(".pdf")) {
        // Render PDF link as clickable text
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewer(url: value[0]),
              ),
            );
          },
          child: Text(
            value[0],
            style: TextStyle(
              color: context.color.textDefaultColor,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      } else if ((value[0]).toLowerCase().endsWith(".png") ||
          (value[0]).toLowerCase().endsWith(".jpg") ||
          (value[0]).toLowerCase().endsWith(".jpeg") ||
          (value[0]).toLowerCase().endsWith(".svg")) {
        // Render image
        return InkWell(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(
                value[0],
              ),
            );
          },
          child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.color.territoryColor.withOpacity(0.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: UiUtils.imageType(
                  value[0],
                  color: context.color.territoryColor,
                  fit: BoxFit.cover,
                ),
              )),
        );
      }
    }

    // Default text if not a supported format or not a URL
    return Text(
      value.length == 1 ? value[0].toString() : value.join(','),
      style: TextStyle(
        color: context.color.textDefaultColor,
      ),
    );
  }

  Widget bottomButtonWidget() {
    if (isAddedByMe) {
      final model = widget.model;
      final contextColor = context.color;

      if (model.status == "review") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButton("editBtnLbl".translate(context), () {
              addCloudData("edit_request", model);
              addCloudData("edit_from", model.status);
              Navigator.pushNamed(context, Routes.addItemDetails,
                  arguments: {"isEdit": true});
            }, contextColor.secondaryColor, contextColor.territoryColor),
            SizedBox(width: 10.rw(context)),
            BlocProvider(
              create: (context) => DeleteItemCubit(),
              child: Builder(builder: (context) {
                return BlocListener<DeleteItemCubit, DeleteItemState>(
                  listener: (context, deleteState) {
                    if (deleteState is DeleteItemSuccess) {
                      HelperUtils.showSnackBarMessage(
                          context, "deleteItemSuccessMsg".translate(context));
                      context.read<FetchMyItemsCubit>().deleteItem(model);
                      Navigator.pop(context, "refresh");
                    } else if (deleteState is DeleteItemFailure) {
                      HelperUtils.showSnackBarMessage(
                          context, deleteState.errorMessage);
                    }
                  },
                  child: _buildButton("lblremove".translate(context), () {
                    Future.delayed(
                      Duration.zero,
                      () {
                        if (Constant.isDemoModeOn) {
                          HelperUtils.showSnackBarMessage(
                              context,
                              UiUtils.getTranslatedLabel(
                                  context, "thisActionNotValidDemo"));
                          return;
                        }
                          context.read<DeleteItemCubit>().deleteItem(model.id!);

                      },
                    );
                  }, null, null),
                );
              }),
            ),
          ],
        );
      } else if (model.status == "active" || model.status == "approved") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButton("editBtnLbl".translate(context), () {
              addCloudData("edit_request", model);
              addCloudData("edit_from", model.status);
              Navigator.pushNamed(context, Routes.addItemDetails,
                  arguments: {"isEdit": true});
            }, contextColor.secondaryColor, contextColor.territoryColor),
            SizedBox(width: 10.rw(context)),
            BlocListener<ChangeMyItemStatusCubit, ChangeMyItemStatusState>(
              listener: (context, changeState) {
                if (changeState is ChangeMyItemStatusSuccess) {
                  HelperUtils.showSnackBarMessage(context, changeState.message);
                  Navigator.pop(context, "refresh");
                } else if (changeState is ChangeMyItemStatusFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, changeState.errorMessage);
                }
              },
              child: _buildButton("soldOut".translate(context), () {
                Future.delayed(Duration.zero, () {
                  if (Constant.isDemoModeOn) {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(
                            context, "thisActionNotValidDemo"));
                    return;
                  }
                    context
                        .read<ChangeMyItemStatusCubit>()
                        .changeMyItemStatus(id: model.id!, status: 'sold out');

                });
              }, null, null),
            ),
          ],
        );
      } else if (model.status == "inactive") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButton("editBtnLbl".translate(context), () {
              addCloudData("edit_request", model);
              addCloudData("edit_from", model.status);
              Navigator.pushNamed(context, Routes.addItemDetails,
                  arguments: {"isEdit": true});
            }, contextColor.secondaryColor, contextColor.territoryColor),
            SizedBox(width: 10.rw(context)),
            BlocListener<ChangeMyItemStatusCubit, ChangeMyItemStatusState>(
              listener: (context, changeState) {
                if (changeState is ChangeMyItemStatusSuccess) {
                  HelperUtils.showSnackBarMessage(context, changeState.message);
                  Navigator.pop(context, "refresh");
                } else if (changeState is ChangeMyItemStatusFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, changeState.errorMessage);
                }
              },
              child: _buildButton("active".translate(context), () {
                Future.delayed(Duration.zero, () {
                  if (Constant.isDemoModeOn) {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(
                            context, "thisActionNotValidDemo"));
                    return;
                  }
                    context
                        .read<ChangeMyItemStatusCubit>()
                        .changeMyItemStatus(id: model.id!, status: 'active');

                });
              }, null, null),
            ),
          ],
        );
      } else if (model.status == "sold out") {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => DeleteItemCubit(),
            ),
            BlocProvider(
              create: (context) => ChangeMyItemStatusCubit(),
            ),
          ],
          child: Builder(builder: (context) {
            return BlocListener<DeleteItemCubit, DeleteItemState>(
              listener: (context, deleteState) {
                if (deleteState is DeleteItemSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, "deleteItemSuccessMsg".translate(context));

                  context.read<FetchMyItemsCubit>().deleteItem(model);
                  Navigator.pop(context, "refresh");
                } else if (deleteState is DeleteItemFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, deleteState.errorMessage);
                }
              },
              child: _buildButton("lblremove".translate(context), () {
                Future.delayed(
                  Duration.zero,
                  () {
                    if (Constant.isDemoModeOn) {
                      HelperUtils.showSnackBarMessage(
                          context,
                          UiUtils.getTranslatedLabel(
                              context, "thisActionNotValidDemo"));
                      return;
                    }
                      context.read<DeleteItemCubit>().deleteItem(model.id!);

                  },
                );
              }, null, null),
            );
          }),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
        bloc: context.read<GetBuyerChatListCubit>(),
        builder: (context, State) {
          ChatedUser? chatedUser = context.select(
              (GetBuyerChatListCubit cubit) =>
                  cubit.getOfferForItem(model.id!));



          return BlocProvider(
            create: (context) => MakeAnOfferItemCubit(),
            child: Builder(builder: (context) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chatedUser == null /*!model.isAlreadyOffered!*/)
                    _buildButton("makeAnOffer".translate(context), () {
                      if (Constant.isDemoModeOn) {
                        HelperUtils.showSnackBarMessage(context,
                            "thisActionNotValidDemo".translate(context));
                        return;
                      }
                      makeOfferBottomSheet(model);
                    }, null, null),
                  if (chatedUser != null /*model.isAlreadyOffered!*/)
                    SizedBox(width: 10.rw(context)),
                  if (chatedUser != null /*model.isAlreadyOffered!*/)
                    _buildButton("chat".translate(context), () {
                      if (Constant.isDemoModeOn) {
                        HelperUtils.showSnackBarMessage(context,
                            "thisActionNotValidDemo".translate(context));
                        return;
                      }
                      Navigator.push(context, BlurredRouter(
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => SendMessageCubit(),
                              ),
                              BlocProvider(
                                create: (context) => LoadChatMessagesCubit(),
                              ),
                              BlocProvider(
                                create: (context) => DeleteMessageCubit(),
                              ),
                            ],
                            child: ChatScreen(
                              itemId: chatedUser.itemId.toString(),
                              profilePicture: chatedUser.seller != null &&
                                      chatedUser.seller!.profile != null
                                  ? chatedUser.seller!.profile!
                                  : "",
                              userName: chatedUser.seller != null &&
                                      chatedUser.seller!.name != null
                                  ? chatedUser.seller!.name!
                                  : "",
                              date: chatedUser.createdAt!,
                              itemOfferId: chatedUser.id!,
                              itemPrice: chatedUser.item != null &&
                                      chatedUser.item!.price != null
                                  ? chatedUser.item!.price!
                                  : 0,
                              itemOfferPrice: chatedUser.amount!,
                              itemImage: chatedUser.item != null &&
                                      chatedUser.item!.image != null
                                  ? chatedUser.item!.image!
                                  : "",
                              itemTitle: chatedUser.item != null &&
                                      chatedUser.item!.name != null
                                  ? chatedUser.item!.name!
                                  : "",
                              userId: chatedUser.sellerId.toString(),
                              from: "item",
                            ), /*ChatScreen(
                              profilePicture: model.user!.profile ?? "",
                              userName: model.user!.name!,
                              userId: model.user!.id!.toString(),
                              from: "item",
                              itemImage: model.image!,
                              itemId: model.id.toString(),
                              date: model.created!,
                              itemTitle: model.name!,
                              itemPrice: model.price!,
                              itemOfferId: model.itemOffers![0].id!,
                              itemOfferPrice: model.itemOffers![0].amount!,
                            ),*/
                          );
                        },
                      ));
                    }, null, null),
                ],
              );
            }),
          );
        },
      );
    }
  }

  Widget _buildButton(String title, VoidCallback onPressed, Color? buttonColor,
      Color? textColor) {
    return Expanded(
      child: UiUtils.buildButton(
        context,
        onPressed: onPressed,
        radius: 10,
        height: 46,
        border: buttonColor != null
            ? BorderSide(color: context.color.territoryColor)
            : null,
        buttonColor: buttonColor,
        textColor: textColor,
        buttonTitle: title,
        width: 50.rw(context),
      ),
    );
  }

//ImageView
  Widget setImageViewer() {
    return Container(
      height: 200.rh(context),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          PageView.builder(
              itemCount: images.length,
              controller: pageController,
              itemBuilder: (context, index) => ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.01),
                          Colors.black.withOpacity(0.55)
                        ]).createShader(bounds);
                    //TODO: change black color to some other app color if required
                  },
                  blendMode: BlendMode.darken,
                  child: InkWell(
                    child: UiUtils.getImage(
                      images[index]!,
                      fit: BoxFit.cover,
                      height: 200.rh(context),
                    ),
                    onTap: () {
                      UiUtils.showFullScreenImage(
                        context,
                        provider: NetworkImage(
                          images[index]!,
                        ),
                      );
                    },
                  ))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          images.length, (index) => buildDot(index))))),
          if (widget.model.isFeature != null)
            if (widget.model.isFeature!)
              setTopRowItem(
                  alignment: Alignment.topLeft,
                  marginVal: 15,
                  cornerRadius: 5,
                  backgroundColor: context.color.territoryColor,
                  childWidget: Text("featured".translate(context))
                      .size(context.font.small)
                      .color(context.color.backgroundColor)),
          favouriteButton()
        ]),
      ),
    );
  }

  Widget favouriteButton() {
    if (!isAddedByMe) {
      return BlocBuilder<FavoriteCubit, FavoriteState>(
        bloc: context.read<FavoriteCubit>(),
        builder: (context, favState) {
          bool isLike = context
              .select((FavoriteCubit cubit) => cubit.isItemFavorite(model.id!));

          return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
            bloc: context.read<UpdateFavoriteCubit>(),
            listener: (context, state) {
              if (state is UpdateFavoriteSuccess) {
                if (state.wasProcess) {
                  context.read<FavoriteCubit>().addFavoriteitem(state.item);
                } else {
                  context.read<FavoriteCubit>().removeFavoriteItem(state.item);
                }
              }
            },
            builder: (context, state) {
              return setTopRowItem(
                  alignment: Alignment.topRight,
                  marginVal: 10,
                  backgroundColor: context.color.backgroundColor,
                  cornerRadius: 30,
                  childWidget: InkWell(
                    onTap: () {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            context.read<UpdateFavoriteCubit>().setFavoriteItem(
                                  item: model,
                                  type: isLike ? 0 : 1,
                                );
                          },
                          context: context);
                    },
                    child: state is UpdateFavoriteInProgress
                        ? UiUtils.progress(
                            height: 22,
                            width: 22,
                          )
                        : UiUtils.getSvg(
                            isLike ? AppIcons.like_fill : AppIcons.like,
                            color: context.color.territoryColor,
                            width: 22,
                            height: 22),
                  ));
            },
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setTopRowItem(
      {required Alignment alignment,
      required double marginVal,
      required double cornerRadius,
      required Color backgroundColor,
      required Widget childWidget}) {
    return Align(
        alignment: alignment,
        child: Container(
            margin: EdgeInsets.all(marginVal),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: backgroundColor),
            child: childWidget)
        //TODO: swap icons according to liked and non-liked -- favorite_border_rounded and favorite_rounded
        );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      width: currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == index ? Colors.white : Colors.grey),
    );
  }

//ImageView

  Widget setLikesAndViewsCount() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color:
                              context.color.textDefaultColor.withOpacity(0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46.rh(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.eye,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(model.views!.toString())
                          .color(
                              context.color.textDefaultColor.withOpacity(0.8))
                          .size(context.font.large)
                    ],
                  ))),
          SizedBox(width: 20.rw(context)),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color:
                              context.color.textDefaultColor.withOpacity(0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46.rh(context),
                  //alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.like,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(model.totalLikes == null
                              ? "0"
                              : model.totalLikes.toString())
                          .color(
                              context.color.textDefaultColor.withOpacity(0.8))
                          .size(context.font.large)
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget setPriceAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text("${Constant.currencySymbol} ${model.price.toString()}")
              .size(context.font.larger)
              .color(context.color.territoryColor)
              .bold(),
        ),
        if (model.status != null && isAddedByMe)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _getStatusColor(model.status),
            ),
            child: Text(
              model.status!.firstUpperCase(),
            ).size(context.font.normal).color(
                  _getStatusTextColor(model.status),
                ),
          )

        //TODO: change color according to status - confirm,pending,etc..
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor.withOpacity(0.1);
      case "active" || "approved":
        return activateButtonColor.withOpacity(0.1);
      case "inactive":
        return deactivateButtonColor.withOpacity(0.1);
      case "sold out":
        return soldOutButtonColor.withOpacity(0.1);
      default:
        return context.color.territoryColor.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor;
      case "active" || "approved":
        return activateButtonColor;
      case "inactive":
        return deactivateButtonColor;
      case "sold out":
        return soldOutButtonColor;
      default:
        return context.color.territoryColor;
    }
  }

  Widget setAddress({required bool isDate}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            (isDate) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppIcons.location,
            colorFilter:
                ColorFilter.mode(context.color.territoryColor, BlendMode.srcIn),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(model.address!)
                  .color(context.color.textDefaultColor.withOpacity(0.5)),
            ),
          ),
          (isDate)
              ? Expanded(
                  child: Text(model.created!.formatDate(format: "d MMM yyyy"))
                      .setMaxLines(lines: 1)
                      .color(context.color.textDefaultColor.withOpacity(0.5)))
              : const SizedBox.shrink()
          //TODO: add DATE from model
        ],
      ),
    );
  }

  Widget setDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("aboutThisItemLbl".translate(context)).bold().size(context
            .font.large), //TODO: replace label with your own - aboutThisPropLbl
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(model.description!)
              .color(context.color.textDefaultColor.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget setLocation() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("locationLbl".translate(context)).bold().size(context.font.large),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text("${"addressLbl".translate(context)} :")
            .color(context.color.textDefaultColor),
      ),
      setAddress(isDate: false),
      SizedBox(
        height: 5,
      ),
      InkWell(
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    "assets/map.png",
                    fit: BoxFit.cover,
                    height: 200.rh(context),
                  )),
              Positioned.fill(
                child: FractionalTranslation(
                  translation: const Offset(0.0, 0.0), // Center the icon
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: context
                          .color.territoryColor, // Change to your desired color
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            /* Navigator.push(
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
                    ),
                  );
                },
              ),
            );*/
            Navigator.push(
              context,
              BlurredRouter(
                barrierDismiss: true,
                builder: (context) {
                  return GoogleMapScreen(
                      item: model,
                      kInitialPlace: _kInitialPlace,
                      controller: _controller);
                },
              ),
            );
          })
    ]);
  }

  Widget setReportAd() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      crossFadeState: isShowReportAds
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withOpacity(0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.red, // Icon color can be adjusted
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "didYouFindAnyProblemWithThisItem".translate(context),
                  )
                      .color(context.color.textDefaultColor)
                      .size(context.font.large),
                ]),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    UiUtils.checkUser(
                        onNotGuest: () {
                          if (Constant.isDemoModeOn) {
                            HelperUtils.showSnackBarMessage(context,
                                "thisActionNotValidDemo".translate(context));
                            return;
                          }
                          _bottomSheet(model.id!);
                        },
                        context: context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.territoryColor
                          .withOpacity(0.1), // Button color can be adjusted
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.report,
                          size: 20,
                          color: context.color
                              .territoryColor, // Icon color can be adjusted
                        ),
                        SizedBox(width: 5),
                        Text(
                          "yes".translate(context),
                        )
                            .color(context.color.territoryColor)
                            .size(context.font.normal),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isShowReportAds = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.color.territoryColor
                          .withOpacity(0.1), // Button color can be adjusted
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 20,
                          color: context.color
                              .territoryColor, // Icon color can be adjusted
                        ),
                        SizedBox(width: 5),
                        Text(
                          "no".translate(context),
                        )
                            .color(context.color.territoryColor)
                            .size(context.font.normal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      secondChild: SizedBox.shrink(),
    );
  }

  void makeOfferBottomSheet(ItemModel model) {
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: MakeAnOfferItemScreen(
            model: model,
          ),
        )));
  }

  void _bottomSheet(int itemId) {
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: BlocListener<ItemReportCubit, ItemReportState>(
            listener: (context, state) {
              if (state is ItemReportInSuccess) {
                setState(() {
                  isShowReportAds = false;
                });
              }
            },
            child: ReportItemScreen(itemId: itemId),
          ),
        ))).then((value) {
      setState(() {});
    });
  }

  Widget setSellerDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        SizedBox(
            height: 60.rh(context),
            width: 60.rw(context),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: model.user!.profile != null && model.user!.profile != ""
                    ? UiUtils.getImage(model.user!.profile!, fit: BoxFit.fill)
                    : UiUtils.getSvg(
                        AppIcons.defaultPersonLogo,
                        color: context.color.territoryColor,
                        fit: BoxFit.none,
                      ))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(model.user!.name!).bold().size(context.font.large),
              Text(model.user!.email!)
                  .color(context.color.textLightColor)
                  .size(context.font.small)
            ]),
          ),
        ),
        setIconButtons(
            assetName: AppIcons.message,
            onTap: () {
              HelperUtils.launchPathURL(
                  isTelephone: false,
                  isSMS: true,
                  isMail: false,
                  value: widget.model.user!.mobile!,
                  context: context);
            }),
        SizedBox(width: 10.rw(context)),
        setIconButtons(
            assetName: AppIcons.call,
            onTap: () {
              HelperUtils.launchPathURL(
                  isTelephone: true,
                  isSMS: false,
                  isMail: false,
                  value: widget.model.user!.mobile!,
                  context: context);
            })
      ]),
    );
  }

  Widget setIconButtons({
    required String assetName,
    required void Function() onTap,
    Color? color,
    double? height,
    double? width,
  }) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.color.borderColor.darken(30))),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
                onTap: onTap,
                child: SvgPicture.asset(
                  assetName,
                  colorFilter: color == null
                      ? ColorFilter.mode(
                          context.color.territoryColor, BlendMode.srcIn)
                      : ColorFilter.mode(color, BlendMode.srcIn),
                ))));
  }

  void createFeaturedDialog(ItemModel model) async {
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
          child: AlertDialog(
            backgroundColor: context.color.secondaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: StatefulBuilder(builder: (context, update) {
              return BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
                listener: (context, state) {
                  if (state is CreateFeaturedAdInSuccess) {
                    setState(() {
                      isFeaturedWidget = false;
                    });
                    HelperUtils.showSnackBarMessage(
                        context, state.responseMessage.toString(),
                        messageDuration: 3);
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                    context.read<FetchMyItemsCubit>().fetchMyItems(
                          getItemsWithStatus: "",
                        );
                  }

                  if (state is CreateFeaturedAdFailure) {
                    HelperUtils.showSnackBarMessage(
                        context, state.error.toString(),
                        messageDuration: 3);
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('areYouSureToCreateThisItemAsAFeaturedAd'
                        .translate(context)),
                  ],
                ),
              );
            }),
            title: Text('createFeaturedAd'.translate(context)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                      onPressed: () {
                        if (Constant.isDemoModeOn) {
                          HelperUtils.showSnackBarMessage(context,
                              "thisActionNotValidDemo".translate(context));
                          return;
                        }
                        context.read<CreateFeaturedAdCubit>().createFeaturedAds(
                              itemId: model.id!,
                            );
                      },
                      elevation: 0,
                      height: 39.rh(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: context.color.borderColor)),
                      color: context.color.territoryColor,
                      // minWidth: (constraints.maxWidth / 2) - 10,

                      child: Text("yes".translate(context))),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 0,
                      height: 39.rh(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: context.color.borderColor)),
                      color: context.color.primaryColor,
                      // minWidth: (constraints.maxWidth / 2) - 10,

                      child: Text("no".translate(context)))
                ],
              ),
            ],
          ),
        ));
  }
}
