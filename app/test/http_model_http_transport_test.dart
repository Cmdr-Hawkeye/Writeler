import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:writeller/core/domain/domain_failure.dart';
import 'package:writeller/features/ai_harness/infrastructure/http_model_http_transport.dart';

void main() {
  test('HTTP transport retries temporary provider failures', () async {
    var attempts = 0;
    final transport = HttpModelHttpTransport(
      client: MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          return http.Response('temporarily unavailable', 503);
        }
        return http.Response('{"ok": true}', 200);
      }),
      retryDelay: Duration.zero,
    );

    final response = await transport.postJson(
      uri: Uri.parse('https://example.test/v1/chat/completions'),
      headers: const {'content-type': 'application/json'},
      body: const {'model': 'test'},
    );

    expect(attempts, 2);
    expect(response.statusCode, 200);
  });

  test('HTTP transport turns timeouts into domain failures', () async {
    final transport = HttpModelHttpTransport(
      client: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('late', 200);
      }),
      timeout: const Duration(milliseconds: 1),
      maxAttempts: 1,
    );

    expect(
      () => transport.postJson(
        uri: Uri.parse('https://example.test/v1/chat/completions'),
        headers: const {'content-type': 'application/json'},
        body: const {'model': 'test'},
      ),
      throwsA(isA<DomainFailure>()),
    );
  });
}
