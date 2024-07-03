/*
// ignore_for_file: file_names

// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/chat_repository.dart';
import '../../Repositories/favourites_repository.dart';
import '../../model/item/item_model.dart';

abstract class UpdateMakeAnOfferState {}

class UpdateMakeAnOfferInitial extends UpdateMakeAnOfferState {}

class UpdateMakeAnOfferInProgress extends UpdateMakeAnOfferState {}

class UpdateMakeAnOfferSuccess extends UpdateMakeAnOfferState {
  final ItemModel item;
  final bool wasProcess; //to check that process of MakeAnOffer done or not
  UpdateMakeAnOfferSuccess(this.item, this.wasProcess);
}

class UpdateMakeAnOfferFailure extends UpdateMakeAnOfferState {
  final String errorMessage;

  UpdateMakeAnOfferFailure(this.errorMessage);
}

class UpdateMakeAnOfferCubit extends Cubit<UpdateMakeAnOfferState> {
  final ChatRepostiory makeAnOfferRepository;

  UpdateMakeAnOfferCubit(this.makeAnOfferRepository) : super(UpdateMakeAnOfferInitial());

  void setMakeAnOfferItem({required ItemModel item, required int type}) {
    emit(UpdateMakeAnOfferInProgress());
    makeAnOfferRepository.manageMakeAnOffers(item.id!).then((value) {
      emit(UpdateMakeAnOfferSuccess(item, type == 1 ? true : false));
    }).catchError((e) {
      emit(UpdateMakeAnOfferFailure(e.toString()));
    });
  }
}
*/
