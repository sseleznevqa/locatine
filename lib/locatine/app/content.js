async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
};

async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};

async function creatingDiv(){
  const options = {
    "id":"locatine_magic_div",
    "locatinestyle": await get_value('magic_div') || "false",
    "locatinetitle": "ok",
    "locatinehint": "ok",
    "locatine_name": ""
  };
  locatine_create_element(document.body, "div", options, "");
  const magic_cover = document.getElementById('locatine_magic_div');
  magic_cover.onclick = function(e) {locatine_magic_click(e)};
  await set_value('locatine_confirm', 'new')
  document.body.onkeypress = async function(e) {
    if (e.which == 13) {
      await set_value('locatine_confirm', true)
    }
  }
}

async function setStyle(style, magicDiv){
  if (style === "set_true") {
    await set_value('magic_div', true);
    magicDiv.setAttribute("locatinestyle", "true");
  };
  if (style === "set_false") {
    await set_value('magic_div', false);
    magicDiv.setAttribute("locatinestyle", "false");
  };
  let status = await get_value('magic_div');
  magicDiv.setAttribute("locatinestyle", status);
}

async function setTitleHint(magicDiv){
  if (magicDiv.getAttribute("locatinetitle") != "ok") {
    await set_value('locatine_title', magicDiv.getAttribute("locatinetitle"));
    await set_value('locatine_hint', magicDiv.getAttribute("locatinehint"));
    magicDiv.setAttribute("locatinetitle", "ok");
    let op = 1;
    magicDiv.innerHTML = await get_value("locatine_title");
    let timer = setInterval(function () {
      if ((magicDiv.style.opacity == 1) && (op < 0.97)) {
        clearInterval(timer);// If other process changed opacity.
      };
      if (op <= 0.2) {
        clearInterval(timer);
        magicDiv.style.opacity = 0;
        magicDiv.innerHTML = "";
      }
      magicDiv.style.opacity = op;
      magicDiv.style.filter = 'alpha(opacity=' + op * 100 + ")";
      op -= op * 0.03;
    }, 50);
  }
}

async function setConfirm(magicDiv) {
  if (magicDiv.getAttribute("locatineconfirmed") === "ok") {
    magicDiv.removeAttribute("tag");
    magicDiv.removeAttribute("index");
    await set_value("locatine_confirm", false);
  }

  const confirmed = await get_value('locatine_confirm');
  magicDiv.setAttribute("locatineconfirmed", confirmed);
}

async function setName(magicDiv) {
  const selectionName = magicDiv.getAttribute("locatine_name");
  const nameMark = magicDiv.getAttribute("locatine_name_mark");
  if (nameMark != "true") {
    magicDiv.setAttribute("locatine_name", await get_value("locatineName"));
  }
  if ((selectionName != "") && (nameMark == "true")){
    await set_value("locatineName", selectionName);
    magicDiv.setAttribute("locatine_name_mark", "");
  }
}

async function refreshData(){
  const magicDiv = document.getElementById("locatine_magic_div");
  if (!document.getElementById("locatine_magic_div")){
    creatingDiv();
    set_value("locatineName", "");
  } else {
    setStyle(magicDiv.getAttribute("locatinestyle"), magicDiv);
    setTitleHint(magicDiv);
    setName(magicDiv);
    magicDiv.setAttribute("locatinecollection", await get_value("locatine_collection"));
    setConfirm(magicDiv);
  };
};

async function getSelected(value){
  if (value) {
    const magic_div = document.getElementById("locatine_magic_div");
    const tagName = value.tagName;
    const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
    const index = array.indexOf(value);
    if ((document.locatine_selected !=  value) && (String(tagName) != "")) {
      document.locatine_selected = value;
      await set_value("locatine_confirm", "selected");
      magic_div.setAttribute("tag", tagName);
      magic_div.setAttribute("index", index);
    }
  }
};

async function locatine_magic_click(e) {
  document.getElementById("locatine_magic_div").setAttribute("locatinestyle", "blocked");
  const value = document.elementFromPoint(e.clientX, e.clientY);
  document.getElementById("locatine_magic_div").setAttribute("locatinestyle", "true");
  const tagName = value.tagName;
  const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
  const index = array.indexOf(value);
  await set_value("locatine_confirm", "selected");
  document.getElementById("locatine_magic_div").setAttribute("tag", tagName);
  document.getElementById("locatine_magic_div").setAttribute("index", index);
};

function locatine_create_element(dom, tag, attrs, inner) {
  const element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

setInterval(async function(){
  if (document.getElementById("locatine_magic_div")) {
    if (document.getElementById("locatine_magic_div").getAttribute("locatinestyle") != "blocked") {
      await refreshData()
    }
  } else {
    await refreshData()
  }
}, 100);
