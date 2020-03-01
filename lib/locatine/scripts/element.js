
function one_element(target){

  let element = [];
  let att_array = [];

  // Taking text
  let text = "";
  if (target.childNodes){
    for (let i = 0; i < target.childNodes.length; ++i){
      if (target.childNodes[i].nodeType === 3){
        text += target.childNodes[i].textContent;
      }
    }
  } else {
    text = target.textContent
  }
  const text_array = text.split(/[\s\'\\]/).filter(word => word !== "");
  for (let i = 0; i < text_array.length; ++i){
    element.push({value: text_array[i], type: "text", name: "text"});
  }

  //Taking tag
  element.push({value: target.tagName.toLowerCase(), type: "tag", name: "tag"});

  //Taking attributes
  let atts = target.attributes;
  if (atts) {
    for (let k = 0, n = atts.length; k < n; k++){
      att = atts[k];
      att_array = att.nodeValue.split(/[\s\'\\]/).filter(word => word !== "");
      for (let i = 0; i < att_array.length; ++i){
        element.push({value: att_array[i], type: "attribute", name: att.nodeName});
      }
    }
  }
  return element;
}
let x = one_element(arguments[0]);
return x;
