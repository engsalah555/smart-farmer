class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.data,
    required this.meta,
  });

  int get currentPage => meta.currentPage;
  int get lastPage => meta.lastPage;
  bool get hasNextPage => meta.hasMore;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) mapper,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((i) => mapper(i)).toList(),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }

  static PaginatedResponse<T> empty<T>({int perPage = 10}) {
    return PaginatedResponse(
      data: [],
      meta: PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: perPage,
        total: 0,
      ),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}

