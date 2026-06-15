import '../../../core/domain/json_map.dart';

abstract interface class ModelHttpTransport {
  Future<ModelHttpResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required JsonMap body,
  });
}

final class ModelHttpResponse {
  const ModelHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}
