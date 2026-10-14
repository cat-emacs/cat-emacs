;; -*- lexical-binding: t; -*-

(defvar cat/org-latex-environment-configured-p nil
  "Non-nil after TeX Live environment probing has been attempted.")

(defun cat/org-latex-configure-texlive-environment ()
  "Connect Homebrew dvisvgm to the TeX Live kpathsea tree."
  (unless cat/org-latex-environment-configured-p
    (setq cat/org-latex-environment-configured-p t)
    (when (and IS-MAC
               (executable-find "dvisvgm")
               (executable-find "kpsewhich"))
      (unless (getenv "TEXMFROOT")
        (when-let* ((texmfroot
                    (car (ignore-errors
                           (process-lines "kpsewhich" "-var-value=TEXMFROOT")))))
          (setenv "TEXMFROOT" texmfroot)))
      (unless (getenv "TEXMFCNF")
        (when-let* ((texmfcnf
                    (car (ignore-errors (process-lines "kpsewhich" "texmf.cnf")))))
          (setenv "TEXMFCNF" (file-name-directory texmfcnf)))))))

(use-package org-latex-preview
  :ensure nil
  :hook
  (org-mode . cat/org-latex-configure-texlive-environment)
  (org-mode . org-latex-preview-mode)
  :custom
  (org-latex-preview-mode-display-live t)
  (org-latex-preview-mode-update-delay 0.25)
  (org-latex-preview-process-precompile nil)
  (org-latex-preview-process-default 'dvisvgm)
  (org-latex-preview-mode-ignored-commands
   '(next-line
     previous-line
     mwheel-scroll
     scroll-up-command
     scroll-down-command))
  :config
  (setq org-latex-preview-preamble
        (replace-regexp-in-string
         (regexp-quote "\\documentclass{article}")
         "\\documentclass[dvisvgm]{article}"
         org-latex-preview-preamble t t))
  ;; org-drill and kitty-graphics still call the old internal entry point.
  (defun org--latex-preview-region (beg end)
    (org-latex-preview--preview-region
     org-latex-preview-process-default beg end)))

(setq org-latex-compiler "xelatex"
      org-latex-packages-alist
      '(
        ("" "booktabs" nil)
        ("" "ctex" t ("xelatex"))
        ("" "enumitem" nil)
        ("" "fontspec" nil)
        ("" "geometry" nil)
        ("" "minted2" nil)              ;FIXME: change to minted after https://github.com/gpoore/minted/issues/463 fixed
        ("" "newfloat" nil)
        ("" "pgfplots" t)
        ("" "svg" nil)
        )
      org-latex-default-table-environment "longtable"
      org-latex-src-block-backend 'minted)

(use-package ox-html
  :ensure nil
  :custom
  (org-html-latex-image-options
   `(:foreground "Black" :background "Transparent"
     :page-width 1.0 :scale 1.0
     :image-dir ,(concat cat-cache-dir "org-latex/"))))

(defun cat/org-src-redisplay-latex-preview ()
  (when (eq major-mode 'latex-mode)
    (with-current-buffer (org-src-source-buffer)
      (org-latex-preview))))

;; (advice-add #'org-edit-src-save :after #'cat/org-src-redisplay-latex-preview)

(defun cat/org-redisplay-all-latex-preview ()
  "Copy from `org-revert-all-org-buffers', refresh all latex preview."
  (interactive)
  (save-excursion
    (save-window-excursion
      (dolist (b (buffer-list))
	    (when (and (with-current-buffer b (derived-mode-p 'org-mode))
		           (with-current-buffer b buffer-file-name)
                   (with-current-buffer b org-startup-with-latex-preview))
	      (pop-to-buffer-same-window b)
	      (org-latex-preview '(64))
          (org-latex-preview '(16)))))))

;; (add-hook 'cat-theme-refresh-hook #'cat/org-redisplay-all-latex-preview)

(defun cat/org-preview-clear-cache ()
  (interactive)
  (org-latex-preview-clear-cache nil nil t))
