// ignore_for_file: deprecated_member_use

import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final appThemeData = {
  AppTheme.light: ThemeData(
    // scaffoldBackgroundColor: pageBackgroundColor,
    brightness: Brightness.light,
    //textTheme
    useMaterial3: false,
    fontFamily: "Manrope",
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: territoryColor_,
      cursorColor: territoryColor_,
      selectionHandleColor: territoryColor_,
    ),
    cardColor: errorMessageColor,
    switchTheme: SwitchThemeData(
      thumbColor: const MaterialStatePropertyAll(territoryColor_),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return territoryColor_.withOpacity(0.3);
        }
        return primaryColorDark;
      }),
    ),
  ),
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    fontFamily: "Manrope",
    cardColor: errorMessageColor.withOpacity(0.7),
    textSelectionTheme:
        const TextSelectionThemeData(selectionHandleColor: territoryColorDark,selectionColor: territoryColorDark,
          cursorColor: territoryColorDark,),
    switchTheme: SwitchThemeData(
        thumbColor: const MaterialStatePropertyAll(territoryColor_),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return territoryColor_.withOpacity(0.3);
          }
          return primaryColor_.withOpacity(0.2);
        })),
  )
};
