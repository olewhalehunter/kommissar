;; to-do:
;; -
;; browser GUI
;; toggle show windows above each element as button in toolbar
;;  --
;; collect sequence of elements by interactive xpath regex highlight
;; cross-page state validation for workflows
;; better mozrepl debugging, repl instance tracking
;; -user-select workaround wo stylish
;; GUI fix without scriptish, rewrite mozrepl as new addon?
;; gmail mouse event fix

(ql:quickload :telnetlib)
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
  "~/emacs-tools/kommissar-js/")
(defun read-file-as-string (file-name)
  (format nil "~{~a~}" 
	  (with-open-file (stream file-name)
	    (loop for line = (read-line stream nil)
	       while line
	       collect line))))
(defun moz-wrapper (input)
  (concatenate 'string "\"START\" + (" input ") + \"END\""))
(defun moz-eval (input)  
  (telnetlib:write-ln kom-session (moz-wrapper input))
  (print (telnetlib:read-until kom-session "START"))
  (let ((retval (string-trim "END"
			     (telnetlib:read-until kom-session "END" ))))
    retval
    ))
(defun moz-eval-file (file-name)  
  (telnetlib:write-ln
   kom-session
   (concatenate 'string "repl.load(\"file://localhost/"
		kommissar-js-folder file-name "\")"))
  ;;(print (telnetlib:read-available-data kom-session))
)

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

(defun unit-tests
    (forward-tab)
  (refresh)
  (forward-tab)
  (open-url "http://www.google.com" "google")
  (backward-tab)
  (goto-tab "Google")
  (close-tab "google")
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
  
  (print (moz-eval  "content.location.href = content.location.href"))
  (moz-eval-file  "tabs.js")
)
(start-moz-client)
