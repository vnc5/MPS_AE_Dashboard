import 'dart:html';

void main() {
	WebSocket ws = new WebSocket('ws://${window.location.host}');
}