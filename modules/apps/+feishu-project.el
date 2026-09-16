;; -*- lexical-binding: t; -*-

(use-package mcp
  :if EMACS30+
  :defer t
  :vc (:url "https://github.com/cat-emacs/mcp.el"
             :rev "0f18e48fd47793e326f25d70ca0fc79fce2f69a6"))

(use-package feishu-project
  :vc (:url "https://github.com/cat-emacs/feishu-project.el")
  :commands
  (feishu-project-list
   feishu-project-mql)
  :custom
  (feishu-project-backend (if EMACS30+ 'mcp 'openapi)))

(provide '+feishu-project)
;;; +feishu-project.el ends here
