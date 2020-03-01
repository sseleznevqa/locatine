async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};

setInterval(async function(){
  document.current = await get_value('locatined');
  document.getElementById('current').innerHTML = JSON.stringify(document.current, undefined, 2);
}, 100);

document.getElementById('add').addEventListener("click", addOptions);
document.getElementById('clear').addEventListener("click", function(){clearOptions(true)});
document.data = {};
document.elementsCount = 0;

function createElement(dom, tag, attrs, inner) {
  const element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

function addOption(what){
  option = createElement(document.getElementById('results-list'),
                                                 "option",
                                                 {"id": what, "value": what},
                                                 what);
  option.addEventListener("click", function(){copyToClipboard(what)});
}

function copyToClipboard(str) {
  const el = document.createElement('textarea');
  el.value = str;
  el.setAttribute('readonly', '');
  el.style.position = 'absolute';
  el.style.left = '-9999px';
  document.body.appendChild(el);
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
  document.getElementById('results-title').innerHTML = str + " is copied to clipboard";
};

async function addOptions() {
  await clearOptions(false);
  if (Object.keys(document.data).length === 0) {
    document.data = document.current;
  } else {
    if (document.data.tag !== document.current.tag) {
      await clearOptions();
      return setTitle("Selected elements were too different (different tags). Selection is dropped.")
    }
    const pairs = document.data.attrs.filter(x => document.current.attrs.filter(y => x == y).length >0);
    document.data.attrs = pairs;
  }
  await populateList();
  document.elementsCount = document.elementsCount +1;
  setTitle(document.elementsCount + " elements were added. You can find them by names below.\nHigher in the list the better");
}

function setTitle(title) {
  document.getElementById('results-title').innerHTML = title;
}

function populateList() {
  document.data.attrs.map(x => addOption(`${x} ${document.data.tag.toLowerCase()}`));
}

async function clearOptions(reload) {
  const list = document.getElementById('results-list');
  while (list.firstChild) {
    list.removeChild(list.lastChild);
  }
  if (reload){
    document.data = {};
    addOption("Nothing here");
    document.elementsCount = 0;
    setTitle("Select and add something!")
  }
}
