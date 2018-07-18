(require 'magit)
(require 'magit-sequence)

;;; Common
(defun magit-rebase-command ()
  (if (file-exists-p (magit-git-dir "rebase-recursive")) "rbr" "rebase"))

;;;###autoload
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

;;;###autoload
(defun magit-rebase-skip ()
  "Skip the current commit and restart the current rebase operation."
  (interactive)
  (unless (magit-rebase-in-progress-p)
    (user-error "No rebase in progress"))
  (magit-run-git-sequencer (magit-rebase-command) "--skip"))


;;;###autoload
(defun magit-rebase-abort ()
  "Abort the current rebase operation, restoring the original branch."
  (interactive)
  (unless (magit-rebase-in-progress-p)
    (user-error "No rebase in progress"))
  (magit-confirm 'abort-rebase "Abort this rebase")
  (magit-run-git (magit-rebase-command) "--abort"))


;;;###autoload
(defun magit-rebase-recursive (args)
  "Rebase the current branch onto a branch read in the minibuffer.
All commits that are reachable from `HEAD' but not from the
selected branch TARGET are being rebased."
  (interactive (list (magit-rebase-arguments)))
  (message "Recursively Rebasing...")
  (magit-git-rebase-recursive args)
  (message "Recursively Rebasing...done"))

;;;###autoload
(defun magit-git-rebase-recursive (args)
  (magit-run-git-sequencer "rbr" args))

(magit-define-popup-action 'magit-rebase-popup ?r "recursively" 'magit-rebase-recursive ?i t)

(provide 'magit-rbr)
