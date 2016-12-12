(in-package :kommissar)

(defun load-elements ()
(setq elements '(:OBJ
 ("firstDownvote" :OBJ
  ("xPath" . "//html/body/div[4]/div[3]/div/div/div/div[5]")
  ("key" . "firstDownvote") ("element" :OBJ))
 ("firstRedditLink" :OBJ
  ("xPath" . "//html/body/div[4]/div[3]/div/div/div[2]/p/a")
  ("key" . "firstRedditLink") ("element" :OBJ))
 ("redditSearch" :OBJ ("xPath" . "//html/body/div[2]/div/form/input")
  ("key" . "redditSearch") ("element" :OBJ)))
))
(load-elements)

(defun load-actions ()
(setq actions '((:OBJ ("target" . "firstDownvote") ("action" . "mouse-click") ("args"))
 (:OBJ ("target" . "firstRedditLink") ("action" . "dict-scrape")
  ("args" "firstRedditLinkTitle"
   "Good morning, I thought I'd give a quick update."))
 (:OBJ ("target" . "redditSearch") ("action" . "set-text") ("args" "wefe")))
)) 
(load-actions)
(defun workflow-script ()
(mouse-click "firstDownvote")
(setq firstRedditLinkTitle (dict-scrape "firstRedditLink"))
(set-text "redditSearch" firstRedditLinkTitle)
) ;;(workflow-script)

;;




