import 'package:flutter/foundation.dart';

/// Standardized pagination state for lists
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final bool hasNext;
  final bool isLoading;
  final String? error;

  PaginationState({
    this.items = const [],
    this.currentPage = 1,
    this.hasNext = true,
    this.isLoading = false,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    bool? hasNext,
    bool? isLoading,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get canLoadMore => hasNext && !isLoading;
}

/// Mixin to handle pagination logic in Providers
mixin PaginationMixin on ChangeNotifier {
  /// Updates a pagination state with new data
  PaginationState<T> updateState<T>({
    required PaginationState<T> currentState,
    required List<T> newItems,
    required bool isRefresh,
    bool? hasNext,
  }) {
    final updatedItems = isRefresh ? newItems : [...currentState.items, ...newItems];
    
    return currentState.copyWith(
      items: updatedItems,
      currentPage: isRefresh ? 2 : currentState.currentPage + 1,
      hasNext: hasNext ?? newItems.isNotEmpty,
      isLoading: false,
      error: null,
    );
  }

  /// Sets loading state for a specific pagination
  PaginationState<T> setPaginationLoading<T>(PaginationState<T> state, bool loading) {
    return state.copyWith(isLoading: loading);
  }

  /// Sets error state for a specific pagination
  PaginationState<T> setPaginationError<T>(PaginationState<T> state, String? error) {
    return state.copyWith(error: error, isLoading: false);
  }
}
