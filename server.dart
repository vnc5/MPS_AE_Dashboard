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

//		Socket.connect('localhost', 2000).then((Socket socket) {
//			monitor = socket;
//			socket
//				.map((str) => JSON.decode(str))
//				.listen((Map json) {
//					clients.forEach((WebSocket client) {
//						client.add(json);
//					});
//				});
//		});
	});
}

void handleWebSocket(WebSocket socket) {
	clients.add(socket);
	socket.listen((str) {
//		monitor.add(str);
		print(str);
	}, onDone: () {
		clients.remove(socket);
	});
}
