import 'dart:io';

import 'package:eClassify/Ui/screens/Subscription/payment_gatways.dart';
import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:eClassify/data/cubits/subscription/get_payment_intent_cubit.dart';
import 'package:eClassify/data/model/subscription_pacakage_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../Utils/payment/gatways/inAppPurchaseManager.dart';
import '../../../../Utils/payment/gatways/stripe_service.dart';
import '../../../../data/helper/widgets.dart';
import '../../../../exports/main_export.dart';
import '../../../../settings.dart';

class SubscriptionPlansItem extends StatefulWidget {
  final int itemIndex, index;
  final SubscriptionPackageModel model;

  const SubscriptionPlansItem(
      {super.key,
      required this.itemIndex,
      required this.index,
      required this.model});

  @override
  _SubscriptionPlansItemState createState() => _SubscriptionPlansItemState();
}

class _SubscriptionPlansItemState extends State<SubscriptionPlansItem> {
  InAppPurchaseManager inAppPurchase = InAppPurchaseManager();

  @override
  void initState() {
    super.initState();
    StripeService.initStripe(
      AppSettings.stripePublishableKey,
      "test",
    );
    InAppPurchaseManager.getPendings();
    inAppPurchase.listenIAP(context);
  }

  int calculateDiscountPercentage(int mainPrice, int discountPrice) {
    if (mainPrice <= 0) {
      throw ArgumentError('Main price must be greater than zero.');
    }

    int discountPercentage =
        (((mainPrice - discountPrice) / mainPrice) * 100).toInt();
    return discountPercentage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      bottomNavigationBar: bottomWidget(),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AssignFreePackageCubit(),
          ),
          BlocProvider(
            create: (context) => GetPaymentIntentCubit(),
          ),
        ],
        child: Builder(builder: (context) {
          return BlocListener<GetPaymentIntentCubit, GetPaymentIntentState>(
            listener: (context, state) {
              if (state is GetPaymentIntentInSuccess) {
                Widgets.hideLoder(context);

                PaymentGateways.stripe(context,
                    price: widget.model.discountPrice != null &&
                            widget.model.discountPrice! > 0
                        ? widget.model.discountPrice!.toDouble()
                        : widget.model.price!.toDouble(),
                    packageId: widget.model.id!,
                    paymentIntent: state.paymentIntent);
              }

              if (state is GetPaymentIntentInProgress) {
                Widgets.showLoader(context);
              }

              if (state is GetPaymentIntentFailure) {
                Widgets.hideLoder(context);
                HelperUtils.showSnackBarMessage(
                    context, state.error.toString());
              }
            },
            child: BlocListener<AssignFreePackageCubit, AssignFreePackageState>(
              listener: (context, state) {
                if (state is AssignFreePackageInSuccess) {
                  Widgets.hideLoder(context);
                  HelperUtils.showSnackBarMessage(
                      context, state.responseMessage);
                  Navigator.pop(context);
                }
                if (state is AssignFreePackageFailure) {
                  Widgets.hideLoder(context);
                  HelperUtils.showSnackBarMessage(
                      context, state.error.toString());
                }
                if (state is AssignFreePackageInProgress) {
                  Widgets.showLoader(context);
                }
              },
              child: Card(
                color: context.color.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                elevation: 0,
                margin: EdgeInsets.fromLTRB(
                    14,
                    (widget.index == widget.itemIndex) ? 40 : 70,
                    14,
                    (widget.index == widget.itemIndex) ? 100 : 120),
                // (widget.index == widget.itemIndex) ? 120 : 150
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, //temp
                  children: [
                    SizedBox(height: 50.rh(context)),
                    ClipPath(
                      clipper: HexagonClipper(),
                      child: Container(
                        width: 100,
                        height: 110,
                        padding: EdgeInsets.all(30),
                        //alignment: Alignment.center,
                        color: context.color.primaryColor,
                        //TODO: replace url below with model data response
                        child: UiUtils.imageType(widget.model.icon!,
                            fit: BoxFit.contain),
                      ),
                    ),
                    SizedBox(height: 18.rh(context)),
                    widget.model.isActive! && widget.model.price! > 0
                        ? activeAdsData()
                        : adsData(),
                    const Spacer(),
                    Text(widget.model.discountPrice! > 0
                            ? "${Constant.currencySymbol}${widget.model.discountPrice.toString()}"
                            : "free".translate(context))
                        .size(context.font.xxLarge)
                        .bold(),
                    if (widget.model.price! > 0)
                      if (widget.model.discountPrice != null &&
                          widget.model.discountPrice! >
                              0) //TODO: check for discount value here
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${calculateDiscountPercentage(widget.model.price!, widget.model.discountPrice!)}%\t${"OFF".translate(context)}")
                                  .color(context.color.forthColor)
                                  .bold(),
                              SizedBox(width: 5.rh(context)),
                              Text(
                                " ${Constant.currencySymbol}${widget.model.price.toString()}",
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough),
                              )
                            ],
                          ),
                        ),
                    if ((widget.index == widget.itemIndex))
                      // padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                      UiUtils.buildButton(context, onPressed: () {

                        if (Constant.isDemoModeOn) {
                          HelperUtils.showSnackBarMessage(context,
                              "thisActionNotValidDemo".translate(context));
                          return;
                        }
                        if (!widget.model.isActive!) {
                          if (widget.model.price! > 0) {
                            if (Platform.isIOS) {

                              inAppPurchase.buy(widget.model.iosProductId!,
                                  widget.model.id!.toString());
                              return;
                            }
                            context
                                .read<GetPaymentIntentCubit>()
                                .getPaymentIntent(
                                    paymentMethod: "Stripe",
                                    packageId: widget.model.id!);
                          } else {
                            context
                                .read<AssignFreePackageCubit>()
                                .assignFreePackage(packageId: widget.model.id!);
                          }
                        } else {}
                      },
                          radius: 10,
                          height: 46,
                          fontSize: context.font.large,
                          border: widget.model.isActive!
                              ? BorderSide(
                                  color: context.color.textDefaultColor
                                      .withOpacity(0.1))
                              : null,
                          buttonColor: widget.model.isActive!
                              ? context.color.secondaryColor
                              : context.color.territoryColor,
                          textColor: widget.model.isActive!
                              ? context.color.textDefaultColor
                              : context.color.secondaryColor,
                          buttonTitle: widget.model.isActive!
                              ? "yourCurrentPlan".translate(context)
                              : "purchaseThisPackage".translate(context),

                          //TODO: change title to Your Current Plan according to condition
                          outerPadding: const EdgeInsets.all(20))
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget adsData() {
    return Expanded(
      flex: 10,
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(widget.model.name!)
              .centerAlign()
              .copyWith(
                  style: TextStyle(
                color: context.color.textDefaultColor,
                fontWeight: FontWeight.w600,
              ))
              .size(context.font.larger),
          SizedBox(height: 15),
          if (widget.model.type == "item_listing")
            checkmarkPoint(context,
                "${widget.model.limit.toString()}\t${"adsListing".translate(context)}"),
          if (widget.model.type == "advertisement")
            checkmarkPoint(context,
                "${widget.model.limit.toString()}\t${"featuredAdsListing".translate(context)}"),
          checkmarkPoint(context,
              "${widget.model.duration.toString()}\t${"days".translate(context)}"),
          if (widget.model.description != null &&
              widget.model.description != "")
            checkmarkPoint(context, widget.model.description!),
        ],
      ),
    );
  }

  Widget activeAdsData() {
    return Expanded(
      flex: 10,
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(widget.model.name!)
              .copyWith(
                  style: TextStyle(
                      color: context.color.textDefaultColor,
                      fontWeight: FontWeight.w600))
              .size(context.font.larger)
              .centerAlign(),
          SizedBox(height: 15),
          if (widget.model.type == "item_listing")
            checkmarkPoint(context,
                "${widget.model.userPurchasedPackages![0].remainingItemLimit}/${widget.model.limit.toString()}\t${"adsListing".translate(context)}"),
          if (widget.model.type == "advertisement")
            checkmarkPoint(context,
                "${widget.model.userPurchasedPackages![0].remainingItemLimit}/${widget.model.limit.toString()}\t${"featuredAdsListing".translate(context)}"),
          checkmarkPoint(context,
              "${widget.model.userPurchasedPackages![0].remainingDays}/${widget.model.duration.toString()}\t${"days".translate(context)}"),
          if (widget.model.description != null &&
              widget.model.description != "")
            checkmarkPoint(context, widget.model.description!),
        ],
      ),
    );
  }

  SingleChildRenderObjectWidget bottomWidget() {
    if (widget.model.isActive! &&
        widget.model.price! > 0 &&
        widget.model.userPurchasedPackages != null &&
        widget.model.userPurchasedPackages![0].endDate != null) {
      DateTime dateTime =
          DateTime.parse(widget.model.userPurchasedPackages![0].endDate!);
      String formattedDate = intl.DateFormat.yMMMMd().format(dateTime);
      return Padding(
        padding: EdgeInsets.only(
            bottom: 15.0,
            left: 15,
            right: 15), // EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
            "${"yourSubscriptionWillExpireOn".translate(context)} $formattedDate"),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget circlePoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.start,
        // width: context.screenWidth * 0.55,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 2.0),
            child: Icon(
              Icons.circle_rounded,
              size: 8,
            ),
          ),
          //  const Icon(Icons.check_box_rounded, size: 25.0, color: Colors.cyan), //TODO: change it to given icon and fill according to status passed
          SizedBox(width: 15),
          Expanded(
              child: Text(
            text,
            textAlign: TextAlign.start,
          ).color(context.color.textDefaultColor))
        ],
      ),
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // width: context.screenWidth * 0.55,
        children: [
          UiUtils.getSvg(
            AppIcons.active_mark,
            //(boolVariable) ? AppIcons.active_mark : AppIcons.deactive_mark,
          ),
          //  const Icon(Icons.check_box_rounded, size: 25.0, color: Colors.cyan), //TODO: change it to given icon and fill according to status passed
          SizedBox(width: 8.rw(context)),
          Expanded(
              child: Text(
            text,
            textAlign: TextAlign.start,
          ).color(
            context.color.textDefaultColor,
          ))
        ],
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path
      ..moveTo(size.width / 2, 0) // moving to topCenter 1st, then draw the path
      ..lineTo(size.width, size.height * .25)
      ..lineTo(size.width, size.height * .75)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .75)
      ..lineTo(0, size.height * .25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
