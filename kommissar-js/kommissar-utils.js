// ==UserScript==
// @id             sandbox
// @name           sandboxxxxxx
// @version        1.0
// @namespace      kommissar
// @include        *
// @run-at         document-end
// @grant unsafeWindow
// ==/UserScript==

/* Kommissar Browser GUI*/
var showToolbar = true;
var showHoverInfo = false;
var showRecordTool = false;
var showActionList = false;
var curElement, curObject
function addButton(parent, text, func){
    var button  = document.createElement("button");
    button.setAttribute("type", "button");
    button.setAttribute("id", (text + "Btn"));
    button.innerHTML =  text;
    parent.appendChild(button);
    return button;
}
function addDiv(parent, text){
    var elem = window.document.createElement("div");
    elem.id = text + "Div";
    parent.appendChild(elem);
    elem.innerHTML =text;
    return elem;
}

elementsD = addDiv(window.document.body, "placeholder");
elementsD.id = "elements";
elementsD.style.display = 'none';
dictD = addDiv(window.document.body, "placeholder");
dictD.id = "dict";
dictD.style.display = 'none';
actionsD = addDiv(window.document.body, "placeholder");
actionsD.id = "actions";
actionsD.style.display = 'none';

dict = {} // variable key->value lookup for runtime
elements = {}; // elements by Kommissar keyname ID
elemsPath = {}; // elements by xPath
actions = []; // actions by function keyname

elementsD.innerHTML = "{}";
dictD.innerHTML = "{}";

function updateActionList() {
    actionList.innerHTML = "Action List:</br>";
    for (action in actions){
	action = actions[action];
	actionList.innerHTML += "* " + action.target + " " + action.action 
	    + " (" + action.args.map(function (x) { return "\""+x+"\"";}) + ")</br>";
    }
}

// (set-text 'searchbar "search string")
// -> (moz-eval "setText(\"searchbar1\", \"search string\")")

function recordSetTextAction(){
    storeAction({
	target : curObject.key,
	action : "set-text",
	args : [recordTextInput.value]
    });
    curElement.value = recordTextInput.value;
    recordTextInput.value = "";
    updateActionList();
}

function recordClickAction(){
    storeAction({
	target : curObject.key,
	action : "mouse-click",
	args : []
    });
    curElement.click();
    updateActionList();
}

function recordScrapeAction(){
    storeAction({
	target : curObject.key,
	action : "dict-scrape",
	args : [recordScrapeInput.value, curElement.innerHTML]
    });
    updateActionList();
    dict[recordScrapeInput.value] = curElement.innerHTML;
    dictD.innerHTML = JSON.stringify(dict);
}

function storeAction(action){
    actions.push(action);
    actionsD.innerHTML = JSON.stringify(actions);
}

function storeElement(value){
    elements[value.key] = value;
    elemsPath[value.xPath] = value;
    elementsD.innerHTML = JSON.stringify(elements);
}

function getElementByXpath(path) {
  return document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
}

function identifyElement(){
    curObject = {
	xPath : getElementXPath(curElement),
	key : recordKeynameInput.value,
	element : curElement
    };
    storeElement(curObject);
    recordXPath.style.color = "green"; 
    recordTextButton.style.display = "inline";
    recordClickButton.style.display = "inline";
}

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

function initActionList(){
    actionList = window.document.createElement("div");
    actionList.style.position = "fixed";
    actionList.style.width = "300px";
    actionList.style.height = "400px";
    actionList.style.fontSize = "10px";
    actionList.style.top = "50px";
    actionList.style.left = "10px";
    actionList.style.zIndex = 2147483646;
    actionList.style.display = "none";

    content.document.body.appendChild(actionList);
}
initActionList()

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

function mergeObj(obj1, obj2){ for(var key in obj2) obj1[key]=obj2[key];}

function addTag(text){
    tag = window.document.createElement("div");
    tag.innerHTML = text;
    this.appendChild(tag);
}

function initKomToolbar() {
    komToolbar = window.document.createElement("div");
    komToolbar.id = "komToolbar";
    
    mergeObj(komToolbar.style, {position : "fixed",
				 left : "50px",
				 bottom : "50px",
				 width : "350px",
				 height : "75px",
				 color : "black",
				 fontSize : "10px",
				 cursor : "auto !important",
				 zIndex : 2147483646,
				 backgroundColor : "white"});
    content.document.body.appendChild(komToolbar);

    ["[F1] -  toggle show current element  .",
    "[F2] - record action for element  .",
    "[F3] - toggle show identified elements  .",
    "[F4] - toggle show action list.",
    "[F8] - toggle hide toolbar."].map(addTag, komToolbar);
}
initKomToolbar()

function initRecordTool(){
    recordTool = window.document.createElement("div");
    recordTool.id = id =  "recordTool",
    mergeObj(recordTool.style, {position : "fixed",
				left : "50px",
				bottom : "50px",
				width : "350px",
				height : "75px",
				color : "black",
				fontSize : "small",
				cursor : "auto !important",
				zIndex : 2147483646,
				display : 'inline',
				backgroundColor : "white"});

    recordTool.innerHTML = "Identify element and record actions.";
    content.document.body.appendChild(recordTool);

    recordXPath = addDiv(recordTool, "no xPath for element yet");
    recordXPath.style.color = "green";

    recordKeyname = addDiv(recordTool, "Element has no ID");

    recordKeynameInput = document.createElement("input");
    recordKeynameInput.setAttribute("type", "text");
    recordKeynameInput.setAttribute("id", "toolID");
    recordTool.appendChild(recordKeynameInput);
    recordKeynameInput.placeholder = "enter keyname for element";

    recordIDButton = addButton(recordTool, "Identify", null);
    recordIDButton.onclick =  function () { identifyElement(); };

    addDiv(recordTool, "</br>")

    recordTextInput = document.createElement("input");
    recordTextInput.setAttribute("type", "text");
    recordTextInput.setAttribute("id", "textInput");
    recordTool.appendChild(recordTextInput);
    recordTextInput.placeholder = "record text entry";
    recordTextInput.style.display = "none";

    recordTextButton = addButton(recordTool, "Record Text", null);
    recordTextButton.onclick =  function () { recordSetTextAction(); };
    recordTextButton.style.display = "none";

    addDiv(recordTool, "</br>")
    recordClickButton = addButton(recordTool, "Record Click", null);
    recordClickButton.onclick =  function () { recordClickAction(); };
    recordClickButton.style.display = "none";

    addDiv(recordTool, "</br>")
    recordScrapeInput = document.createElement("input");
    recordScrapeInput.setAttribute("type", "text");
    recordScrapeInput.setAttribute("id", "scrapeInput");
    recordTool.appendChild(recordScrapeInput);
    recordScrapeInput.placeholder = "variable name to store";
    recordScrapeInput.style.display = "none";

    recordScrapeButton = addButton(recordTool, "Record Scrape Value", null);
    recordScrapeButton.onclick =  function () { recordScrapeAction(); };
    recordScrapeButton.style.display = "none";
}
initRecordTool()

var mouseMovDelay = 0
var mouseX, mouseY
content.document.onmousemove = function (e) {
    mouseMovDelay += 1;
    mouseX = e.clientX;
    mouseY = e.clientY;
    if (!showRecordTool)
	curElement = content.document.elementFromPoint(mouseX, mouseY);
    if (elemsPath[getElementXPath(curElement)]){
	recordTextInput.style.display = "inline";
	recordTextButton.style.display = "inline";
	recordClickButton.style.display = "inline";
	recordScrapeInput.style.display = "inline";
	recordScrapeButton.style.display = "inline";
	recordXPath.innerHTML = "Key = " 
	+ elemsPath[getElementXPath(curElement)].key;
    }
    if (mouseMovDelay % 2 == 0) {
	if (showHoverInfo) {
	    mouseMovDelay = 1;
	    mouseX = e.clientX;
	    mouseY = e.clientY;
	    hoverInfo.style.left = mouseX + 20 +"px";
	    hoverInfo.style.top = mouseY - 20 +"px";
	    hoverInfo.innerHTML =  getElementXPath(curElement);	    
	}
    }
}

window.onresize = function(event) {
    //komToolbar = document.getElementById("komToolbar");
}

// KEYPRESS FUNCTIONS
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
	    if (elemsPath[getElementXPath(curElement)]){ 
		// Element already ID'd
		curObject = elemsPath[getElementXPath(curElement)];
		recordTextInput.style.display = "inline";
		recordTextButton.style.display = "inline";
		recordClickButton.style.display = "inline";
		recordScrapeInput.style.display = "inline";
		recordScrapeButton.style.display = "inline";
		recordXPath.style.display = "none";
		recordKeyname.innerHTML = "";
		recordKeynameInput.value =  curObject.key;

	    } else { // Unidentified Element
		recordTextButton.style.display = "none";
		recordTextInput.style.display = "none";
		recordClickButton.style.display = "none";
		recordScrapeInput.style.display = "none";
		recordScrapeButton.style.display = "none";
		recordXPath.style.color = "red";
		recordXPath.style.display = "block";
		recordKeynameInput.value = "";

		if (!(curElement.id == "")){
		    recordKeyname.innerHTML = "ID : " + curElement.id;
		    recordKeynameInput.value = "" + curElement.id;
		} else { 
		    recordKeyname.innerHTML = "Element has no ID";
		    recordKeynameInput.placeholder = "enter keyname for element";
		}
	    }
	    recordTool.style.display = 'inline';
	    hoverInfo.style.display = 'none';
	    recordTool.style.left = mouseX + 20 +"px";
	    recordTool.style.top = mouseY - 20 +"px";
	    recordXPath.innerHTML = getElementXPath(curElement);	    
	}
    }
    if (key == 114) { //F3
	
    }
    if (key == 115) { //F4
	showActionList = !showActionList;
	if (showActionList){
	    actionList.style.display = "inline";
	    updateActionList();
	} else {
	    actionList.style.display = "none";
	}
    }
    if (key == 116) {  } // F5
    if (key == 117) {  } // F6
    if (key == 118) {  } // F7
    if (key == 119) {   // F8
	showToolbar = !showToolbar;	
	if (showToolbar){
	    komToolbar.style.display = "inline";
	} else {
	    komToolbar.style.display = "none";
	}
    }
    
}

function getElementXPath(element) {
    if (element && element.id)
        return '//*[@id="' + element.id + '"]';
    else
        return "/" + this.getElementTreeXPath(element);
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
                index++;
        }
        var tagName = element.nodeName.toLowerCase();
        var pathIndex = (index ? "[" + (index+1) + "]" : "");
        paths.splice(0, 0, tagName + pathIndex);
    }

    return paths.length ? "/" + paths.join("/") : null;
}

function getElementByXpath(path) {
  return document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
}



