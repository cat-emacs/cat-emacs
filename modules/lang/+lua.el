;; -*- lexical-binding: t; -*-

(use-package lua-mode
  :ensure-system-package
  (stylua . stylua)
  :custom
  (lua-indent-level 2))

(use-package lua-ts-mode
  :ensure nil
  :when EMACS30+
  :custom
  (lua-ts-indent-offset 2))
