
function one_element(target){

  let element = {};
  let attribute = {};

  element = {attrs: [], text: "", tag: ""};
  if (target.childNodes){
    for (let i = 0; i < target.childNodes.length; ++i){
      if (target.childNodes[i].nodeType === 3){
        element.text += target.childNodes[i].textContent;
      }
    }
  } else {
    element.text = target.textContent
  }
  element.tag = target.tagName.toLowerCase();
  let atts = target.attributes;
  if (atts) {
    for (var k = 0, n = atts.length; k < n; k++){
      att = atts[k];
      attribute = {};
      attribute[att.nodeName] = att.nodeValue;
      element.attrs.push(attribute);
    }
  }
  return element;
}
let x = one_element(arguments[0]);
return x;
