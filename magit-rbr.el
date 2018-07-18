;;; magit-rbr.el --- Support for git rbr in Magit

;; Copyright (C) 2010-2018 Anatoly Fayngelerin

;; Author: Anatoly Fayngelerin <fanatoly+magitrbr@gmail.com>
;; Maintainer: Anatoly Fayngelerin <fanatoly+magitrbr@gmail.com>
;; Created: 18 Jul 2018
;; Version: 20180718.00
;; Keywords: git magit rbr tools
;; Homepage: https://github.com/fanatoly/magit-rbr
;; Package-Requires: ((magit "2.13.0") (emacs "24.3"))
;; This file is not part of GNU Emacs.

;; This file is free software...

;;; Commentary:
;;;
;;; This package tweaks magit to recognize `git rbr` rebases and use
;;; corresponding commands during the magit rebase sequence. This
;;; means that when you abort a rebase during a recursive rebase,
;;; magit will abort the rbr rather than a particular phase of
;;; rbr. This also adds recursive rebase as an option to the rebase
;;; popup.
;;;
;;; Code:
(require 'magit)
(require 'magit-sequence)

(defun magit-rebase-command ()
  (if (file-exists-p (magit-git-dir "rebase-recursive")) "rbr" "rebase"))

(defun magit-rebase-continue (&optional noedit)
  "Restart the current rebasing operation.
In some cases this pops up a commit message buffer for you do
edit.  With a prefix argument the old message is reused as-is."
  (interactive "P")
  (if (magit-rebase-in-progress-p)
      (if (magit-anything-unstaged-p t)
          (user-error "Cannot continue rebase with unstaged changes")
        (when (and (magit-anything-staged-p)
                   (file-exists-p (magit-git-dir "rebase-merge"))
                   (not (member (magit-toplevel)
                                magit--rebase-public-edit-confirmed)))
          (magit-commit-amend-assert))
        (if noedit
            (let ((process-environment process-environment))
              (push "GIT_EDITOR=true" process-environment)
              (magit-run-git-async (magit-rebase-command) "--continue")
              (set-process-sentinel magit-this-process
                                    #'magit-sequencer-process-sentinel)
              magit-this-process)
          (magit-run-git-sequencer (magit-rebase-command) "--continue")))
    (user-error "No rebase in progress")))

(defun magit-rebase-skip ()
  "Skip the current commit and restart the current rebase operation."
  (interactive)
  (unless (magit-rebase-in-progress-p)
    (user-error "No rebase in progress"))
  (magit-run-git-sequencer (magit-rebase-command) "--skip"))


(defun magit-rebase-abort ()
  "Abort the current rebase operation, restoring the original branch."
  (interactive)
  (unless (magit-rebase-in-progress-p)
    (user-error "No rebase in progress"))
  (magit-confirm 'abort-rebase "Abort this rebase")
  (magit-run-git (magit-rebase-command) "--abort"))


;;;###autoload
(defun magit-rbr-rebase-recursive (args)
  "Rebase the current branch recursively onto its upstream."
  (interactive (list (magit-rebase-arguments)))
  (message "Recursively Rebasing...")
  (magit-git-rebase-recursive args)
  (message "Recursively Rebasing...done"))

;;;###autoload
(defun magit-rbr-git-rebase-recursive (args)
  (magit-run-git-sequencer "rbr" args))

(magit-define-popup-action 'magit-rebase-popup ?r "recursively" 'magit-rbr-rebase-recursive ?i t)

(provide 'magit-rbr)

;;; magit-rbr.el ends here
