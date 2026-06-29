import 'dart:convert';
import 'dart:io';

const openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
const proxyPath = '/.writeller-ai/openrouter/chat/completions';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final port = int.parse(options['port'] ?? '8090');
  final bind = options['bind'] ?? '127.0.0.1';
  final directory = Directory(options['directory'] ?? 'app/build/web');

  if (!directory.existsSync()) {
    stderr.writeln('Web directory not found: ${directory.path}');
    exitCode = 1;
    return;
  }

  final server = await HttpServer.bind(bind, port);
  stdout.writeln('Writeller web server listening on http://$bind:$port');
  stdout.writeln('Serving ${directory.absolute.path}');
  stdout.writeln('Proxying $proxyPath -> $openRouterUrl');

  await for (final request in server) {
    if (request.uri.path == proxyPath) {
      await _handleOpenRouterProxy(request);
    } else {
      await _serveStaticFile(request, directory);
    }
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final parsed = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final arg = args[index];
    if (arg.startsWith('--') && index + 1 < args.length) {
      parsed[arg.substring(2)] = args[index + 1];
      index++;
    }
  }
  return parsed;
}

Future<void> _handleOpenRouterProxy(HttpRequest request) async {
  _addNoCacheHeaders(request.response);

  if (request.method == 'OPTIONS') {
    request.response
      ..statusCode = HttpStatus.noContent
      ..headers.set(
        'Access-Control-Allow-Origin',
        request.headers.value('origin') ?? '*',
      )
      ..headers.set(
        'Access-Control-Allow-Headers',
        'Authorization, X-Api-Key, Content-Type, Accept, HTTP-Referer, X-OpenRouter-Title',
      )
      ..headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    await request.response.close();
    return;
  }

  if (request.method != 'POST') {
    await _sendJson(request.response, HttpStatus.methodNotAllowed, {
      'error': {
        'message': 'Method not allowed',
        'code': HttpStatus.methodNotAllowed,
      },
    });
    return;
  }

  final body = await utf8.encode(await utf8.decoder.bind(request).join());
  final headers = _proxyHeaders(request);
  if (!headers.containsKey(HttpHeaders.authorizationHeader) &&
      !headers.containsKey('X-Api-Key')) {
    await _sendJson(request.response, HttpStatus.unauthorized, {
      'error': {
        'message':
            'Local proxy did not receive provider authentication headers.',
        'code': HttpStatus.unauthorized,
      },
    });
    return;
  }

  final client = HttpClient();
  try {
    final upstreamUri = Uri.parse(openRouterUrl);
    final upstream = await client.postUrl(upstreamUri);
    headers.forEach(upstream.headers.set);
    upstream.add(body);
    final upstreamResponse = await upstream.close();
    final upstreamBody = await upstreamResponse.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );

    request.response.statusCode = upstreamResponse.statusCode;
    request.response.headers
      ..contentType = _contentTypeFrom(upstreamResponse.headers)
      ..set(
        'Access-Control-Allow-Origin',
        request.headers.value('origin') ?? '*',
      );
    request.response.add(upstreamBody);
    await request.response.close();
  } catch (error) {
    await _sendJson(request.response, HttpStatus.badGateway, {
      'error': {
        'message': 'Local proxy failed to reach OpenRouter: $error',
        'code': HttpStatus.badGateway,
      },
    });
  } finally {
    client.close(force: true);
  }
}

Map<String, String> _proxyHeaders(HttpRequest request) {
  final headers = <String, String>{};
  for (final name in [
    HttpHeaders.authorizationHeader,
    'X-Api-Key',
    HttpHeaders.contentTypeHeader,
    HttpHeaders.acceptHeader,
    'HTTP-Referer',
    'X-OpenRouter-Title',
  ]) {
    final value = request.headers.value(name);
    if (value != null && value.isNotEmpty) {
      headers[name] = value;
    }
  }
  headers.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
  headers.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json');
  headers.putIfAbsent(
    'HTTP-Referer',
    () => 'https://github.com/Cmdr-Hawkeye/Writeller',
  );
  headers.putIfAbsent('X-OpenRouter-Title', () => 'Writeller');
  return headers;
}

ContentType _contentTypeFrom(HttpHeaders headers) {
  final value = headers.value(HttpHeaders.contentTypeHeader);
  if (value == null || value.isEmpty) return ContentType.json;
  return ContentType.parse(value);
}

Future<void> _serveStaticFile(HttpRequest request, Directory root) async {
  _addNoCacheHeaders(request.response);
  final requestPath = Uri.decodeComponent(request.uri.path);
  final relativePath = requestPath == '/'
      ? 'index.html'
      : requestPath.substring(1);
  final file = File(
    '${root.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}',
  );
  final resolvedRoot = root.absolute.uri.normalizePath();
  final resolvedFile = file.absolute.uri.normalizePath();

  if (!resolvedFile.toString().startsWith(resolvedRoot.toString())) {
    request.response.statusCode = HttpStatus.forbidden;
    await request.response.close();
    return;
  }

  if (!file.existsSync()) {
    final fallback = File('${root.path}${Platform.pathSeparator}index.html');
    request.response.headers.contentType = ContentType.html;
    await request.response.addStream(fallback.openRead());
    await request.response.close();
    return;
  }

  request.response.headers.contentType = _contentTypeFor(file.path);
  await request.response.addStream(file.openRead());
  await request.response.close();
}

ContentType _contentTypeFor(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js'))
    return ContentType('application', 'javascript', charset: 'utf-8');
  if (path.endsWith('.json')) return ContentType.json;
  if (path.endsWith('.wasm')) return ContentType('application', 'wasm');
  if (path.endsWith('.png')) return ContentType('image', 'png');
  if (path.endsWith('.ico')) return ContentType('image', 'x-icon');
  if (path.endsWith('.css'))
    return ContentType('text', 'css', charset: 'utf-8');
  return ContentType.binary;
}

void _addNoCacheHeaders(HttpResponse response) {
  response.headers.set(HttpHeaders.cacheControlHeader, 'no-store, max-age=0');
}

Future<void> _sendJson(
  HttpResponse response,
  int status,
  Object payload,
) async {
  response
    ..statusCode = status
    ..headers.contentType = ContentType.json;
  response.write(jsonEncode(payload));
  await response.close();
}
