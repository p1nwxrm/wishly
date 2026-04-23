part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when the user types in the search bar
class SearchUsers extends SearchEvent {
  final String query;
  final bool isRefresh;

  const SearchUsers({required this.query, this.isRefresh = false});

  @override
  List<Object?> get props => [query];
}

// Event triggered when the user return to SearchScreen
class RefreshSearch extends SearchEvent {
  final String query;

  const RefreshSearch({required this.query});

  @override
  List<Object> get props => [query];
}

// Event to clear search results and return to initial state
class ClearSearch extends SearchEvent {}