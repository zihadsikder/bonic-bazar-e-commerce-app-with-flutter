import 'dart:developer';

import 'package:eClassify/Ui/screens/Home/home_screen.dart';
import 'package:eClassify/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Utils/api.dart';
import '../../../Utils/cloudState/cloud_state.dart';

import '../../../Utils/helper_utils.dart';
import '../../../app/routes.dart';
import '../../../data/cubits/item/create_featured_ad_cubit.dart';
import '../../../data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import '../../../data/helper/designs.dart';
import '../../../exports/main_export.dart';
import '../Widgets/Errors/no_data_found.dart';
import '../Widgets/Errors/no_internet.dart';
import '../Widgets/Errors/something_went_wrong.dart';
import '../Widgets/shimmerLoadingContainer.dart';

Map<String, FetchMyItemsCubit> myAdsCubitReference = {};

class MyItemTab extends StatefulWidget {
  //final bool? getActiveItems;
  final String? getItemsWithStatus;

  const MyItemTab({super.key, this.getItemsWithStatus});

  @override
  CloudState<MyItemTab> createState() => _MyItemTabState();
}

class _MyItemTabState extends CloudState<MyItemTab> {
  late final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    ///Store reference for later use

    context.read<FetchMyItemsCubit>().fetchMyItems(
          getItemsWithStatus: widget.getItemsWithStatus,
        );
    _pageScrollController.addListener(_pageScroll);
    setReferenceOfCubit();
    super.initState();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyItemsCubit>().hasMoreData()) {
        context
            .read<FetchMyItemsCubit>()
            .fetchMyMoreItems(getItemsWithStatus: widget.getItemsWithStatus);
      }
    }
  }

  void setReferenceOfCubit() {
    myAdsCubitReference[widget.getItemsWithStatus!] =
        context.read<FetchMyItemsCubit>();
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 10 + defaultPadding,
        horizontal: defaultPadding,
      ),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth - 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomShimmer(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth / 1.2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: CustomShimmer(
                          width: c.maxWidth / 4,
                        ),
                      ),
                    ],
                  );
                }),
              )
            ],
          ),
        );
      },
    );
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
                    HelperUtils.showSnackBarMessage(
                        context, state.responseMessage.toString(),
                        messageDuration: 3);
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                    context.read<FetchMyItemsCubit>().fetchMyItems(
                          getItemsWithStatus: widget.getItemsWithStatus,
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FetchMyItemsCubit>().fetchMyItems(
              getItemsWithStatus: widget.getItemsWithStatus,
            );

        setReferenceOfCubit();
      },
      color: context.color.territoryColor,
      child: BlocBuilder<FetchMyItemsCubit, FetchMyItemsState>(
        builder: (context, state) {
          if (state is FetchMyItemsInProgress) {
            return shimmerEffect();
          }

          if (state is FetchMyItemsFailed) {
            if (state.error is ApiException) {
              if (state.error.error == "no-internet") {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchMyItemsCubit>().fetchMyItems(
                        getItemsWithStatus: widget.getItemsWithStatus);
                  },
                );
              }
            }

            return const SomethingWentWrong();
          }

          if (state is FetchMyItemsSuccess) {
            if (state.items.isEmpty) {
              return NoDataFound(
                mainMessage: "noAdsFound".translate(context),
                subMessage: "noAdsAvailable".translate(context),
                onTap: () {
                  context.read<FetchMyItemsCubit>().fetchMyItems(
                      getItemsWithStatus: widget.getItemsWithStatus);
                },
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    controller: _pageScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: 8,
                    ),
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 8,
                      );
                    },
                    itemBuilder: (context, index) {
                      ItemModel item = state.items[index];
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (context) => DeleteItemCubit()),
                          BlocProvider(
                              create: (context) => ChangeMyItemStatusCubit()),
                        ],
                        child: Builder(builder: (context) {
                          return BlocListener<FetchUserPackageLimitCubit,
                              FetchUserPackageLimitState>(
                            listener: (context, state) {
                              if (state is FetchUserPackageLimitFailure) {
                                UiUtils.noPackageAvailableDialog(context);
                              }
                              if (state is FetchUserPackageLimitInSuccess) {
                                createFeaturedDialog(item);
                              }
                            },
                            child: BlocListener<ChangeMyItemStatusCubit,
                                ChangeMyItemStatusState>(
                              listener: (context, changeState) {
                                if (changeState is ChangeMyItemStatusSuccess) {
                                  HelperUtils.showSnackBarMessage(
                                      context, changeState.message);
                                  context
                                      .read<FetchMyItemsCubit>()
                                      .fetchMyItems(
                                        getItemsWithStatus:
                                            widget.getItemsWithStatus,
                                      );
                                } else if (changeState
                                    is ChangeMyItemStatusFailure) {
                                  HelperUtils.showSnackBarMessage(
                                      context, changeState.errorMessage);
                                }
                              },
                              child: BlocListener<DeleteItemCubit,
                                  DeleteItemState>(
                                listener: (context, deleteState) {
                                  if (deleteState is DeleteItemSuccess) {
                                    HelperUtils.showSnackBarMessage(
                                        context,
                                        "deleteItemSuccessMsg"
                                            .translate(context));
                                    context
                                        .read<FetchMyItemsCubit>()
                                        .deleteItem(item);
                                  } else if (deleteState is DeleteItemFailure) {
                                    HelperUtils.showSnackBarMessage(
                                        context, deleteState.errorMessage);
                                  }
                                },
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.adDetailsScreen,
                                        arguments: {
                                          "model": item,
                                        }).then((value) {
                                      if (value == "refresh") {
                                        context
                                            .read<FetchMyItemsCubit>()
                                            .fetchMyItems(
                                              getItemsWithStatus:
                                                  widget.getItemsWithStatus,
                                            );

                                        setReferenceOfCubit();
                                      }
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: item.status == "inactive"
                                              ? context.color.deactivateColor
                                                  .brighten(70)
                                              : context.color.secondaryColor,
                                          border: Border.all(
                                              color: context.color.borderColor
                                                  .darken(30),
                                              width: 1)),
                                      width: double.infinity,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: SizedBox(
                                              width: 116,
                                              height: double.infinity,
                                              child: UiUtils.getImage(
                                                  item.image ?? "",
                                                  height: double.infinity,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14.0,
                                                      vertical: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("${Constant.currencySymbol}\t${item.price}")
                                                      .color(context
                                                          .color.territoryColor)
                                                      .bold(),
                                                  Text(item.name ?? "")
                                                      .setMaxLines(lines: 2)
                                                      .firstUpperCaseWidget(),
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                              AppIcons.eye,
                                                              width: 14,
                                                              height: 14,
                                                              color: context
                                                                  .color
                                                                  .textDefaultColor),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text("${"views".translate(context)}:${item.views}")
                                                              .size(context
                                                                  .font.small)
                                                              .color(context
                                                                  .color
                                                                  .textColorDark
                                                                  .withOpacity(
                                                                      0.8))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 16,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                              AppIcons.heart,
                                                              width: 14,
                                                              height: 14,
                                                              color: context
                                                                  .color
                                                                  .textDefaultColor),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text("${"like".translate(context)}:${item.totalLikes.toString()}")
                                                              .size(context
                                                                  .font.small)
                                                              .color(context
                                                                  .color
                                                                  .textColorDark
                                                                  .withOpacity(
                                                                      0.8)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            alignment: Alignment.center,
                                            child: PopupMenuButton(
                                              color:
                                                  context.color.territoryColor,
                                              offset: Offset(-12, 15),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(17),
                                                  bottomRight:
                                                      Radius.circular(17),
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
                                                    context
                                                        .color.textDefaultColor,
                                                    BlendMode.srcIn),
                                              ),
                                              itemBuilder: (context) => [
                                                if (!item.isFeature!)
                                                  if (item.status == "active" ||
                                                      item.status == "approved")
                                                    PopupMenuItem(
                                                      onTap: () {
                                                        Future.delayed(
                                                            Duration.zero, () {
                                                          if (Constant
                                                              .isDemoModeOn) {
                                                            HelperUtils
                                                                .showSnackBarMessage(
                                                                context,
                                                                "thisActionNotValidDemo"
                                                                    .translate(
                                                                    context));
                                                            return;
                                                          }
                                                            context
                                                                .read<
                                                                    FetchUserPackageLimitCubit>()
                                                                .fetchUserPackageLimit(
                                                                    packageType:
                                                                        "advertisement");

                                                        });
                                                      },
                                                      child: Text("featureAd"
                                                              .translate(
                                                                  context))
                                                          .color(context.color
                                                              .buttonColor),
                                                    ),
                                                if (item.status == "active" ||
                                                    item.status == "inactive" ||
                                                    item.status == "approved")
                                                  PopupMenuItem(
                                                    onTap: () {
                                                      Future.delayed(
                                                          Duration.zero, () {
                                                        if (Constant
                                                            .isDemoModeOn) {
                                                          HelperUtils.showSnackBarMessage(
                                                              context,
                                                              "thisActionNotValidDemo"
                                                                  .translate(
                                                                      context));
                                                          return;
                                                        }
                                                          context
                                                              .read<
                                                                  ChangeMyItemStatusCubit>()
                                                              .changeMyItemStatus(
                                                                  id: item.id!,
                                                                  status:
                                                                      'sold out');

                                                      });
                                                    },
                                                    child: Text("soldOut"
                                                            .translate(context))
                                                        .color(context
                                                            .color.buttonColor),
                                                  ),
                                                if (item.status == "active" ||
                                                    item.status == "approved")
                                                  PopupMenuItem(
                                                    onTap: () {
                                                      Future.delayed(
                                                          Duration.zero, () {
                                                        if (Constant
                                                            .isDemoModeOn) {
                                                          HelperUtils.showSnackBarMessage(
                                                              context,
                                                              "thisActionNotValidDemo"
                                                                  .translate(
                                                                      context));
                                                          return;
                                                        }
                                                          context
                                                              .read<
                                                                  ChangeMyItemStatusCubit>()
                                                              .changeMyItemStatus(
                                                                  id: item.id!,
                                                                  status:
                                                                      'inactive');

                                                      });
                                                    },
                                                    child: Text("deactivate"
                                                            .translate(context))
                                                        .color(context
                                                            .color.buttonColor),
                                                  ),
                                                if (item.status == "active" ||
                                                    item.status == "inactive" ||
                                                    item.status == "review" ||
                                                    item.status == "approved")
                                                  PopupMenuItem(
                                                    child: Text("edit"
                                                            .translate(context))
                                                        .color(context
                                                            .color.buttonColor),
                                                    onTap: () {
                                                      addCloudData(
                                                          "edit_request", item);
                                                      addCloudData(
                                                          "edit_from",
                                                          widget
                                                              .getItemsWithStatus);
                                                      Navigator.pushNamed(
                                                          context,
                                                          Routes.addItemDetails,
                                                          arguments: {
                                                            "isEdit": true
                                                          });
                                                    },
                                                  ),
                                                PopupMenuItem(
                                                  child: Text("lblremove"
                                                          .translate(context))
                                                      .color(context
                                                          .color.buttonColor),
                                                  onTap: () async {
                                                    var delete = await UiUtils
                                                        .showBlurredDialoge(
                                                      context,
                                                      dialoge: BlurredDialogBox(
                                                        title: "deleteBtnLbl"
                                                            .translate(context),
                                                        content: Text(
                                                          "deleteitemwarning"
                                                              .translate(
                                                                  context),
                                                        ),
                                                      ),
                                                    );
                                                    if (delete == true) {
                                                      Future.delayed(
                                                        Duration.zero,
                                                        () {
                                                          if (Constant
                                                              .isDemoModeOn) {
                                                            HelperUtils.showSnackBarMessage(
                                                                context,
                                                                "thisActionNotValidDemo"
                                                                    .translate(
                                                                        context));
                                                            return;
                                                          }
                                                            context
                                                                .read<
                                                                    DeleteItemCubit>()
                                                                .deleteItem(
                                                                    item.id!);

                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          /* const SizedBox(
                                            width: 14,
                                          ),*/
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                    itemCount: state.items.length,
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
