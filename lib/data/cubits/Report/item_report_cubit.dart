
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/report_item_repository.dart';

abstract class ItemReportState {}

class ItemReportInitial extends ItemReportState {}

class ItemReportInProgress extends ItemReportState {}

class ItemReportInSuccess extends ItemReportState {
  final String responseMessage;

  ItemReportInSuccess(this.responseMessage);
}

class ItemReportFailure extends ItemReportState {
  final dynamic error;

  ItemReportFailure(this.error);
}

class ItemReportCubit extends Cubit<ItemReportState> {
  ItemReportCubit() : super(ItemReportInitial());
  ReportItemRepository repository = ReportItemRepository();

  void report({
    required int item_id,
    required int reason_id,
    String? message,
  }) async {
    emit(ItemReportInProgress());

    repository
        .reportItem(reasonId: reason_id, itemId: item_id, message: message)
        .then((value) {

      emit(ItemReportInSuccess(value['message']));
    }).catchError((e) {

      emit(ItemReportFailure(e.toString()));
    });
  }
}
