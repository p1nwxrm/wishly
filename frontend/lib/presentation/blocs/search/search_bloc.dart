import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../core/api/api_error_parser.dart';
import '../../../data/models/user_subscription_models.dart';
import '../../../data/repositories/user_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final UserRepository _userRepository;
  final Talker _talker;

  SearchBloc(this._userRepository, this._talker) : super(SearchInitial()) {
    // We use transformer to debounce search requests and avoid spamming the server
    on<SearchUsers>(
      _onSearchUsers,
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
    on<RefreshSearch>(_onRefreshSearch);
    on<ClearSearch>((event, emit) => emit(SearchInitial()));
  }

  Future<void> _onSearchUsers(
      SearchUsers event,
      Emitter<SearchState> emit,
      ) async {
    // Backend requires at least 2 characters
    if (event.query.length < 2) {
      emit(SearchInitial());
      return;
    }

    if (!event.isRefresh) {
      emit(SearchLoading());
    }

    await _fetchUsers(event.query, emit);
  }

  Future<void> _onRefreshSearch(RefreshSearch event, Emitter<SearchState> emit) async {
    if (event.query.length < 2) return;
    await _fetchUsers(event.query, emit);
  }

  Future<void> _fetchUsers(String query, Emitter<SearchState> emit) async {
    try {
      final users = await _userRepository.searchUsers(query);
      emit(SearchLoaded(users: users));
    } on DioException catch (e, st) {
      _talker.handle(e, st);
      final errorMsg = ApiErrorParser.extractMessage(e);
      emit(SearchError(message: errorMsg));
    } catch (e, st) {
      _talker.handle(e, st);
      emit(const SearchError(message: 'An unexpected error occurred during search.'));
    }
  }
}