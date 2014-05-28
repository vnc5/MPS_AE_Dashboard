var table = document.getElementById('status-tbody');
var rowTemplate = document.getElementById('row-template');
var statusUrls = {
	on: 'status',
	off: 'status-offline',
	stopped: 'status-away'
};
var ws = new WebSocket('ws://' + location.host);

ws.onopen = function () {
	ws.send(JSON.stringify({
		request: 'getCompleteList'
	}));
};

ws.onmessage = function (e) {
	var json = JSON.parse(e.data);
	console.log(json);
	switch (json.response) {
		case 'completeList':
            clearRows(table);
			var length = json.data.length;
			for (var i = 0; i < length; i++) {
				addRow(table, json.data[i].name, json.data[i]);
			}
			break;
		case 'add':
			addRow(table, json.key, json.data);
			break;
		case 'update':
			updateRow(table, json.key, json.data);
			break;
		case 'remove':
			removeRow(table, json.key);
			break;
	}
};


function clearRows(tbody) {
    while (tbody.rows.length > 0) {
        tbody.deleteRow(0);
    }
}

function addRow(tbody, name, json) {
	var row = rowTemplate.cloneNode(true);
	row.removeAttribute('style');
	row.cells[1].textContent = name;
	tbody.appendChild(row);
	updateRow(tbody, name, json);
}

function removeRow(tbody, name) {
	var rowCount = tbody.rows.length;
	for (var i = 0; i < rowCount; i++) {
		var row = tbody.rows[i];
		if (row.cells[1].textContent == name) {
			tbody.deleteRow(i);
			return;
		}
	}
}

function updateRow(tbody, name, json) {
	var rowCount = tbody.rows.length;
	for (var i = 0; i < rowCount; i++) {
		var row = tbody.rows[i];
		if (row.cells[1].textContent == name) {
			if ('status' in json) {
				row.cells[0].children[0].src = 'img/' + statusUrls[json.status] + '.png';
			}
			if ('uptime' in json) {
				row.cells[2].textContent = json.uptime + '%';
			}
			if ('requests' in json) {
				row.cells[3].textContent = json.requests;
			}
			if ('systemLoad' in json) {
				row.cells[4].textContent = json.systemLoad + '%';
			}
			return;
		}
	}
}

function buttonClick(button, cmd) {
	var name = button.parentNode.parentNode.cells[1].textContent;
	ws.send(JSON.stringify({
		request: cmd,
		key: name
	}));
}

function addInstance(e, form) {
	var value = form.elements[0].value;
	ws.send(JSON.stringify({
		request: 'add',
		key: value
	}));
	form.elements[0].value = "";
	e.preventDefault();
}
