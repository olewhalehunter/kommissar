;; to-do:
;; -
"The value -10 is not of type SB-INT:INDEX. bug"
;;^reproduce -> repeat testworkflow command a lot
;; moz-eval -> read-until "start"
"highlight/border identified element"
;; multi-page workflows
"start workflow command (query for url or blank for use current/none)"
"create current workflow object"
"master listener for tool postbacks"
"postback to master lisp to store elements with each record"
"gui elements reload/workflow load"
;; add ParenScript support
;; toggle show info above each id'd element
;; ensure tool divs coordinates fully in view
;;  --
;; record tab changes
;; action-by-action runthrough of recording
;; sequences of elements by interactive xpath regex highlight
;; re-edit/re-order? actions in gui
;; schmancy GUI styling
;; lisp js DSL/vm/compiler (mainly for gui components)
;; cross-page state validation for workflows
;; better mozrepl debugging, repl instance tracking
;; -user-select workaround wo stylish
;; GUI fix without scriptish, rewrite mozrepl as new addon?
;; google mouse track event fix
;; set-text button only visible on input/textarea

(ql:quickload :telnetlib)
(ql:quickload :jsown)
(ql:quickload :parenscript)
(defun package-init ()
(defpackage :kommissar (:use :cl :telnetlib))
(in-package :kommissar)
(eval-when 
    (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :telnetlib))
) (package-init)

(defparameter kom-session '())
(defparameter moz-return-val "")
(defparameter kommissar-js-folder
  (cond ((string= (software-type) "Linux")
	 "home/frog/projects/kommissar/kommissar-js/")
	((string= (software-type) "Windows")
	 "")))
(defun read-file-as-string (file-name)
  (format nil "~{~a~}"
	  (with-open-file (stream file-name)
	    (loop for line = (read-line stream nil)
	       while line
	       collect line))))
(defun moz-wrapper (input)
  (concatenate 'string "\"START\" + (" input ") + \"END\""))
(defun moz-send (input)
  (telnetlib:write-ln kom-session input))

(defun moz-eval (input)
  (moz-send (moz-wrapper input))
  (print (telnetlib:read-until kom-session "START"))2
  (let ((retval (string-trim "END"
			     (telnetlib:read-until kom-session "END" ))))
    retval
    ))

(defun ps-eval (input)
  "Evaluate ParenScript sexps"
  (moz-send (parenscript::ps (parenscript::lisp (read-from-string input)))))

(defun push-var (var val)
  "Add variable/value pair to DOM container"
  (moz-eval "window.document.body.dcont = 1")
  )

(defun moz-eval-file (file-name)  
  (telnetlib:write-ln
   kom-session
   (concatenate 'string "repl.load(\"file://localhost/"
		kommissar-js-folder file-name "\")"))
  ;;(print (telnetlib:read-available-data kom-session))
  )

(defun current-url ()
  (moz-eval "content.location.href"))
(defun refresh ()
  (moz-eval "content.location.href = content.location.href"))
(defun forward-tab ()
  (moz-eval "cycleTab(0)"))
(defun backward-tab ()
  (moz-eval "cycleTab(1)"))
(defun goto-tab (tab-regex)
  (moz-eval 
   (concatenate 'string
		"gotoTab(\"" tab-regex "\")")))
(defun open-url (url tab-id)
  (moz-eval (concatenate 'string
			 "openTab(\"" url "\", \"" tab-id "\")")))
(defun close-tab (tab-id)
 (moz-eval (concatenate 'string
			"closeTab(\"" tab-id "\")")))
(defun scroll-down ()
  (moz-eval "scrollDown()"))
(defun scroll-up ()
  (moz-eval "scrollUp()"))
(defun get-html (id)
  (moz-eval (concatenate 'string
			 "content.document.getElementById(\"" id "\").innerHTML")))

(defun download-page (target-folder)
  (sb-ext:run-program "/usr/bin/wget"  ;; SBCL+linux only
		      (list (current-url) "-P" target-folder)))

(defun download-url (url target-folder)
  (sb-ext:run-program "/usr/bin/wget"  ;; SBCL+linux ONLY
		      (list url "-P" target-folder)))

(download-page "/home/frog/projects/kommissar/")
(download-url "https://raw.githubusercontent.com/mrdoob/three.js/master/build/three.min.js" "/home/frog/")

(defun mouse-click (target-key)
  (let ((element (jsown:val elements target-key)))
    (print 
    (moz-eval (concatenate 'string
     (get-elem (jsown:val element "xPath"))
     ".click()")))))

(defun set-text (target-key text)
 (let ((element (jsown:val elements target-key)))
    (print 
    (moz-eval (concatenate 'string
     (get-elem (jsown:val element "xPath"))
     ".value = '" text "'")))))

(defun dict-scrape (target-key)
(let ((element (jsown:val elements target-key)))
    (moz-eval (concatenate 'string
     (get-elem (jsown:val element "xPath"))
     ".innerHTML"))))

(defun unit-tests ()
  (forward-tab)
  (refresh)
  (forward-tab)
  (open-url "http://www.google.com" "google")
  (backward-tab)
  (goto-tab "Google")
  (scroll-down)
  (scroll-up)
  (close-tab "google")
  (download-page 
   "/home/frog/projects/")
  (download-url 
   "https://raw.githubusercontent.com/mrdoob/three.js/master/build/three.min.js" 
   "/home/frog/")
  (progn 
    (refresh)
    (moz-eval-file "kommissar-utils.js")
    )
  )
(defun start-moz-client ()
  (ignore-errors (close-telnet-session kom-session))
  (ignore-errors  (moz-eval "repl.quit()"))
  (setq kom-session (telnetlib:open-telnet-session "127.0.0.1" 4242))
  (telnetlib:set-telnet-session-option
   kom-session :remove-return-char t)
  (print (moz-send "alert(\"Kommissar started!\")"))
;;  (moz-eval-file "~/kommissar-js/tabs.js")
) ;; (start-moz-client)

(defun start-kommissar ()
  (ignore-errors
    (start-moz-client)))
(start-kommissar)

(defun json-decode (json-string)
  (jsown:parse json-string))

(defun get-elem (xpath)
(concatenate 'string 
"content.document.evaluate('" xpath
"', content.document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue"))
(defun store-workflow (name)
  (defun load-elements-string ()
    (concatenate 'string
		 "~%(defun load-elements ()~%"
		 "(setq elements '" (prin1-to-string 
				     (json-decode (get-html "elements")))
		 "~%))~%(load-elements)"))
  (defun load-dictionary-string ()
    (concatenate 'string
		 "~%(defun load-dictionary ()~%"
		 "(setq dict '" (prin1-to-string (json-decode (get-html "dict")))
		 "~%)) ~%(load-dictionary)"))
  (defun load-actions-string ()
    (concatenate 'string
		 "~%(defun load-actions ()~%"
		 "(setq actions '" (prin1-to-string (json-decode (get-html "actions")))
		 "~%)) ~%(load-actions)")
    )
  (defun load-script ()
    (concatenate 'string
		 "~%(defun workflow-script ()~%"
		 (format nil "~{~a~%~}"
			 (loop for x in (json-decode (get-html "actions"))
			    collect (action-sexp x)))
		 "~%) ;;(workflow-script)"))
  
  (with-open-file (file (concatenate 'string name ".lisp")
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)
  (format file (concatenate 'string
	  "(in-package :kommissar)~%"
	  (load-elements-string) "~%"
	  (load-actions-string)
	  ;;(load-dictionary-string) transactional dict record?
	  (load-script)
	  )
	  ))
)

;; (store-workflow "~/projects/kommissar/testworkflow")

(defun action-sexp (action)
  (let ((target-key (jsown:val action "target"))
	(action-type (jsown:val action "action"))
	(args (jsown:val action "args")))
    (print action-type)
     (cond
       ((string= action-type "dict-scrape") (concatenate 'string
	"(setq " (first args) " (dict-scrape \"" target-key "\"))"))
       ((string= action-type "mouse-click") (concatenate 'string
	"(mouse-click \"" target-key "\")"))
       ((string= action-type "set-text") (concatenate 'string
	"(set-text \"" target-key "\" \"" (first args) "\")")))))
