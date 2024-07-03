// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eClassify/Ui/screens/widgets/Errors/no_internet.dart';
import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/Repositories/system_repository.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/model/system_settings_model.dart';

// import 'package:eClassify/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/cubits/system/language_cubit.dart';

import '../../exports/main_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  //late OldAuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false; //TODO: temp
  bool isLanguageLoaded = false;

  @override
  void initState() {
    locationPermission();
    super.initState();

    getDefaultLanguage();
    // GuestChecker.setContext(context);

    checkIsUserAuthenticated();
    // bool isDataAvailable = checkPersistedDataAvailibility();
    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return NoInternet(
              onRetry: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.splash,
                );
              },
            );
          },
        ));
      } else {
        startTimer();
      }
    });

    //get Currency Symbol from Admin Panel
/*    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            Api.currencySymbol,
          );
    });*/
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  Future getDefaultLanguage() async {
    try {
      if (HiveUtils.getLanguage() == null ||
          HiveUtils.getLanguage()?['data'] == null) {
        Map result =
            await SystemRepository().fetchSystemSettings(isAnonymouse: true);

        var code = (result['data']['default_language']);
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else {
        isLanguageLoaded = true;
        setState(() {});
      }
    } catch (e) {
      log("Error while load default language $e");
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void checkIsUserAuthenticated() async {
    if (HiveUtils.isUserAuthenticated() == true) {
      context
          .read<FetchSystemSettingsCubit>()
          .fetchSettings(isAnonymouse: false, forceRefresh: true);
    } else {
      context
          .read<FetchSystemSettingsCubit>()
          .fetchSettings(isAnonymouse: true, forceRefresh: true);
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 1), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    if (isTimerCompleted || isSettingsLoaded || isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void navigateToScreen() {

    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime() == true) {

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      if (HiveUtils.getUserDetails().name == "" ||
          HiveUtils.getUserDetails().email == "" ||
          HiveUtils.getUserDetails().mobile == "") {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {
                "from": "login",
              },
            );
          },
        );
      } else {

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context)
                .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
          }
        });
      }
    } else {

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {
        if (state is FetchLanguageSuccess) {
          Map<String, dynamic> map = state.toMap();
          var data = map['file_name'];
          map['data'] = data;
          map.remove("file_name");

          HiveUtils.storeLanguage(map);
          context.read<LanguageCubit>().emit(LanguageLoader(state.code));
          isLanguageLoaded = true;
          if (mounted) {
            setState(() {});
          }
        }
      },
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsSuccess) {
            /*if (state.settings['data'].containsKey("demo_mode")) {
              Constant.isDemoModeOn = state.settings['data']['demo_mode'];
            }*/

            Constant.isDemoModeOn = context
                .read<FetchSystemSettingsCubit>()
                .getSetting(SystemSetting.demoMode);

            isSettingsLoaded = true;
            setState(() {});
          }
          if (state is FetchSystemSettingsFailure) {}
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: context.color.territoryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.territoryColor,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: UiUtils.getSvg(AppIcons.companyLogo),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0.rh(context)),
                    child: SizedBox(
                      width: 150.rw(context),
                      height: 150.rh(context),
                      child: UiUtils.getSvg(AppIcons.splashLogo),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0.rh(context)),
                  child: Column(
                    children: [
                      Text("BonikBazar".translate(context))
                          .size(context.font.xxLarge)
                          .color(context.color.secondaryColor)
                          .centerAlign()
                          .bold(weight: FontWeight.w600),
                      Text("\"${"E-Commerce App".translate(context)}\"")
                          .size(context.font.smaller)
                          .color(context.color.secondaryColor)
                          .centerAlign(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
