/* SY_Carry NUI — zero external dependencies (vanilla JS + XMLHttpRequest) */

/* ── GetParentResourceName polyfill (must be first — only used outside FiveM for testing) ── */
if (typeof GetParentResourceName === 'undefined') {
	window.GetParentResourceName = function() { return 'SY_Carry'; };
}

function debug(msg) {
	console.log('[SY_Carry] ' + msg);
}

debug('scripts.js loading...');

/* ── DOM helpers ── */

function closeMain() {
	document.body.style.display = 'none';
}

function openMain() {
	document.body.style.display = 'block';
}

function hideAll() {
	var ids = ['carryreceiever', 'carryrequester', 'carryed', 'carrytype'];
	for (var i = 0; i < ids.length; i++) {
		var el = document.getElementById(ids[i]);
		if (el) el.style.display = 'none';
	}
}

function showById(id) {
	var el = document.getElementById(id);
	if (el) el.style.display = '';
}

/* ── NUI POST via XMLHttpRequest (most compatible with FiveM CEF) ── */

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
		debug('nuiPost error: ' + e);
	}
}

function closeMenu() {
	closeMain();
	hideAll();
	nuiPost('closetypeselect', {});
	debug('closeMenu done');
}

/* ── NUI message handler (registered immediately — no dependencies) ── */

window.addEventListener('message', function (event) {
	var item = event.data;
	if (!item || !item.message) return;

	debug('NUI message: ' + item.message);

	if (item.message === 'showcarryrequestreceiever') {
		hideAll();
		showById('carryreceiever');
		openMain();
	}

	if (item.message === 'showcarryrequestrequester') {
		hideAll();
		showById('carryrequester');
		var sec = document.getElementById('secondsremainingrequest');
		if (sec) sec.innerHTML = item.remainingseconds;
		openMain();
	}

	if (item.message === 'showcarryed') {
		hideAll();
		showById('carryed');
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
		var el = document.getElementById('carryreceiever');
		if (el) el.style.display = 'none';
		/* Don't hide body — a notification may follow immediately */
	}

	if (item.message === 'showNotify') {
		showNotify(item.text || '', item.msgtype || 'info', item.duration || 5000);
	}
});

/* ── Built-in Notification System ── */

function showNotify(text, msgtype, duration) {
	debug('showNotify: ' + msgtype + ' — ' + text);
	var container = document.getElementById('notify-container');
	if (!container) return;

	var icons = {
		success: '✓',
		error: '✗',
		info: 'ℹ'
	};

	var type = (msgtype === 'success' || msgtype === 'error') ? msgtype : 'info';

	var el = document.createElement('div');
	el.className = 'carry-notify ' + type;
	el.innerHTML =
		'<div class="carry-notify-icon">' + (icons[type] || 'ℹ') + '</div>' +
		'<div>' +
			'<div class="carry-notify-title">CARRY</div>' +
			'<div class="carry-notify-text">' + escapeHtml(text) + '</div>' +
		'</div>';

	container.appendChild(el);

	/* Body must be visible for notifications to show */
	document.body.style.display = 'block';

	setTimeout(function () {
		el.classList.add('hiding');
		setTimeout(function () {
			if (el.parentNode) el.parentNode.removeChild(el);
			/* Hide body again only if no menu panels are visible and no notifications remain */
			if (container.children.length === 0) {
				var anyVisible = false;
				var ids = ['carryreceiever', 'carryrequester', 'carryed', 'carrytype'];
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

/* ── Click handlers (after DOM ready) ── */

document.addEventListener('DOMContentLoaded', function () {
	debug('DOM ready — attaching click handlers');

	var closeBtn = document.querySelector('.closetypemenu');
	if (closeBtn) {
		closeBtn.addEventListener('click', function () {
			debug('close button clicked');
			closeMenu();
		});
	}

	var btn1 = document.querySelector('.carry1select');
	if (btn1) {
		btn1.addEventListener('click', function () {
			debug('type1 selected');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type1' });
		});
	}

	var btn2 = document.querySelector('.carry2select');
	if (btn2) {
		btn2.addEventListener('click', function () {
			debug('type2 selected');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type2' });
		});
	}

	var btn3 = document.querySelector('.carry3select');
	if (btn3) {
		btn3.addEventListener('click', function () {
			debug('type3 selected');
			closeMain();
			hideAll();
			nuiPost('selecttype', { carrytype: 'type3' });
		});
	}

	document.addEventListener('keyup', function (e) {
		if (e.key === 'Escape') {
			debug('ESC pressed');
			closeMenu();
		}
	});

	debug('All handlers attached OK');
});

debug('scripts.js loaded OK');