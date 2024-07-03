import 'package:flutter/material.dart';

import 'strings.dart';

class Validator {
  static String emailPattern =
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
  static String? validateEmail(String? email) {
    if ((email ??= "").trim().isEmpty) {
      return Strings.emptyEmailMessage;
    } else if (!RegExp(emailPattern).hasMatch(email)) {
      return Strings.invalidEmailMessage;
    } else {
      return null;
    }
  }

  static String? emptyValueValidation(String? value,
      {String? errmsg = Strings.emptyValueMessage}) {
    return (value ??= "").trim().isEmpty ? errmsg : null;
  }

  static String? validatePhoneNumber(String? value) {
    // return null;

    final pattern = RegExp(r"^[0-9]{6,15}$");
    if ((value ??= "").trim().isEmpty) {
      return Strings.invalidPhoneMessage;
    } else if (!pattern.hasMatch(value)) {
      return Strings.invalidPhoneMessage;
    } else {
      return null;
    }
  }

  static String? validateName(String? value,
      {String? errmsg = Strings.emptyValueMessage}) {
    final pattern = RegExp(r'^[a-zA-Z ]+$');
    if ((value ??= "").trim().isEmpty) {
      return errmsg;
    } else if (!pattern.hasMatch(value)) {
      return Strings.invalidNameMessage;
    } else {
      return null;
    }
  }

  static String? nullCheckValidator(String? value, {int? requiredLength}) {
    if (value!.isEmpty) {
      return "Field must not be empty";
    } else if (requiredLength != null) {
      if (value.length < requiredLength) {
        return "Text must be $requiredLength character long";
      } else {
        return null;
      }
    }

    return null;
  }

//byAnish
  static String? validatePassword(String? password,
      {String? secondFieldValue}) {
    if (password!.isEmpty) {
      return "Field must not be empty";
    } else if (password.length < 6) {
      return "Password must be 6 character long";
    }
    if (secondFieldValue != null) {
      if (password != secondFieldValue) {
        return "Both fields must be match";
      }
    }

    return null;
  }
}

class CustomValidator<T> extends FormField<T> {
  CustomValidator(
      {super.key, required FormFieldValidator<T> super.validator,
      required Widget Function(FormFieldState<T> state) builder,
      super.initialValue,
      bool autovalidate = false})
      : super(
          builder: (FormFieldState<T> state) {
            return builder(state);
          },
        );
}
// regex Strings.(.*?)(?=[,|\n|\)|}|'|"|])
