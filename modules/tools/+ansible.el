;; -*- lexical-binding: t; -*-

(use-package ansible
  :delight (ansible-mode (:eval (+with-icon "nf-dev-ansible" " "))))

(use-package ansible-doc
  :delight)

(use-package poly-ansible-jinja2
  :vc (:url "https://github.com/cat-emacs/poly-any-template"
            :lisp-dir "lisp/ansible"))

(use-package flymake-ansible-lint
  :hook
  (ansible-mode . flymake-ansible-lint-setup)
  (ansible-mode . flymake-mode))
