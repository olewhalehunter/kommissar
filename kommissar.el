;; Emacs MozRepl functions and automation
;;
;; License : AGPL3
;; https://www.gnu.org/licenses/agpl-3.0.html
;;
;; To Do:
;; Record click pattern -> chain workflow

(defun kommissar-init ()
  (slime-load-file "kommissar.lisp")
  (lispy-eval-lisp "(load \"kommissar.lisp\")")
  
) (kommissar-init)

;;(lispy-eval-lisp "(kommissar::moz-refresh)")

(defmacro kom-eval (input)
  `(cadr (slime-eval '(swank:eval-and-grab-output 
		       ,input))))

(defun moz-refresh ()
  (interactive)
  (lispy-eval-lisp "(kommissar::moz-refresh)"))

(defun lispy-eval-lisp (str)
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


(global-set-key (kbd "<f5>") 'moz-refresh)
(global-set-key (kbd "M-w") 'moz-forward-tab)

(global-set-key (kbd "M-s") 'moz-back-tab)
(global-set-key (kbd "M-e") 'moz-send-region)

(kommissar-init)
;; pref("extensions.mozrepl.autoStart", true);
;; ^ put in "pref.js" in firefox profile directory during installer







