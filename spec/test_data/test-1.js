const magicDiv = document.getElementById("locatine_magic_div");
const element = document.getElementById("Label");
function locatineTestSelect(index, tag, confirm){
  magicDiv.setAttribute("INDEX", index);
  magicDiv.setAttribute("TAG", tag);
  magicDiv.setAttribute("locatineconfirmed", confirm);
};
setTimeout(function() {magicDiv.setAttribute("locatinecollection", "true")}, 1000);
setTimeout(function() {locatineTestSelect("0", "li", "selected")}, 2000);
setTimeout(function() {if (!magicDiv.getAttribute("locatinetitle").includes("1 element was selected as lisa foxa in Default. If it is correct - confirm the selection."))
                         {
                           element.innerText = "Title was = " + magicDiv.getAttribute("locatinetitle") + " expected = 1 element was selected as span in Default. If it is correct - confirm the selection."
                         }}, 3000);
setTimeout(function() {locatineTestSelect("", "", "declined")}, 4000);
setTimeout(function() {if (!magicDiv.getAttribute("locatinetitle").includes("Now nothing is selected as lisa foxa in Default"))
                         {
                           element.innerText = "Title was = " + magicDiv.getAttribute("locatinetitle") + " expected = Now nothing is selected as lisa foxa in Default"
                         }}, 5000);
setTimeout(function() {locatineTestSelect("0", "li", "selected")}, 6000);
setTimeout(function() {locatineTestSelect("1", "li", "selected")}, 7000);
setTimeout(function() {if (!magicDiv.getAttribute("locatinetitle").includes("3 elements were selected as lisa foxa in Default. If it is correct - confirm the selection."))
                         {
                           element.innerText = "Title was = " + magicDiv.getAttribute("locatinetitle")+ " expected = 3 elements were selected as lisa foxa in Default. If it is correct - confirm the selection."
                         }}, 8000);
setTimeout(function() {locatineTestSelect("1", "li", "true")}, 9000);
setTimeout(function() {magicDiv.setAttribute("locatinecollection", false)}, 10000);
setTimeout(function() {locatineTestSelect("0", "label", "selected")}, 11000);
setTimeout(function() {if (!magicDiv.getAttribute("locatinetitle").includes("1 element was selected as element in Default. If it is correct - confirm the selection."))
                         {
                           element.innerText = "Title was = " + magicDiv.getAttribute("locatinetitle") + "expected: 1 element was selected as element in Default. If it is correct - confirm the selection."
                         }}, 12000);
setTimeout(function() {locatineTestSelect("0", "label", "selected")}, 13000);
setTimeout(function() {locatineTestSelect("0", "label", "true")}, 14000);
setTimeout(function() {locatineTestSelect("", "", false)}, 15000);
setTimeout(function() {magicDiv.setAttribute("locatineconfirmed", "true")}, 16000);
setTimeout(function() {locatineTestSelect("", "", false)}, 17000);
setTimeout(function() {magicDiv.setAttribute("locatineconfirmed", "true")}, 18000);
setTimeout(function() {locatineTestSelect("", "", false)}, 19000);
setTimeout(function() {magicDiv.setAttribute("locatineconfirmed", "true")}, 20000);
setTimeout(function() {locatineTestSelect("", "", false)}, 23000);
setTimeout(function() {magicDiv.setAttribute("locatineconfirmed", "true")}, 24000);
setTimeout(function() {locatineTestSelect("", "", false)}, 25000);
setTimeout(function() {magicDiv.setAttribute("locatineconfirmed", "true")}, 26000);
setTimeout(function() {locatineTestSelect("", "", false)}, 27000);
setTimeout(function() { magicDiv.setAttribute("locatineconfirmed", "true")}, 29000);
setTimeout(function() {locatineTestSelect("", "", false)}, 31000);
setTimeout(function() { magicDiv.setAttribute("locatineconfirmed", "true")}, 33000);
