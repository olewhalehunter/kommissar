
function cycleTab(direction){
    var tabContainer = window.getBrowser().tabContainer;
    var tabs = tabContainer.childNodes;
    var numTabs = tabs.length;
    var startIndex = tabContainer.selectedIndex;

    if (direction == 0){
	startIndex++;
    }
    else{
	startIndex--;
    }

    if (startIndex >= numTabs){
	startIndex =0;
    }
    if (startIndex <= -1){
	startIndex = numTabs-1;
    }
    tabContainer.selectedItem = tabs[startIndex];
}

function gotoTab(titleRegex) { 
    var tabContainer = window.getBrowser().tabContainer;
    var tabs = tabContainer.childNodes;
    var numTabs = tabs.length;
    var startIndex = tabContainer.selectedIndex;

  for (i = 0; i < numTabs - 1; i++) {
    testIndex = (startIndex + i + 1) % numTabs;
    if (tabs[testIndex].label.match(titleRegex)) {
      tabContainer.selectedItem = tabs[testIndex];
      break;
    }
  }
}

function openTab(url, tabID) {
    content.window.open(url, tabID);
}

function closeTab(tabID){
    content.window.close(tabID);
}





