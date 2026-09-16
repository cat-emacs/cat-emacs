;; -*- lexical-binding: t; -*-

(use-package mcp
  :if EMACS30+
  :defer t
  :vc (:url "https://github.com/cat-emacs/mcp.el"
            :branch "feat/oauth-client"))

(use-package feishu-project
  :vc (:url "https://github.com/cat-emacs/feishu-project.el")
  :commands
  (feishu-project-list
   feishu-project-mql)
  :custom
  (feishu-project-backend (if EMACS30+ 'mcp 'openapi)))

(provide '+feishu-project)
;;; +feishu-project.el ends here
