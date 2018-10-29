setTimeout(function wait() {
	var reload = document.querySelector("button.button-toolbar.reload");
	var home = document.querySelector("button.button-toolbar.home");
	var addr = document.querySelector(".toolbar-addressbar");
	if (addr != null) {
		var toolalt = document.createElement('div');
		toolalt.classList.add('toolalt');
		addr.appendChild(toolalt);
		toolalt.appendChild(reload);
	}
	else {
		setTimeout(wait, 300);
	}
}, 300); 
