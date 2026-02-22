function closeMain() {
	$("body").css("display", "none");
}
function openMain() {
	$("body").css("display", "block");
}

function hideAll() {
	$('#carryreceiever').hide();
	$('#carryrequester').hide();
	$('#carryed').hide();
	$('#carrytype').hide();
}

$(".closetypemenu").click(function(){
    $.post('http://SY_Carry/closetypeselect', JSON.stringify({}));
});

window.addEventListener('message', function (event) {

	var item = event.data;

	if (item.message == "showcarryrequestreceiever") {
		hideAll();
		$('#carryreceiever').show();
		openMain();
	}

	if (item.message == "showcarryrequestrequester") {
		hideAll();
		$('#carryrequester').show();
		document.getElementById("secondsremainingrequest").innerHTML = item.remainingseconds;
		openMain();
	}

	if (item.message == "showcarryed") {
		hideAll();
		$('#carryed').show();
		openMain();
	}

	if (item.message == "showtypes") {
		hideAll();
		$('#carrytype').show();
		openMain();
	}

	if (item.message == "hide") {
		closeMain();
		hideAll();
	}
});

$(".carry1select").click(function () {
	closeMain();
	hideAll();
	$.post('http://SY_Carry/selecttype', JSON.stringify({
		carrytype: "type1"
	}));
});

$(".carry2select").click(function () {
	closeMain();
	hideAll();
	$.post('http://SY_Carry/selecttype', JSON.stringify({
		carrytype: "type2"
	}));
});

$(".carry3select").click(function () {
	closeMain();
	hideAll();
	$.post('http://SY_Carry/selecttype', JSON.stringify({
		carrytype: "type3"
	}));
});