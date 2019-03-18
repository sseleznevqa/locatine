function walk(elm, result) {
    let node;

    const tagName = elm.tagName;
    const array = Array.prototype.slice.call( document.getElementsByTagName(tagName) );
    const index = array.indexOf(elm);

    const item = [tagName, index, getComputedStyle(elm).cssText]
    result.push(item)

    // Handle child elements
    for (node = elm.firstChild; node; node = node.nextSibling) {
        if (node.nodeType === 1) { // 1 == Element
            result = walk(node, result);
        }
    }
    return result
}
let array = walk(document.body,[]);
array.shift();
return array;
