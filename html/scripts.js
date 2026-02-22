/*
    MTJ_Carry — NUI-Script
    (c) 2024 MTJ2024 — Alle Rechte vorbehalten
    Vanilla JS, keine externen Abhaengigkeiten
*/

if (typeof GetParentResourceName === 'undefined') {
	window.GetParentResourceName = function() { return 'MTJ_Carry'; };
}

function debug(msg) {
	console.log('[MTJ_Carry] ' + msg);
}

debug('scripts.js wird geladen...');

/* ── DOM-Helfer ── */

function closeMain() {
	document.body.style.display = 'none';
}

function openMain() {
	document.body.style.display = 'block';
}

function hideAll() {
	var ids = ['carryrequest', 'carrytype'];
	for (var i = 0; i < ids.length; i++) {
		var el = document.getElementById(ids[i]);
		if (el) el.style.display = 'none';
	}
}

function showById(id) {
	var el = document.getElementById(id);
	if (el) el.style.display = '';
}

/* ── NUI POST (XMLHttpRequest fuer CEF-Kompatibilitaet) ── */

function nuiPost(endpoint, data) {
	try {
		var resName = GetParentResourceName();
		var url = 'https://' + resName + '/' + endpoint;
		debug('POST ' + url);
		var xhr = new XMLHttpRequest();
		xhr.open('POST', url, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify(data || {}));
	} catch (e) {
		debug('nuiPost Fehler: ' + e);
	}
}

function closeMenu() {
	closeMain();
	hideAll();
	nuiPost('closetypeselect', {});
	debug('Menue geschlossen');
}

/* ── NUI-Nachrichten-Handler ── */

window.addEventListener('message', function (event) {
	var item = event.data;
	if (!item || !item.message) return;

	debug('NUI Nachricht: ' + item.message);

	if (item.message === 'showcarryrequest') {
		hideAll();
		showById('carryrequest');
		openMain();
	}

	if (item.message === 'showtypes') {
		hideAll();
		showById('carrytype');
		openMain();
	}

	if (item.message === 'hide') {
		closeMain();
		hideAll();
	}

	if (item.message === 'hidecarryrequest') {
		var el = document.getElementById('carryrequest');
		if (el) el.style.display = 'none';
	}

	if (item.message === 'showNotify') {
		showNotify(item.text || '', item.msgtype || 'info', item.duration || 5000);
	}
});

/* ── Benachrichtigungs-System ── */

function showNotify(text, msgtype, duration) {
	debug('Benachrichtigung: ' + msgtype + ' — ' + text);
	var container = document.getElementById('mtj-notify-box');
	if (!container) return;

	var icons = {
		success: '\u2713',
		error: '\u2717',
		info: '\u2139'
	};

	var type = (msgtype === 'success' || msgtype === 'error') ? msgtype : 'info';

	var el = document.createElement('div');
	el.className = 'mtj-toast ' + type;
	el.innerHTML =
		'<div class="mtj-toast-icon">' + (icons[type] || '\u2139') + '</div>' +
		'<div class="mtj-toast-body">' +
			'<div class="mtj-toast-label">TRAGEN</div>' +
			'<div>' + escapeHtml(text) + '</div>' +
		'</div>';

	container.appendChild(el);
	document.body.style.display = 'block';

	setTimeout(function () {
		el.classList.add('hiding');
		setTimeout(function () {
			if (el.parentNode) el.parentNode.removeChild(el);
			if (container.children.length === 0) {
				var anyVisible = false;
				var ids = ['carryrequest', 'carrytype'];
				for (var i = 0; i < ids.length; i++) {
					var panel = document.getElementById(ids[i]);
					if (panel && panel.style.display !== 'none') { anyVisible = true; break; }
				}
				if (!anyVisible) document.body.style.display = 'none';
			}
		}, 300);
	}, duration || 5000);
}

function escapeHtml(str) {
	var div = document.createElement('div');
	div.appendChild(document.createTextNode(str));
	return div.innerHTML;
}

/* ── Klick-Handler ── */

document.addEventListener('DOMContentLoaded', function () {
	debug('DOM bereit — Handler werden angebunden');

	var closeBtn = document.querySelector('.closetypemenu');
	if (closeBtn) {
		closeBtn.addEventListener('click', function () {
			debug('Schliessen geklickt');
			closeMenu();
		});
	}

	var btn1 = document.querySelector('.carry1select');
	if (btn1) {
		btn1.addEventListener('click', function () {
			debug('Typ 1 gewaehlt');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type1' });
		});
	}

	var btn2 = document.querySelector('.carry2select');
	if (btn2) {
		btn2.addEventListener('click', function () {
			debug('Typ 2 gewaehlt');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type2' });
		});
	}

	var btn3 = document.querySelector('.carry3select');
	if (btn3) {
		btn3.addEventListener('click', function () {
			debug('Typ 3 gewaehlt');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type3' });
		});
	}

	document.addEventListener('keyup', function (e) {
		if (e.key === 'Escape') {
			debug('ESC gedrueckt');
			closeMenu();
		}
	});

	debug('Alle Handler angebunden');
});

debug('scripts.js geladen');