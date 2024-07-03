import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../Widgets/AnimatedRoutes/blur_page_route.dart';

class SuccessItemScreen extends StatefulWidget {
  final ItemModel model;

  const SuccessItemScreen({super.key, required this.model});

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SuccessItemScreen(model: arguments!['model']);
      },
    );
  }

  @override
  _SuccessItemScreenState createState() => _SuccessItemScreenState();
}

class _SuccessItemScreenState extends State<SuccessItemScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccessShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust duration as needed
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1.5), // Off-screen initially
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Simulate loading time
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
      // Show success animation after loading animation completes
      Future.delayed(const Duration(seconds: 0), () {
        setState(() {
          _isSuccessShown = true;
          Future.delayed(const Duration(seconds: 1), () {
            _slideController.forward();
          }); // Start slide animation
        });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? Lottie.asset(
                "assets/lottie/${Constant.loadingSuccessLottieFile}") // Replace with your loading animation
            : _isSuccessShown
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                          "assets/lottie/${Constant.successItemLottieFile}"),
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Text(
                              'congratulations'.translate(context),
                            )
                                .size(context.font.extraLarge)
                                .color(context.color.territoryColor)
                                .bold(weight: FontWeight.w600),
                            SizedBox(height: 18),
                             Text('submittedSuccess'.translate(context))
                                .centerAlign()
                                .size(context.font.larger)
                                .color(context.color.textDefaultColor),
                            SizedBox(height: 60),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.adDetailsScreen,
                                  arguments: {
                                    'model': widget.model,
                                  },
                                );
                                //pageCntrlr.jumpToPage(3);
                                /*  Navigator.pushReplacementNamed(
                                  context,
                                  Routes.main,
                                  arguments: {"from": "successItem"},
                                ).then((_) {
                                  context
                                      .read<NavigationCubit>()
                                      .navigateToMyItems();
                                });*/
                                /*  Navigator.pushNamed(
                                  context,
                                  Routes.myItemScreen,
                                );*/
                              },
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 65, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: context.color.territoryColor),
                                    color: context.color.secondaryColor),
                                child: Text("previewAd".translate(context))
                                    .centerAlign()
                                    .size(context.font.larger)
                                    .color(context.color.territoryColor),
                              ),
                            ),
                            SizedBox(height: 15),
                            InkWell(
                              onTap: () {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                              child: Text('backToHome'.translate(context))
                                  .underline()
                                  .centerAlign()
                                  .size(context.font.larger)
                                  .color(context.color.textDefaultColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox(), // Placeholder
      ),
    );
  }
}
