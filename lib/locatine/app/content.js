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
    "locatinehint": "ok"
  };
  locatine_create_element(document.body, "div", options, "");
  const magic_cover = document.getElementById('locatine_magic_div');
  magic_cover.onclick = function(e) {locatine_magic_click(e)};
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

async function refreshData(){
  const magicDiv = document.getElementById("locatine_magic_div");
  if (!document.getElementById("locatine_magic_div")){
    creatingDiv();
  } else {
    setStyle(magicDiv.getAttribute("locatinestyle"), magicDiv);
    setTitleHint(magicDiv);
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
