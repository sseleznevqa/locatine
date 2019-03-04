async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
};

async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};

document.addEventListener("locatine_send", async function(e) {
  await set_value(e.detail.varname, e.detail.varvalue);
});

async function refreshData(){
  if (!document.getElementById("locatine_magic_div")){
    const options = {
      "locatineclass": "locatine_smthing",
      "id":"locatine_magic_div",
      "locatinestyle": await get_value('magic_div') || "false",
      "locatinetitle": "ok",
      "locatinehint": "ok"
    };
    locatine_create_element(document.body, "div", options, "");
  } else {
    const magicDiv = document.getElementById("locatine_magic_div");
    if (magicDiv.getAttribute("locatinestyle") === "set_true") {
      await set_value('magic_div', true);
    };
    if (magicDiv.getAttribute("locatinetitle") != "ok") {
      await set_value('locatine_title', magicDiv.getAttribute("locatinetitle"));
      await set_value('locatine_hint', magicDiv.getAttribute("locatinehint"));
      magicDiv.setAttribute("locatinetitle", "ok")
    }
    let status = await get_value('magic_div');
    magicDiv.setAttribute("locatinestyle", status);
    magicDiv.setAttribute("locatinecollection", await get_value("locatine_collection"))
    if (magicDiv.getAttribute("locatineconfirmed") === "ok") {
      magicDiv.removeAttribute("tag");
      magicDiv.removeAttribute("index");
      await set_value("locatine_confirm", false);
      await set_value('magic_div', false);
    }
    const confirmed = await get_value('locatine_confirm');
    magicDiv.setAttribute("locatineconfirmed", confirmed);
  };
  const magic_cover = document.getElementById('locatine_magic_div');
  magic_cover.onclick = function(e) {locatine_magic_click(e)};
};

function getSelected(value){
  const tagName = value.tagName;
  const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
  const index = array.indexOf(value);
  document.getElementById("locatine_magic_div").setAttribute("tag", tagName);
  document.getElementById("locatine_magic_div").setAttribute("index", index);
};

function locatine_magic_click(e) {
  document.getElementById("locatine_magic_div").setAttribute("locatinestyle", "blocked");
  const value = document.elementFromPoint(e.clientX, e.clientY);
  document.getElementById("locatine_magic_div").setAttribute("locatinestyle", "true");
  const tagName = value.tagName;
  const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
  const index = array.indexOf(value);
  document.getElementById("locatine_magic_div").setAttribute("TAG", tagName);
  document.getElementById("locatine_magic_div").setAttribute("INDEX", index);
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

set_value('magic_div','off');

setInterval(async function(){
  if (document.getElementById("locatine_magic_div")) {
    if (document.getElementById("locatine_magic_div").getAttribute("locatinestyle") != "blocked") {
      await refreshData()
    }
  } else {
    await refreshData()
  }
}, 100);
