
function walk(elm) {
    let node;

    const tagName = elm.tagName.toLowerCase();
    const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
    const index = array.indexOf(elm);
    const relative = elm.getBoundingClientRect();

    // init item
    const item = {tag: tagName,
                  index: index,
                  style: getComputedStyle(elm).cssText,
                  text: "",
                  attrs: {},
                  coordinates: {top:0, bottom:0, left:0, right:0},
                  children: []};

    // text for item
    if (elm.childNodes) {
      for (let z = 0; z < elm.childNodes.length; ++z){
        if (elm.childNodes[z].nodeType === 3){
          item.text += elm.childNodes[z].textContent;
        }
      }
    } else {
      item.text = elm.textContent
    }

    // attributes for item
    atts = elm.attributes;
    if (atts) {
      for (var att, k = 0, n = atts.length; k < n; k++){
        att = atts[k];
        item.attrs[att.nodeName] = att.nodeValue;
      }
    }

    item.coordinates.top = relative["top"] + window.scrollY;
    item.coordinates.bottom = relative["bottom"] + window.scrollY;
    item.coordinates.left = relative["left"] + window.scrollX;
    item.coordinates.right = relative["right"] + window.scrollX;

    // Handle child elements (not magic ones)
    for (node = elm.firstChild; node; node = node.nextSibling) {
        if (node.nodeType === 1) { // 1 == Element
          if (node.attributes['id']) {
            if (node.attributes['id'].value !== 'locatine_magic_div') {
              item.children.push(walk(node))
            }
          } else {
            item.children.push(walk(node))
          }
        }
    }

    return item;
}
let result = walk(document.body);
return [result];
