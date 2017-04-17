(defun package-init ()
  (defpackage :kommissar (:use :cl :telnetlib))
  (in-package :kommissar)
  (eval-when 
      (:compile-toplevel :load-toplevel :execute))
  (mapcar 'quickload '(:telnetlib
		       :jsown
		       :parenscript))
  ) (package-init)

(setq kom-session '()
   moz-return-val ""
   kommissar-js-folder (cond 
			 ((string= (software-type) "Linux")
			  "home/user/projects/kommissar/kommissar-js/")
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
  (moz-send input))

(defun ps-eval (input)
  "Evaluate ParenScript sexps"
  (moz-send (parenscript::ps (parenscript::lisp (read-from-string input)))))

(defun push-var (var val)
  "Add variable/value pair to DOM container"
  (moz-eval "window.document.body.dcont = 1"))

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
  (sb-ext:run-program "/usr/bin/wget"
		      (list (current-url) "-P" target-folder)))

(defun download-url (url target-folder)
  (sb-ext:run-program "/usr/bin/wget"
		      (list url "-P" target-folder)))

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
  (open-url "localhost:8000")
  (backward-tab)
  (goto-tab "search")
  (scroll-down)
  (scroll-up)
  (close-tab "search")

  (progn 
    (refresh)
    (moz-eval-file "tabs.js")
    )
  )
(defun start-moz-client ()
  (ignore-errors (close-telnet-session kom-session))
  (ignore-errors  (moz-eval "repl.quit()"))
  (setq kom-session (telnetlib:open-telnet-session "127.0.0.1" 4242))
  (telnetlib:set-telnet-session-option
   kom-session :remove-return-char t)
  (moz-eval (parenscript::ps-compile-file "/kommissar-js/tabs.lisp"))
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



