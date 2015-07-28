;; Emacs binds

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
  (eval-slime "(kommissar::start-kommissar)")
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
(defun kom-open-url ()
  (interactive)
  (eval-slime
   (concat "(kommissar::open-url \""
	   (read-string "URL: ")"\" \"kommissarTab\")")))

(defun kom-google ()
  (interactive)
  (eval-slime
   (concat "(kommissar::open-url \"http://www.google.com/search?q="
			  (replace-regexp-in-string " " "+" 
						    (read-from-minibuffer "google: "))
			  "\" \"kommissarTab\")"
			  ))
  (eval-slime "(kommissar::goto-tab \"Goog\")")
  )

(set-key "<f4>" 'kom-start)
(set-key "<f5>" 'kom-refresh)
(set-key "<f12>" 'kom-scroll-down)
(set-key "<f11>" 'kom-scroll-up)
(set-key "<f9>" 'kom-backward-tab)
(set-key "<f10>" 'kom-forward-tab)
(set-key "<home>" 'kom-google)

; (global-set-key (kbd "M-s") 'moz-back-tab)
; (global-set-key (kbd "M-e") 'moz-send-region)
(slime-load-file "kommissar.lisp")
(kom-start)
;; pref("extensions.mozrepl.autoStart", true);
;; ^ put in "pref.js" in firefox profile directory during installer
;; (eshell-command "cp ~/emacs-tools/kommissar.lisp ~/projects/kommissar/kommissar.lisp")
;; (eshell-command "cp ~/emacs-tools/kommissar.el ~/projects/kommissar/kommissar.el")
;; (eshell-command "cp ~/emacs-tools/kommissar-js/kommissar-utils.js ~/projects/kommissar/kommissar-js/kommissar-utils.js")
;; ;; (eshell-command "cp ~/emacs-tools/testworkflow.lisp ~/projects/kommissar/testworkflow.lisp")






