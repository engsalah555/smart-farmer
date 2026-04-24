import '../../../core/models/post_model.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/constants.dart';

class HomeBatchData {
  final List<PostModel> posts;

  HomeBatchData({required this.posts});
}

class HomeService extends BaseApiService {
  HomeService(super.dio);

  Future<HomeBatchData> getHomeBatchData() async {
    return await get<HomeBatchData>(
          AppConstants.homeDataUrl,
          mapper: (data) {
            final postsJson = data['posts'] as List;

            return HomeBatchData(
              posts: postsJson.map((p) => PostModel.fromJson(p)).toList(),
            );
          },
        ) ??
        HomeBatchData(posts: []);
  }
}
