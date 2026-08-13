;; -*- lexical-binding: t; -*-

(defvar cat-mermaid-config-file (cat-config-file "mermaid/config.json"))

(defvar cat-mermaid-theme "default")

(defun cat/mermaid-auto-theme ()
  "Adjust `cat-mermaid-theme' to align with Emacs' current theme."
  (setq-default cat-mermaid-theme (if (+dark-mode-p) "dark" "default")
                mermaid-flags (format "-c %s -t %s" cat-mermaid-config-file cat-mermaid-theme))
  (when (boundp 'org-babel-default-header-args:mermaid)
    (setf (alist-get :theme org-babel-default-header-args:mermaid)
          cat-mermaid-theme)))

(use-package mermaid-mode
  :font-rule (code-diagram :modes (mermaid-mode mermaid-ts-mode))
  :ensure-system-package
  (mmdr . "cargo install mermaid-rs-renderer")
  :mode "\\.mmd\\'"
  :custom
  (mermaid-mmdc-location "mmdr")
  (mermaid-tmp-dir (expand-file-name "mermaid/" cat-cache-dir))
  (mermaid-output-format ".svg")
  :config
  (mkdir mermaid-tmp-dir t)
  (add-hook 'cat-theme-refresh-hook #'cat/mermaid-auto-theme)
  (cat/mermaid-auto-theme))

(defun cat/mermaid-mode ()
  (setq-local indent-line-function 'insert-tab)
  (setq-local tab-width 4))

(add-hook 'mermaid-mode-hook #'cat/mermaid-mode)

(use-package ob-mermaid
  :demand t
  :after org
  :custom
  (ob-mermaid-cli-path "mmdr")
  (ob-mermaid-default-config-file cat-mermaid-config-file)
  :config
  (add-to-list 'org-babel-load-languages '(mermaid . t))
  (cat/mermaid-auto-theme)
  (defalias 'cat/ob-mermaid-execute
    (symbol-function 'org-babel-execute:mermaid))
  ;; `mermaid-mode' also defines this executor; keep ob-mermaid authoritative.
  (with-eval-after-load 'mermaid-mode
    (defalias 'org-babel-execute:mermaid #'cat/ob-mermaid-execute)))
