(defun cycle-tab (direction)
  (setq tabContainer (eval "window.getBrowser().tabcontainer")
     tabs tabContainer.childNodes
     numTabs tabs.length
     startIndex tabContainer.selectedIndex)
  (if (= direction 0)
      (+= 1 startIndex)
      (-= 1 startIndex))
  (if (>= startIndex numTabs)
      (setq startIndex 0))
  (if (<= startIndex -1)
      (setq startIndex (- numTabs 1)))
  (setq tabContainer.selectedIndex
     tabs[startIndex])
)

(defun goto-tab (titleRegex)
  (setq tabContainer (eval "window.getBrowser().tabcontainer")
     tabs tabContainer.childNodes
     numTabs tabs.length
     startIndex tabContainer.selectedIndex)

  (loop for i from 0 below numTabs do
       (progn
	 (setq textIndex (% 
		       (+ 1 i startIndex)
		       numTabs))
	 (if (eval "tabs[testIndex].label.match(titleRegex)")
	     (setq tabContainer.selectedItem
		tabs[testIndex])
	     )))
  )

(defun open-tab (url tabID)
  (content.window.open url tabID))

(defun close-tab (tabID)
  (content.window.close tabID))

(defun windowScroll(x y)
  (content.window.scrollBy x y)
)

(defun scrollDown ()
  (windowScroll 0 90))

(defun scrollUp ()
  (windowScroll 0 -90))
