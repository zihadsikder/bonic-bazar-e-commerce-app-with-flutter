import 'package:eClassify/Ui/screens/Subscription/widget/subscriptionPlansItem.dart';
import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/api.dart';
import '../../../data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';
import '../Widgets/Errors/no_data_found.dart';
import '../Widgets/Errors/no_internet.dart';
import '../Widgets/Errors/something_went_wrong.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class SubscriptionPackageListScreen extends StatefulWidget {
  const SubscriptionPackageListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(builder: (context) {
      return MultiBlocProvider(
        providers: [

          BlocProvider(
            create: (context) => AssignFreePackageCubit(),
          ),
        ],
        child: const SubscriptionPackageListScreen(),
      );
    });
  }

  @override
  State<SubscriptionPackageListScreen> createState() =>
      _SubscriptionPackageListScreenState();
}

class _SubscriptionPackageListScreenState
    extends State<SubscriptionPackageListScreen> {
  //List mySubscriptions = [];
  bool isLifeTimeSubscription = false;
  bool hasAlreadyPackage = false;

  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);

  int currentIndex = 0;

  //bool isCurrentPlan = false;

  @override
  void initState() {
    context.read<FetchSubscriptionPackagesCubit>().fetchPackages();


/*    mySubscriptions = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.subscription) ??
        [];*/
/*    if (mySubscriptions.isNotEmpty) {
      isLifeTimeSubscription = mySubscriptions[0]['end_date'] == null;
      context
          .read<GetSubsctiptionPackageLimitsCubit>()
          .getLimits(Constant.subscriptionPackageId.toString());
    }*/

    //  hasAlreadyPackage = mySubscriptions.isNotEmpty;
    super.initState();
  }

/*  dynamic ifServiceUnlimited(int text, {dynamic remaining}) {
    if (text == 0) {
      return "unlimited".translate(context);
    }
    if (remaining != null) {
      return "";
    }

    return text;
  }

  bool isUnlimited(int text, {dynamic remaining}) {
    if (text == 0) {
      return true;
    }
    if (remaining != null) {
      return false;
    }

    return false;
  }*/

  int selectedPage = 0;

/*
  List<SubscriptionPackageModel> subscriptionPackages = [
    SubscriptionPackageModel(
        id: 0,
        name: 'Free Package',
        price: 10000,
        itemLimit: "100",
        advertisementlimit: "5",
        duration: 20,
        status: 1,
        createdAt: "07-12-2023",
        updatedAt: "07-12-2023"),
    SubscriptionPackageModel(
        id: 1,
        name: 'Bronze Package',
        price: 12000,
        itemLimit: "200",
        advertisementlimit: "10",
        duration: 30,
        status: 1,
        createdAt: "07-12-2023",
        updatedAt: "07-12-2023"),
    SubscriptionPackageModel(
        id: 2,
        name: 'Silver Package',
        price: 18000,
        itemLimit: "300",
        advertisementlimit: "15",
        duration: 40,
        status: 1,
        createdAt: "07-12-2023",
        updatedAt: "07-12-2023"),
    SubscriptionPackageModel(
        id: 3,
        name: 'Bronze Package',
        price: 20000,
        itemLimit: "400",
        advertisementlimit: "40",
        duration: 50,
        status: 1,
        createdAt: "07-12-2023",
        updatedAt: "07-12-2023"),
    SubscriptionPackageModel(
        id: 4,
        name: 'Silver Package',
        price: 24000,
        itemLimit: "500",
        advertisementlimit: "55",
        duration: 60,
        status: 1,
        createdAt: "07-12-2023",
        updatedAt: "07-12-2023"),
  ];
*/

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index; //update current index for Next button
      // (index == 1) ? isCurrentPlan = true : isCurrentPlan = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      backgroundColor: context.color.primaryColor,
      color: context.color.territoryColor,
      onRefresh: () async {
        context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

        /*  mySubscriptions = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.subscription);

        if (mySubscriptions.isNotEmpty) {
          isLifeTimeSubscription = mySubscriptions[0]['end_date'] == null;
        }

        hasAlreadyPackage = mySubscriptions.isNotEmpty;*/
      },
      child: Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: "subsctiptionPlane".translate(context),
          ),
          /* bottomNavigationBar: (isCurrentPlan)
              ? const Padding(
                  padding: EdgeInsets.only(
                      bottom: 10.0,
                      left: 15,
                      right:
                          15), // EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                      "Your subscription will expire on Jan 01, 2024 Renew or cancel your subscription here"),
                ) //TODO: change / translate string as per requirement & assign Value to isCurrentPlan parameter to show/hide it
              : null,*/
          body: SafeArea(
              child: BlocListener<FetchSystemSettingsCubit,
                  FetchSystemSettingsState>(listener: (context, state) {
            if (state is FetchSystemSettingsSuccess) {
              /*   mySubscriptions = state.settings['data']['package']
                  ['user_purchased_package'] as List;
              setState(() {});*/
            }
          }, child: Builder(builder: (context) {
            return BlocConsumer<FetchSubscriptionPackagesCubit,
                    FetchSubscriptionPackagesState>(
                listener: (context, FetchSubscriptionPackagesState state) {},
                builder: (context, state) {
                  if (state is FetchSubscriptionPackagesInProgress) {
                    return Center(
                      child: UiUtils.progress(),
                    );
                  }
                  if (state is FetchSubscriptionPackagesFailure) {
                    if (state.errorMessage is ApiException) {
                      if (state.errorMessage == "no-internet") {
                        return NoInternet(
                          onRetry: () {
                            context
                                .read<FetchSubscriptionPackagesCubit>()
                                .fetchPackages();
                          },
                        );
                      }
                    }

                    return const SomethingWentWrong();
                  }
                  if (state is FetchSubscriptionPackagesSuccess) {
                    if (state.subscriptionPacakges
                            .isEmpty /*&&
                        mySubscriptions.isEmpty*/
                        ) {
                      return NoDataFound(
                        onTap: () {
                          context
                              .read<FetchSubscriptionPackagesCubit>()
                              .fetchPackages();

                          /*  mySubscriptions = context
                              .read<FetchSystemSettingsCubit>()
                              .getSetting(SystemSetting.subscription);

                          if (mySubscriptions.isNotEmpty) {
                            isLifeTimeSubscription =
                                mySubscriptions[0]['end_date'] == null;
                          }

                          hasAlreadyPackage = mySubscriptions.isNotEmpty;
                          setState(() {});*/
                        },
                      );
                    }


                    return PageView.builder(
                        onPageChanged: onPageChanged,
                        //update index and fetch nex index details
                        controller: pageController,
                        itemBuilder: (context, index) {
                          return SubscriptionPlansItem(
                              itemIndex: currentIndex,
                              index: index,
                              model: state.subscriptionPacakges[index]);
                        },
                        itemCount: state.subscriptionPacakges.length);
                  }

                  return Container();
                });
          })))
          /* BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
          listener: (context, state) {
            if (state is FetchSystemSettingsSuccess) {
              mySubscriptions = state.settings['data']['package']
                  ['user_purchased_package'] as List;
              setState(() {});
            }
          },
          child: Builder(builder: (context) {
            return BlocConsumer<FetchSubscriptionPackagesCubit,
                FetchSubscriptionPackagesState>(
              listener: (context, FetchSubscriptionPackagesState state) {},
              builder: (context, state) {
                if (state is FetchSubscriptionPackagesInProgress) {
                  return ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: CustomShimmer(
                          height: 160,
                        ),
                      );
                    },
                  );
                }
                if (state is FetchSubscriptionPackagesFailure) {
                  if (state.errorMessage is ApiException) {
                    if (state.errorMessage.errorMessage == "no-internet") {
                      return NoInternet(
                        onRetry: () {
                          context
                              .read<FetchSubscriptionPackagesCubit>()
                              .fetchPackages();
                        },
                      );
                    }
                  }

                  return const SomethingWentWrong();
                }
                if (state is FetchSubscriptionPackagesSuccess) {
                  if (state.subscriptionPacakges.isEmpty &&
                      mySubscriptions.isEmpty) {
                    return NoDataFound(
                      onTap: () {
                        context
                            .read<FetchSubscriptionPackagesCubit>()
                            .fetchPackages();

                        mySubscriptions = context
                            .read<FetchSystemSettingsCubit>()
                            .getSetting(SystemSetting.subscription);

                        if (mySubscriptions.isNotEmpty) {
                          isLifeTimeSubscription =
                              mySubscriptions[0]['end_date'] == null;
                        }

                        hasAlreadyPackage = mySubscriptions.isNotEmpty;
                        setState(() {});
                      },
                    );
                  }

                  // return Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     CarouselSlider.builder(
                  //       itemCount: state.subscriptionPacakges.length,
                  //       itemBuilder: (BuildContext context, int itemIndex,
                  //           int pageViewIndex) {
                  //         SubscriptionPackageModel subscriptionPacakge =
                  //             state.subscriptionPacakges[itemIndex];
                  //         return Container(
                  //           width: context.screenWidth * 0.98,
                  //           decoration: BoxDecoration(
                  //               color: context.color.secondaryColor,
                  //               borderRadius: BorderRadius.circular(18),
                  //               border: Border.all(
                  //                   color: context.color.borderColor,
                  //                   width: 1.5)),
                  //           child: Column(
                  //             children: [
                  //               const SizedBox(
                  //                 height: 24,
                  //               ),
                  //               Text(subscriptionPacakge.name.toString())
                  //                   .size(context.font.extraLarge)
                  //                   .color(context.color.teritoryColor)
                  //                   .bold(weight: FontWeight.w600),
                  //               const SizedBox(
                  //                 height: 14,
                  //               ),
                  //               Container(
                  //                 width: 186,
                  //                 height: 186,
                  //                 decoration: BoxDecoration(
                  //                   color: context.color.teritoryColor
                  //                       .withOpacity(0.1),
                  //                   shape: BoxShape.circle,
                  //                 ),
                  //                 child: SvgPicture.asset(AppIcons.placeHolder),
                  //               ),
                  //               const SizedBox(
                  //                 height: 10,
                  //               ),
                  //               Padding(
                  //                 padding: const EdgeInsets.fromLTRB(
                  //                     20.0, 10, 20, 10),
                  //                 child: Container(
                  //                   height: 75,
                  //                   decoration: BoxDecoration(
                  //                       borderRadius: BorderRadius.circular(14),
                  //                       border: Border.all(
                  //                           color: context.color.teritoryColor,
                  //                           width: 1.5)),
                  //                   child: Padding(
                  //                     padding: const EdgeInsets.symmetric(
                  //                         horizontal: 18.0, vertical: 14),
                  //                     child: Row(
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.spaceBetween,
                  //                       crossAxisAlignment:
                  //                           CrossAxisAlignment.center,
                  //                       children: [
                  //                         Column(
                  //                           crossAxisAlignment:
                  //                               CrossAxisAlignment.start,
                  //                           children: [
                  //                             Text("30 Days")
                  //                                 .size(context.font.larger)
                  //                                 .bold(
                  //                                     weight: FontWeight.w600),
                  //                             Text("50% Off").color(
                  //                                 context.color.textLightColor)
                  //                           ],
                  //                         ),
                  //                         Column(
                  //                           crossAxisAlignment:
                  //                               CrossAxisAlignment.end,
                  //                           children: [
                  //                             Text(r"$549")
                  //                                 .size(context.font.larger)
                  //                                 .bold(
                  //                                     weight: FontWeight.w600),
                  //                             Text(r"800").color(
                  //                                 context.color.textLightColor)
                  //                           ],
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //               Padding(
                  //                 padding: const EdgeInsets.all(19.0),
                  //                 child: Column(
                  //                   children: [
                  //                     PlanFacilityRow(
                  //                         count: subscriptionPacakge
                  //                             .advertisementlimit
                  //                             .toString(),
                  //                         facilityTitle:
                  //                             "Advertisement limit is",
                  //                         icon: AppIcons.ads),
                  //                     const SizedBox(
                  //                       height: 12,
                  //                     ),
                  //                     PlanFacilityRow(
                  //                         count: subscriptionPacakge
                  //                             .itemLimit
                  //                             .toString(),
                  //                         facilityTitle: "Item limit is",
                  //                         icon: AppIcons.itemLimites),
                  //                     const SizedBox(
                  //                       height: 12,
                  //                     ),
                  //                     PlanFacilityRow(
                  //                         count:
                  //                             "${subscriptionPacakge.duration}",
                  //                         facilityTitle: "Validity ",
                  //                         icon: AppIcons.days),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //       options: CarouselOptions(
                  //           autoPlay: false,
                  //           enlargeCenterPage: true,
                  //           onPageChanged: (index, reason) {
                  //             selectedPage = index;
                  //             setState(() {});
                  //           },
                  //           viewportFraction: 0.8,
                  //           initialPage: 0,
                  //           height: 420 + 72 + 15,
                  //           // clipBehavior: Clip.antiAlias,
                  //           disableCenter: true,
                  //           enableInfiniteScroll: false),
                  //     ),
                  //     const SizedBox(
                  //       height: 38,
                  //     ),
                  //     Indicator(state, context),
                  //     const SizedBox(
                  //       height: 38,
                  //     ),
                  //     MaterialButton(
                  //       onPressed: () {},
                  //       height: 50,
                  //       minWidth: context.screenWidth * 0.8,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       color: context.color.teritoryColor,
                  //       child: const Text("Subscribe Now")
                  //           .color(context.color.buttonColor)
                  //           .size(context.font.larger),
                  //     ),
                  //   ],
                  // );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ...mySubscriptions.map((subscription) {
                          var packageName = subscription['package']['name'];
                          var packagePrice =
                              subscription['package']['price'].toString();
                          var packageValidity =
                              subscription['package']['duration'];
                          var advertismentLimit =
                              subscription['package']['advertisement_limit'];
                          var itemLimit =
                              subscription['package']['item_limit'];
                          var startDate = subscription['start_date']
                              .toString()
                              .formatDate(format: "d MMM yyyy");
                          var startDay = subscription['start_date']
                              .toString()
                              .formatDate(format: "EEEE");

                          var endDate = subscription['end_date'];

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            child: CurrentPackageTileCard(
                                startDay: startDay,
                                name: packageName,
                                price: packagePrice,
                                advertismentLimit: advertismentLimit,
                                itemLimit: itemLimit,
                                duration: packageValidity,
                                endDate: endDate,
                                startDate: startDate,
                                advertismentRemining: advertismentRemining,
                                itemRemining: itemRemining),
                          );
                        }).toList(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.subscriptionPacakges.length,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemBuilder: (context, index) {
                            SubscriptionPackageModel subscriptionPacakge =
                                state.subscriptionPacakges[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: buildPackageTile(
                                  context, subscriptionPacakge),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Container();
              },
            );
          }),
        ), */
          ),
    );
  }

  Row Indicator(FetchSubscriptionPackagesSuccess state, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate((state.subscriptionPacakges.length), (index) {
          bool isSelected = selectedPage == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border()
                    : Border.all(color: context.color.textColorDark),
                color: isSelected
                    ? context.color.territoryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        })
      ],
    );
  }

  Widget PlanFacilityRow(
      {required String icon,
      required String facilityTitle,
      required String count}) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter:
              ColorFilter.mode(context.color.territoryColor, BlendMode.srcIn),
        ),
        const SizedBox(
          width: 11,
        ),
        Text("$facilityTitle $count")
            .size(context.font.large)
            .color(context.color.textColorDark.withOpacity(0.8))
      ],
    );
  }

}
