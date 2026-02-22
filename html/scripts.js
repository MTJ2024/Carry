/* SY_Carry NUI — zero jQuery dependency (vanilla JS only) */

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

/* ── NUI POST helper (no jQuery needed) ── */

function nuiPost(endpoint, data) {
	try {
		var url = 'https://' + GetParentResourceName() + '/' + endpoint;
		fetch(url, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(data || {})
		}).then(function(resp) {
			debug('POST ' + endpoint + ' ok');
		}).catch(function(err) {
			debug('POST ' + endpoint + ' error: ' + err);
		});
	} catch (e) {
		debug('nuiPost exception: ' + e);
	}
}

function closeMenu() {
	closeMain();
	hideAll();
	nuiPost('closetypeselect', {});
	debug('closeMenu done');
}

/* ── NUI message handler (MUST be registered first — before any jQuery code) ── */

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
});

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

/* ── GetParentResourceName polyfill for NUI ── */

if (typeof GetParentResourceName === 'undefined') {
	function GetParentResourceName() { return 'SY_Carry'; }
}

debug('scripts.js loaded OK');