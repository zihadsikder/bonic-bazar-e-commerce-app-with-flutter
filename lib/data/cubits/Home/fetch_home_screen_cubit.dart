import 'package:eClassify/data/Repositories/Home/home_repository.dart';
import 'package:eClassify/data/model/Home/home_screen_section.dart';

import '../../../exports/main_export.dart';

abstract class FetchHomeScreenState {}

class FetchHomeScreenInitial extends FetchHomeScreenState {}

class FetchHomeScreenInProgress extends FetchHomeScreenState {}

class FetchHomeScreenSuccess extends FetchHomeScreenState {
  final List<HomeScreenSection> sections;

  FetchHomeScreenSuccess(this.sections);
}

class FetchHomeScreenFail extends FetchHomeScreenState {
  final dynamic error;

  FetchHomeScreenFail(this.error);
}

class FetchHomeScreenCubit extends Cubit<FetchHomeScreenState> {
  FetchHomeScreenCubit() : super(FetchHomeScreenInitial());

  final HomeRepository _homeRepository = HomeRepository();

  fetch({String? city}) async {
    try {
      emit(FetchHomeScreenInProgress());
      List<HomeScreenSection> homeScreenDataList =
          await _homeRepository.fetchHome(city: city);

      emit(FetchHomeScreenSuccess(homeScreenDataList));
    } catch (e) {
      emit(FetchHomeScreenFail(e));
    }
  }
}
