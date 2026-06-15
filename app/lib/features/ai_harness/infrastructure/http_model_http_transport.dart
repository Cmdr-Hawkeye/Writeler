import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/domain/domain_failure.dart';
import '../../../core/domain/json_map.dart';
import '../domain/model_http_transport.dart';

final class HttpModelHttpTransport implements ModelHttpTransport {
  const HttpModelHttpTransport({
    this.client,
    this.timeout = const Duration(seconds: 45),
    this.maxAttempts = 3,
    this.retryDelay = const Duration(milliseconds: 450),
  });

  final http.Client? client;
  final Duration timeout;
  final int maxAttempts;
  final Duration retryDelay;

  @override
  Future<ModelHttpResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required JsonMap body,
  }) async {
    final attempts = maxAttempts < 1 ? 1 : maxAttempts;
    Object? lastError;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        final response =
            await _post(uri, headers: headers, body: jsonEncode(body))
                .timeout(timeout);
        final result = ModelHttpResponse(
          statusCode: response.statusCode,
          body: response.body,
        );
        if (!_shouldRetryStatus(response.statusCode) || attempt == attempts) {
          return result;
        }
      } on TimeoutException catch (error) {
        lastError = error;
        if (attempt == attempts) break;
      } on http.ClientException catch (error) {
        lastError = error;
        if (attempt == attempts) break;
      }

      await Future<void>.delayed(retryDelay * attempt);
    }

    if (lastError is TimeoutException) {
      throw DomainFailure(
          'Provider request timed out after ${timeout.inSeconds} seconds.');
    }
    throw DomainFailure('Provider request failed: $lastError');
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  Future<http.Response> _post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) {
    final client = this.client;
    if (client != null) {
      return client.post(uri, headers: headers, body: body);
    }
    return http.post(uri, headers: headers, body: body);
  }
}
