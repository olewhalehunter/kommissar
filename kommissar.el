;; Kommissar Emacs binds

(defun eval-slime (str)
  "Eval STR as Common Lisp code."
  (unless (slime-current-connection)
    (let ((wnd (current-window-configuration)))
      (slime)
      (while (not (and (slime-current-connection)
                       (get-buffer-window (slime-output-buffer))))
        (sit-for 0.2))
      (set-window-configuration wnd)))
  (let (deactivate-mark)
    (cadr (slime-eval `(swank:eval-and-grab-output ,str)))))

(defun kom-start ()
  (interactive)
  (slime-load-file "~/projects/kommissar/kommissar.lisp")
  )

(defun kom-refresh ()
  (interactive)
  (eval-slime "(kommissar::refresh)"))
(defun kom-scroll-down ()
  (interactive)
  (eval-slime "(kommissar::scroll-down)"))
(defun kom-scroll-up ()
  (interactive)
  (eval-slime "(kommissar::scroll-up)"))
(defun kom-forward-tab ()
  (interactive)
  (eval-slime "(kommissar::forward-tab)"))
(defun kom-backward-tab ()
  (interactive)
  (eval-slime "(kommissar::backward-tab)"))

(defun kom-open (url)
  (eval-slime (concat "(kommissar::open-url \""
		      url "\" \"kommissarTab\")"))
  )

(defun kom-goto-tab (regex)
  (eval-slime (concatenate 'string "(kommissar::goto-tab \"" regex "\")")))

(defun kom-open-url ()
  (interactive)
  (eval-slime
   (concat "(kommissar::open-url \""
	   (read-string "URL: ")"\" \"kommissarTab\")")))
(defun kom-close-tab ()
  (interactive)
  (eval-slime "(kommissar::close-tab \"\")"))
(defun kom-google ()
  (interactive)
  (eval-slime
   (concat "(kommissar::open-url \"http://www.google.com/search?q="
			  (replace-regexp-in-string " " "+" 
						    (read-from-minibuffer "google: "))
			  "\" \"googleTab\")"
			  ))
  (eval-slime "(kommissar::goto-tab \"Goog\")")
  )
(defun kom-download-page ()
  (interactive)
  (eval-slime
   (concat  "(kommissar::download-page \""
	    (replace-regexp-in-string " " "+" 
				      (read-from-minibuffer 
				       "downloading current page, target folder : "))
	    "\")")))
			 
(defun google ()
  (interactive) (kom-google))

(set-key "<f4>" 'kom-start)
(set-key "<f5>" 'kom-refresh)
(set-key "<f12>" 'kom-scroll-down)
(set-key "<f11>" 'kom-scroll-up)
(set-key "<f9>" 'kom-backward-tab)
(set-key "<f10>" 'kom-forward-tab)
(set-key "<home>" 'kom-google)
(set-key "<insert>" 'kom-chan-reply)
    
;; (fset 'ksl
;;    "(eval-slime \"(kommissar::ps-eval \\\"\C-e\\\")\")")
(defun kom-send-line () (interactive)
    (beginning-of-line)
    (call-interactively 'set-mark-command)
    (end-of-line)
    (call-interactively 'kom-send-region)
    )
(defun kom-send-region (start end) 
  (interactive "r")
  (print (buffer-substring-no-properties start end))
  (eval-slime
   (concat "(kommissar::ps-eval \""
	   (buffer-substring-no-properties
	    start end) "\"))"))
  )

(set-key "<f1>" 'kom-send-region) ;; <- use this for interactive ParenScript development


(add-hook
 'slime-connected-hook
 (lambda ()
   (kom-start)
   ))

;; pref("extensions.mozrepl.autoStart", true);
;; ^ put in "pref.js" in firefox profile directory during installer
;; (eshell-command "cp ~/emacs-tools/kommissar.lisp ~/projects/kommissar/kommissar.lisp")
;; (eshell-command "cp ~/emacs-tools/kommissar.el ~/projects/kommissar/kommissar.el")
;; (eshell-command "cp ~/emacs-tools/kommissar-js/kommissar-utils.js ~/projects/kommissar/kommissar-js/kommissar-utils.js")
;; ;; (eshell-command "cp ~/emacs-tools/testworkflow.lisp ~/projects/kommissar/testworkflow.

