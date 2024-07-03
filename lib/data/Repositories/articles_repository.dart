import '../../utils/api.dart';
import '../model/article_model.dart';
import '../model/data_output.dart';

class ArticlesRepository {
  Future<DataOutput<ArticleModel>> fetchArticles({required int page}) async {
    Map<String, dynamic> parameters = {
      Api.page: page,
    };

    Map<String, dynamic> result =
        await Api.get(url: Api.getArticlesApi, queryParameters: parameters);

    List<ArticleModel> modelList = (result['data'] as List)
        .map((element) => ArticleModel.fromJson(element))
        .toList();

    return DataOutput<ArticleModel>(
        total: result['total'] ?? 0, modelList: modelList);
  }
}
