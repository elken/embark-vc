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
;; Package-Requires: ((emacs "25.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Some actions and conveniences for interacting with topics & commits in magit
;;
;;; Code:

(require 'embark)
(require 'forge-commands)
(require 'github-review)

(defun embark-magit-target-topic-at-point ()
  "Target a Topic in the context of Magit."
  (when (derived-mode-p 'magit-mode)
    (save-excursion
      (let* ((beg (progn (skip-chars-backward "#[0-9]+") (point)))
             (end (progn (skip-chars-forward "#[0-9]+") (point)))
             (str (buffer-substring-no-properties beg end)))
        (save-match-data
          (when (string-match "#\\([0-9]\\)+" str)
            (let ((id (substring str 1 (length str))))
              (if (forge-issue-p (embark-magit-id-to-topic id))
                  `(issue ,id)
                `(pull-request ,id)))))))))

(defun embark-magit-target-commit-at-point ()
  "Target a Commit in the context of Magit."
  (when (derived-mode-p 'magit-mode)
    (save-excursion
      (let* ((beg (progn (skip-chars-backward "\\b[0-9a-f]\\{5,40\\}\\b") (point)))
             (end (progn (skip-chars-forward "\\b[0-9a-f]\\{5,40\\}\\b") (point)))
             (str (buffer-substring-no-properties beg end)))
        (save-match-data
          (when (string-match "\\b[0-9a-f]\\{5,40\\}\\b" str)
            `(commit ,str)))))))

(defun embark-magit-id-to-topic (id)
  "Convert a given ID to a topic."
  (when-let ((pr (forge-get-topic (string-to-number id))))
    pr))

(defun embark-magit-get-topic-title (topic)
  "Get the title for a TOPIC."
  (oref topic title))

(defun embark-magit-id-to-url (id)
  "Convert a given ID to a topic url scoped to the current forge."
  (when-let ((url (forge-get-url (embark-magit-id-to-topic id))))
    url))

(defun embark-magit-edit-topic-title (id)
  "Edit the title for a topic by ID."
  (when-let ((pr (embark-magit-id-to-topic id)))
    (forge-edit-topic-title pr)))

(defun embark-magit-edit-topic-state (id)
  "Edit the title for a topic by ID."
  (when-let ((topic (embark-magit-id-to-topic id)))
    (when (magit-y-or-n-p
           (format "%s %S"
                   (cl-ecase (oref topic state)
                     (merged (error "Merged pull-requests cannot be reopened"))
                     (closed "Reopen")
                     (open   "Close"))
                   (embark-magit-get-topic-title topic)))
      (forge-edit-topic-state topic))))

(defun embark-magit-edit-topic-labels (id)
  "Edit the title for a topic by ID."
  (when-let ((pr (embark-magit-id-to-topic id)))
    (forge-edit-topic-labels pr)))

(defun embark-magit-start-review (id)
  "Start a review for a topic by ID."
  (when-let ((pr (embark-magit-id-to-url id)))
    (github-review-start pr)))

(embark-define-keymap embark-magit-topic-actions
  "Keymap for actions related to Topics"
  ("y" forge-copy-url-at-point-as-kill)
  ("s" embark-magit-edit-topic-state)
  ("t" embark-magit-edit-topic-title)
  ("l" embark-magit-edit-topic-labels))

(embark-define-keymap embark-magit-pull-request-actions
  "Keymap for actions related to Pull Requests"
  :parent embark-magit-topic-actions
  ("r" embark-magit-start-review)
  ("m" forge-merge))

(embark-define-keymap embark-magit-issue-actions
  "Keymap for actions related to Issues"
  :parent embark-magit-topic-actions)

(embark-define-keymap embark-magit-commit-actions
  "Keymap for actions related to Commits"
  ("b" forge-browse-commit))

(add-to-list 'embark-keymap-alist '(pull-request . embark-magit-pull-request-actions))
(add-to-list 'embark-keymap-alist '(issue . embark-magit-issue-actions))
(add-to-list 'embark-keymap-alist '(commit . embark-magit-commit-actions))

(add-to-list 'embark-target-finders 'embark-magit-target-topic-at-point)
(add-to-list 'embark-target-finders 'embark-magit-target-commit-at-point)

(provide 'embark-magit)
;;; embark-magit.el ends here
