async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};

async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
};

async function correct_buttons() {
  if (await get_value("magic_div") === true) {
    document.getElementById("watchSwitch").setAttribute("value", "Locatine is waiting for click");
  } else {
    document.getElementById("watchSwitch").setAttribute("value", "Locatine is not waiting now");
  };
  if (await get_value("locatine_collection") === true) {
    document.getElementById("mode").setAttribute("value", "You are in collection mode")
  } else {
    document.getElementById("mode").setAttribute("value", "You are in single selection mode")
  };
  document.getElementById("mainTitle").innerText = await get_value("locatine_title");
  document.getElementById("hint").innerText = await get_value("locatine_hint");
  if ((document.getElementById("nameHandler").value != await get_value("locatineName")) && (!document.hasFocus())){
    document.getElementById("nameHandler").value = (await get_value("locatineName") || "");
  }
}

async function watch() {
  await set_value("magic_div", !(await get_value("magic_div")));
}

function clear() {
  set_value("locatine_confirm", "declined");
}

function confirm() {
  set_value("locatine_confirm", true);
}

function abort() {
  set_value("locatine_confirm", 'abort');
}

async function mode() {
  await set_value("locatine_collection", !(await get_value("locatine_collection")));
}

async function doName() {
  await set_value("locatineName", document.getElementById("nameHandler").value);
}

document.getElementById("watchSwitch").onclick = function() {watch()};
document.getElementById("clearMark").onclick = function() {clear()};
document.getElementById("confirm").onclick = function() {confirm()};
document.getElementById("mode").onclick = function() {mode()};
document.getElementById("abort").onclick = function() {abort()};
document.getElementById("nameHandler").oninput = function() {doName()};

setInterval(function(){
  correct_buttons();
}, 100);
