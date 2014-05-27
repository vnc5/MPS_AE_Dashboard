import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart';

final indexFile = new File(r'web\index.html');
final virDir = new VirtualDirectory('web');
final Set<WebSocket> clients = new Set<WebSocket>();
Socket monitor;

void main() {
	runZoned(() {
		HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 80).then((HttpServer server) {
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

		Socket.connect('localhost', 1338).then((Socket socket) {
			monitor = socket;
			socket
				.transform(UTF8.decoder)
				.transform(new LineSplitter())
				.listen((line) {
					if (clients.isNotEmpty) {
						clients.first.add(line);
					}
					// Concurrent modification during iteration
					// WHYYYYY?
//					clients.forEach((WebSocket client) {
//						client.add(json);
//					});
				});
		});
	});
}

void handleWebSocket(WebSocket socket) {
	clients.add(socket);
	socket.listen((str) {
		monitor.write(str + '\n');
		print(str);
	}, onDone: () {
		clients.remove(socket);
	});
}
