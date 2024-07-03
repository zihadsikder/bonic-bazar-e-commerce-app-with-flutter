import 'package:eClassify/Utils/Network/apiCallTrigger.dart';
import 'package:eClassify/app/register_cubits.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'exports/main_export.dart';

/////////////
///V-1.0.0//
////////////

void main() => initApp();

class EntryPoint extends StatefulWidget {
  const EntryPoint({
    super.key,
  });

  @override
  EntryPointState createState() => EntryPointState();
}

class EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(
        NotificationService.onBackgroundMessageHandler);
    ChatGlobals.init();

  }

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
        providers: RegisterCubits().providers,
        child: Builder(builder: (BuildContext context) {
          return const App();
        }));
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App>{
  @override
  void initState() {
    ///Here Fetching Item report reasons

    context.read<LanguageCubit>().loadCurrentLanguage();
    AppTheme currentTheme = HiveUtils.getCurrentTheme();

    ///Initialized notification services
    LocalAwsomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);

    /// Initialized dynamic links for share items feature
    //DeepLinkManager.initDeepLinks();
    context.read<AppThemeCubit>().changeTheme(currentTheme);

    APICallTrigger.onTrigger(
      () {
        //THIS WILL be CALLED WHEN USER WILL LOGIN FROM ANONYMOUS USER.

        loadInitialData(context, loadWithoutDelay: true);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Continuously watching theme change
    AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;
    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {

      },
      child: BlocListener<GetApiKeysCubit, GetApiKeysState>(
        listener: (context, state) {

          if (state is GetApiKeysSuccess) {


            AppSettings.stripeCurrency = state.stripeCurrency;
            AppSettings.stripePublishableKey = state.stripePublishableKey;
            //AppSettings.stripeSecretKey = state.stripeSecretKey;
          }
        },
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              initialRoute: Routes.splash,
              // App will start from here splash screen is first screen,
              navigatorKey: Constant.navigatorKey,
              //This navigator key is used for Navigate users through notification
              title: Constant.appName,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: Routes.onGenerateRouted,
              theme: appThemeData[currentTheme],
              builder: (context, child) {
                TextDirection direction;
                //here we are languages direction locally
                if (languageState is LanguageLoader) {
                  if (Constant.totalRtlLanguages
                      .contains((languageState).languageCode)) {
                    direction = TextDirection.rtl;
                  } else {
                    direction = TextDirection.ltr;
                  }
                } else {
                  direction = TextDirection.ltr;
                }
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(
                        1.0), //set text scale factor to 1 so that this will not resize app's text while user change their system settings text scale
                  ),
                  child: Directionality(
                    textDirection: direction,
                    //This will convert app direction according to language
                    child: DevicePreview(
                      enabled: false,

                      /// Turn on this if you want to test the app in different screen sizes
                      builder: (context) {
                        return child!;
                      },
                    ),
                  ),
                );
              },
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: loadLocalLanguageIfFail(languageState),
            );
          },
        ),
      ),
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageLoader)) {
      return Locale(state.languageCode);
    } else if (state is LanguageLoadFail) {
      return const Locale("en");
    }
  }
}
