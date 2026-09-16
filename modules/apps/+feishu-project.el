;; -*- lexical-binding: t; -*-

(use-package mcp
  :if EMACS30+
  :defer t
  :vc (:url "https://github.com/lizqwerscott/mcp.el"
             :rev "2d172809cbdb2a40d86b28ad73bd65547cefe0e1"))

(use-package feishu-project
  :vc (:url "https://github.com/cat-emacs/feishu-project.el")
  :commands
  (feishu-project-list
   feishu-project-mql)
  :custom
  (feishu-project-backend (if EMACS30+ 'mcp 'openapi)))

(provide '+feishu-project)
;;; +feishu-project.el ends here
