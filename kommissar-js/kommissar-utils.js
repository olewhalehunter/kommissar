// ==UserScript==
// @id             sandbox
// @name           sandboxxxxxx
// @version        1.0
// @namespace      kommissar
// @author         
// @description    
// @include        *
// @run-at         document-end
// @grant unsafeWindow
// ==/UserScript==

/* Kommissar Util Functions
browser GUI...
----
identify button/store
if element already identified load keyname
store form elements from UI scrape to lisp
storage as lisp hashkey
;; (name '(identifier map))
start new workflow
 url of starting page
 action queue -> compiles to script section
 element list per page -> compiles to map structs
 variable image -> dictionary for workflow logic 
 record visit to next url in toolbar

per element workflow:
 open tool gui on element
 click identify button
 auto by xpath/id, if not what to identify by, list best options
 enter keyname for element in workflow
 store xpath in lisp haskey, file and kommissar var
 option click record text entry, enter text
 option click record click element
 option pull value to master dictionary
 option save variable, (eg image link, result value)
*/


var showToolbar = true;
var showHoverInfo = false;
var showRecordTool = false;

function getElem(id){
    return window.document.getElementById(id);
}

function getOffset( el ) {
    var _x = 0; var _y = 0;
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
        _x += el.offsetLeft - el.scrollLeft;
        _y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    return { top: _y, left: _x };
}
function insertAfter(newNode, referenceNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
    newNode.parentElement = referenceNode.parentNode;
}

var hoverInfo = null
function initHoverInfo() {
    hoverInfo = window.document.createElement("div");
    hoverInfo.style.position = "fixed";
    hoverInfo.style.width = "100px";
    hoverInfo.style.height = "100px";
    hoverInfo.style.color = "green";
    hoverInfo.style.zIndex = 2147483646;
    hoverInfo.style.backgroundColor = "white";

    content.document.body.appendChild(hoverInfo);
} 
initHoverInfo()

function initKomToolbar() {
    komToolbar = window.document.createElement("div");
    komToolbar.id = "komToolbar";
    komToolbar.style.position = "fixed";
    komToolbar.style.left = "100px";
    komToolbar.style.bottom = "50px";
    komToolbar.style.width = "350px";
    komToolbar.style.height = "75px";
    komToolbar.style.color = "black";
    komToolbar.style.fontSize = "small";
    komToolbar.style.cursor = "auto !important";

    komToolbar.style.zIndex = 2147483646;
    komToolbar.style.backgroundColor = "white";

    content.document.body.appendChild(komToolbar);

    komToolbarInfo = window.document.createElement("div");
    komToolbarInfo2 = window.document.createElement("div");
    komToolbarInfo.innerHTML = "[F1] -  toggle show current element  .";
    komToolbarInfo2.innerHTML = "[F2] - record action for element  .";
    komToolbar.appendChild(komToolbarInfo);
    komToolbar.appendChild(komToolbarInfo2);

}
initKomToolbar()

var recordTool = null 
function initRecordTool(){
    recordTool = window.document.createElement("div");
    recordTool.style.width = "350px";
    recordTool.style.height = "75px";
    recordTool.style.color = "black";
    recordTool.style.fontSize = "small";
    recordTool.style.position = "fixed";
    recordTool.id = "recordTool";

    recordTool.style.zIndex = 2147483646;
    recordTool.style.backgroundColor = "white";
    recordTool.style.display = 'inline';
    recordTool.innerHTML = "Identify element and record actions.";
    content.document.body.appendChild(recordTool);

    recordXPath = window.document.createElement("div");
    recordXPath.id = "xpath";
    recordTool.appendChild(recordXPath);
    recordXPath.innerHTML = "no xPath for element yet";
    recordXPath.style.color = "green";

    recordKeyname = window.document.createElement("div");
    recordKeyname.id = "keyname";
    recordTool.appendChild(recordKeyname);
    recordKeyname.innerHTML ="no keyname yet";

    recordKeynameInput = window.document.createElement("div");
    recordKeynameInput.id = "keynameInput";
    recordTool.appendChild(recordKeynameInput);
    recordKeynameInput.value ="";
    recordKeynameInput.placeholder = "enter keyname for element";
} 

initRecordTool()

var curElement, curObject
var mouseMovDelay = 0
var mouseX, mouseY
content.document.onmousemove = function (e) {
    mouseMovDelay += 1;
    mouseX = e.clientX;
    mouseY = e.clientY;
    curElement = content.document.elementFromPoint(mouseX, mouseY);
    if (mouseMovDelay % 2 == 0) {
	if (showHoverInfo) {
	    mouseMovDelay = 1;
	    mouseX = e.clientX;
	    mouseY = e.clientY;
	    hoverInfo.style.left = mouseX + 20 +"px";
	    hoverInfo.style.top = mouseY - 20 +"px";
	    curElement = content.document.elementFromPoint(mouseX, mouseY);
	    hoverInfo.innerHTML =  getElementXPath(curElement) + curElement.id;
	}
    }
}

window.onresize = function(event) {
    //komToolbar = document.getElementById("komToolbar");
}

window.document.dict = {
    'elements' : [],
    'actions' : []
}

window.document.sampElement = {
    'xPath' : "/html/body/div[1]/a",
    'keyname' : 'firstLink'
}

window.onkeydown = function(e) {
    var key = e.keyCode;
    
    if (key == 112) { //F1
	showHoverInfo = !showHoverInfo;
	if (!showHoverInfo)
	    hoverInfo.style.display = "none";
	else
	    hoverInfo.style.display = "inline";
    }
    if (key == 113) { //F2
	showRecordTool = !showRecordTool;
	if (!showRecordTool){
	    recordTool.style.display = 'none';
	}
	else{
	    recordTool.style.display = 'inline';
	    hoverInfo.style.display = 'none';
	    recordTool.style.left = mouseX + 20 +"px";
	    recordTool.style.top = mouseY - 20 +"px";
	    recordXPath.innerHTML = getElementXPath(curElement);
	    if (!(curElement.id == "")){
		recordKeyname.innerHTML = "ID : " + curElement.id;
		recordKeynameInput.value = "" + curElement.id;
	    } else { 
		recordKeyname.innerHTML = "Element has no ID";
		recordKeynameInput.placeholder = "enter keyname for element";
		recordKeynameInput.value ="";
	    }
	}
    }
}

function getElementXPath(element) {
    if (element && element.id)
        return '//*[@id="' + element.id + '"]';
    else
        return this.getElementTreeXPath(element);
}
function getElementTreeXPath(element) {
    var paths = [];

    for (; element && element.nodeType == 1; element = element.parentNode)
    {
        var index = 0;
        for (var sibling = element.previousSibling; sibling; sibling = sibling.previousSibling)
        {
            if (sibling.nodeType == Node.DOCUMENT_TYPE_NODE)
                continue;

            if (sibling.nodeName == element.nodeName)
                ++index;
        }
        var tagName = element.nodeName.toLowerCase();
        var pathIndex = (index ? "[" + (index+1) + "]" : "");
        paths.splice(0, 0, tagName + pathIndex);
    }

    return paths.length ? "/" + paths.join("/") : null;
}


var recordToolName = null
recordKeynameInput = document.createElement("input");
recordKeynameInput.setAttribute("type", "text");
recordKeynameInput.setAttribute("id", "toolID");
getElem("recordTool").appendChild(recordKeynameInput);
