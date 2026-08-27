;; -*- lexical-binding: t; -*-

;; Batch checks may load init.el directly, bypassing Emacs's early-init phase.
(unless (featurep 'cat-early-init)
  (let ((init-directory (file-name-directory load-file-name)))
    (load (expand-file-name "early-init" init-directory) nil 'nomessage)
    (package-initialize)))

(cat-benchmark 'beg)

;;; load-path
(let ((default-directory (expand-file-name "elisp" user-emacs-directory)))
  (when (file-directory-p default-directory)
    (add-to-list 'load-path default-directory)
    (normal-top-level-add-subdirs-to-load-path)))

;;; core
(require 'cat-core (expand-file-name "core/core" user-emacs-directory))
(cat-core-initialize)

;;; ui
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;; enable
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'list-threads 'disabled nil)
(put 'magit-clean 'disabled nil)

(cat-benchmark 'end)
