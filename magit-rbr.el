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

;; This package tweaks magit to recognize `git rbr` rebases and use
;; corresponding commands during the magit rebase sequence. This
;; means that when you abort a rebase during a recursive rebase,
;; magit will abort the rbr rather than a particular phase of
;; rbr. This also adds recursive rebase as an option to the rebase
;; popup.

;;; Code:

(require 'magit)
(require 'magit-sequence)

;;;###autoload
(defun magit-rbr-rebase-recursive (args)
  "Rebase the current branch recursively onto its upstream."
  (interactive (list (magit-rebase-arguments)))
  (message "Rebasing recursively ...")
  (magit-git-rebase-recursive args)
  (message "Rebasing recursively...done"))

;;;###autoload
(defun magit-rbr-git-rebase-recursive (args)
  (magit-run-git-sequencer "rbr" args))

(magit-define-popup-action 'magit-rebase-popup
  ?r "recursively" 'magit-rbr-rebase-recursive ?i t)

(provide 'magit-rbr)

;;; magit-rbr.el ends here
