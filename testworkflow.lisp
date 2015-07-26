(in-package :kommissar)

(defun load-elements ()
(setq elements '(:OBJ
 ("" :OBJ ("xPath" . "//html/body/div/div/div/div/form/label/input")
  ("key" . "") ("element" :OBJ))
 ("githubSearch" :OBJ
  ("xPath" . "//html/body/div/div/div/div/form/label/input")
  ("key" . "githubSearch") ("element" :OBJ)))
))
(load-elements)

(defun load-actions ()
(setq actions '((:OBJ ("target" . "githubSearch") ("action" . "set-text")
  ("args" "common lisp library")))
)) 
(load-actions)
(defun workflow-script ()
  (set-text "githubSearch" "common lisp library")
  (mouse-click "githubSearch")
  ;; example workflow
  (if (= (first search-results) "Jsown")
      (mouse-click "githubHome"))
) ;;(workflow-script)
