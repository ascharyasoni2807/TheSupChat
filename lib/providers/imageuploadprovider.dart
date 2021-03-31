 


 import 'package:flutter/cupertino.dart';
import 'package:thegorgeousotp/enum/view_state.dart';

class ImageUploadProvider with ChangeNotifier {



ViewState _viewState = ViewState.IDLE;
ViewState get getViewState => _viewState;

void setToLoading() {
  _viewState = ViewState.Loading;
  notifyListeners();
}

void setToIdle () {

  _viewState = ViewState.IDLE;
  notifyListeners();
}

}