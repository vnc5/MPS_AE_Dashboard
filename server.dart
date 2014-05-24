import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart';

final indexFile = new File(r'web\index.html');
final virDir = new VirtualDirectory('web');

void main() {
	runZoned(() {
		HttpServer.bind(InternetAddress.ANY_IP_V4, 80).then((HttpServer server) {
			server.listen((HttpRequest req) {
				if (WebSocketTransformer.isUpgradeRequest(req)) {
					WebSocketTransformer.upgrade(req).then(handleWebSocket);
				} else {
					virDir.serveRequest(req);
				}
			});
			virDir.errorPageHandler = (HttpRequest req) {
				req.response.statusCode = HttpStatus.OK;
				virDir.serveFile(indexFile, req);
			};
		});
	}, onError: print);
}

void handleWebSocket(WebSocket socket) {

}
