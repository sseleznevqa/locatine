async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
}

function allMarks(target) {
  let all = [];
  all = all.concat(getAttributes(target));
  const tag = target.tagName.toLowerCase();
  all = [all[0], tag].concat(all.slice(1));
  all = all.concat(getText(target));
  return all
}

function allPairs(all) {
  let result = []
  for (let i = 0; i < all.length; ++i){
    for (let k = 0; k < all.length; ++k){
      if (k !== i){
        if (all[i].length + all[k].length < 41) {
          result.push([all[i], all[k]])
        }
      }
    }
  }
  return result
}

function getSelected(target){
  let all = allMarks(target);
  let pairs = allPairs(all);
  let page = getPage(target);
  let uniq = [];
  for (let i=0, max=page.length; i < max; i++) {
    uniq = pairs.filter(item => (!page[i].includes(item[0]) && !page[i].includes(item[1])));
  }
  let usual = pairs.filter(item => !uniq.includes(item));
  uniq = uniq.map(item => item.join(" "));
  usual = usual.map(item => item.join(" "));
  set_value('locatined', {'uniq': uniq, 'usual': usual});
}

function getPage(target) {
  let result = [];
  let all = document.getElementsByTagName("*");
  for (let i=0, max=all.length; i < max; i++) {
    if (all[i] != target){
      result.push(allMarks(all[i]));
    }
  }
  return result;
}

function getText(target) {
  let text = "";
  if (target.childNodes){
    for (let i = 0; i < target.childNodes.length; ++i){
      if (target.childNodes[i].nodeType === 3){
        text += target.childNodes[i].textContent;
      }
    }
  } else {
    text = target.textContent;
  }
  return text.split(/[\s\'\\]/).filter(word => word !== "");
}

function sortedAttrs(target) {
  let atts = target.attributes;
  let good = [];
  let other = [];
  if (atts) {
    for (let k = 0, n = atts.length; k < n; k++){
      if ((atts[k].nodeName === 'name') || (atts[k].nodeName === 'id')) {
        good.push(atts[k]);
      } else {
        other.push(atts[k]);
      }
    }
  }
  return good.concat(other);
}

function getAttributes(target) {
  result = [];
  const atts = sortedAttrs(target);
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

function uniqTest(item) {
  return ((document.body.innerHTML.split(item).length - 1) < 2)
}
