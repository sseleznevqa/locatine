
function all_elements(){

  const all = document.getElementsByTagName("*");

  const result = [];
  let element = {};
  let attribute = {};
  let atts;

  for (var i=0, max=all.length; i < max; i++) {
    element = {attrs: [], text: "", tag: "", index: ""};
    if (all[i].childNodes) {
      for (let z = 0; z < all[i].childNodes.length; ++z){
        if (all[i].childNodes[z].nodeType === 3){
          element.text += all[i].childNodes[z].textContent;
        }
      }
    } else {
      element.text = all[i].textContent
    }
    element.tag = all[i].tagName.toLowerCase();
    element.index = i;
    atts = all[i].attributes;
    if (atts) {
      for (var att, k = 0, n = atts.length; k < n; k++){
        att = atts[k];
        attribute = {};
        attribute[att.nodeName] = att.nodeValue;
        element.attrs.push(attribute);
      }
    }
    result.push(element);
  }
  return result;
}
let x = all_elements();
return x;
