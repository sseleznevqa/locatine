function walk(xmi, xma, ymi, yma){
  let x;
  let y;
  let array =[];
  let one;
  for (x = xmi; x <= xma; x++) {
    for (y = ymi; y <= yma; y++) {
      one = document.elementFromPoint(x, y);
      if ((one != document.documentElement) && (one != document.body)){
        array.push(document.elementFromPoint(x, y));
      }
    }
  }
  return [...new Set(array)];
}

return walk(parseInt(arguments[0]), parseInt(arguments[1]), parseInt(arguments[2]), parseInt(arguments[3]))
