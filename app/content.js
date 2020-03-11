async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
}

function getSelected(target) {
  let attrs =  getAttributes(target);
  const page = getPage();
  attrs.sort(function(a, b) {
    return weight(a, page) - weight(b, page);
  });
  if (weight(attrs[0], page)>1) {
    let temp = [];
    for (let k = 1, n = attrs.length; k < n; k++) {
      temp.push([`${attrs[0]} ${attrs[k]}`])
    }
    attrs = temp.concat(attrs);
  }
  let data = {"attrs": attrs, "tag": target.tagName};
  set_value('locatined', data)
  return true;
}

function getAttributes(target) {
  result = [];
  const atts = target.attributes;;
  if (atts) {
    for (let k = 0, n = atts.length; k < n; k++){
      att = atts[k];
      att_array = att.nodeValue.split(/[\s\'\\]/).filter(word => word !== "");
      for (let i = 0; i < att_array.length; ++i){
        result.push(att_array[i]);
      }
    }
  }
  return result;
}

function weight(attr, page) {
  return page.filter((v) => (v.toLowerCase() === attr.toLowerCase())).length;
}

function getPage() {
  let result = [];
  let temp;
  let all = document.getElementsByTagName("*");
  for (let i=0, max=all.length; i < max; i++) {
    result = result.concat(getAttributes(all[i]));
  }
  return result;
}
