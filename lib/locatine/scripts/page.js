function walk(target) {
    let node;

    const index = everything.indexOf(target);
    let element = [];
    let att_array = [];
    let item = {children: [],
                  data: [],
                  index: index};

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

    // Handle child elements (not magic ones)
    for (node = target.firstChild; node; node = node.nextSibling) {
        if (node.nodeType === 1) { // 1 == Element
            item.children.push(walk(node))
        }
    }
    item.data = element;
    return item;
}
const everything = Array.prototype.slice.call( document.getElementsByTagName("*") );
let result = walk(document.body);
return [result];
