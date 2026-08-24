;; -*- lexical-binding: t; -*-

(use-package logview
  :font-rule (terminal
             :rescale (("Symbols Nerd Font" . 1.2)))
  :mode ("\\<log\\>.*\\.\\(txt\\|gz\\)" . logview-mode)
  :hook (logview-mode . hl-line-mode))
