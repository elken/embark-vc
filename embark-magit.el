;;; embark-magit.el --- Embark actions for Magit -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Ellis Kenyő
;;
;; Author: Ellis Kenyő <https://github.com/elken>
;; Maintainer: Ellis Kenyő <me@elken.dev>
;; Created: November 20, 2021
;; Modified: November 20, 2021
;; Version: 0.0.1
;; Keywords: convenience matching terminals tools unix vc
;; Homepage: https://github.com/elken/embark-magit
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

(require 'embark)

(defun embark-magit-target-pull-request-at-point ()
  "Target a Pull Request in the context of Magit."
  (when (derived-mode-p 'magit-mode)
    (save-excursion
      (let* ((beg (progn (skip-chars-backward "[:digit:]") (point)))
             (end (progn (skip-chars-forward "[:digit:]") (point)))
             (str (buffer-substring-no-properties beg end)))
        (save-match-data
          (when (string-match "#\\(:num:\\)+" str)
            `(pull-request str)))))))

(defun embark-magit-target-commit-at-point ()
  "Target a Commit in the context of Magit."
  (when (derived-mode-p 'magit-mode)
    (save-excursion
      (let* ((beg (progn (skip-chars-backward "[:alnum:]{7} [:alnum:]+") (point)))
             (end (progn (skip-chars-forward "[:alnum:]{7} [:alnum:]+") (point)))
             (str (buffer-substring-no-properties beg end)))
        (save-match-data
          (message "%s %s" str (string-match "\\([:alnum:]{7}\\) [:alnum:]+" str))
          (when (string-match "\\([:alnum:]{7}\\) [:alnum:]+" str)
            `(commit str)))))))

(add-to-list 'embark-target-finders 'embark-magit-target-pull-request-at-point)
(add-to-list 'embark-target-finders 'embark-magit-target-commit-at-point)

(string-match "\\([:alnum:]{7}\\) [:alnum:]+" "b5d8811 Commit")
(let* ((str "b5d8811 Commit")
      (match (string-match "\\([:alnum:]\\)" str)))
  (message "%o %s" match (match-string match str)))
(string-match "\\([:alnum:]\\)" "b5d8811 Commit")
(provide 'embark-magit)
;;; embark-magit.el ends here
