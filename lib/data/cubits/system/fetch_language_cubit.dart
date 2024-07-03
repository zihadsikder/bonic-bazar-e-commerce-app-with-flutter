// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eClassify/Utils/api.dart';

abstract class FetchLanguageState {}

class FetchLanguageInitial extends FetchLanguageState {}

class FetchLanguageInProgress extends FetchLanguageState {}

class FetchLanguageSuccess extends FetchLanguageState {
  final String code;
  final String name;
  final String image;
  final Map data;
  FetchLanguageSuccess( {
    required this.code,
    required this.name,
    required this.data,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'file_name': data,
    };
  }

  factory FetchLanguageSuccess.fromMap(Map<String, dynamic> map) {
    return FetchLanguageSuccess(
      code: map['code'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      data: map['file_name'] as Map,
    );
  }
}

class FetchLanguageFailure extends FetchLanguageState {
  final String errorMessage;

  FetchLanguageFailure(this.errorMessage);
}

class FetchLanguageCubit extends Cubit<FetchLanguageState> {
  FetchLanguageCubit() : super(FetchLanguageInitial());

  Future<void> getLanguage(String languageCode) async {
    try {
      emit(FetchLanguageInProgress());

      Map<String, dynamic> response = await Api.get(
          url: Api.getLanguageApi,
          queryParameters: {Api.languageCode: languageCode},
          );

      emit(FetchLanguageSuccess(
          code: response['data']['code'],
          image: response['data']['image'],
          data: response['data']['file_name'],
          name: response['data']['name']));
    } catch (e) {
      emit(FetchLanguageFailure(e.toString()));
    }
  }
}
