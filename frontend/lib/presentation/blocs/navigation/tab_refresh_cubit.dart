import 'package:flutter_bloc/flutter_bloc.dart';

class TabRefreshCubit extends Cubit<int?> {
  TabRefreshCubit() : super(null);

  void refreshTab(int index) {
    emit(index);
    emit(null);
  }
}