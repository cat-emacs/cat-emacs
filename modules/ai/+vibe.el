;; -*- lexical-binding: t; -*-

(mode-transient-define-prefix cat-vibe ()
  :description (+with-icon "nf-fa-wand_sparkles" nil " Vibe Coding"))

(use-package chatgpt-shell
  :cat
  :custom
  (chatgpt-shell-root-path (concat cat-local-dir "shell-maker/"))
  (chatgpt-shell-model-version "gemma4")
  :transient
  (cat-vibe
   ["Shell"
    ("c" "chatgpt shell" chatgpt-shell-transient)])
  :config
  (chatgpt-shell-ollama-load-models :override t))

(use-package aidermacs
  :commands #'aidermacs-transient-menu
  :custom
  (aidermacs-backend 'vterm)
  (aidermacs-watch-files t)
  :transient
  (cat-vibe
   ["Aider"
    ("a" "aidermacs" aidermacs-transient-menu)]))

(use-package aider
  :transient
  (cat-vibe
   ["Aider"
    ("A" "aider.el" aider-transient-menu)])
  :config
  (aider-magit-setup-transients))

(use-package ob-aider
  :demand t
  :after org
  :config
  (add-to-list 'org-babel-load-languages '(aider . t)))
