;; -*- lexical-binding: t; -*-

(use-package mcp
  :if EMACS30+
  :defer t
  :vc (:url "https://github.com/cat-emacs/mcp.el"
            :branch "feat/oauth-client")
  :custom
  (mcp-oauth-storage-directory (concat cat-etc-dir "mcp-oauth/")))

(use-package feishu-project
  :vc (:url "https://github.com/cat-emacs/feishu-project.el")
  :custom
  (feishu-project-backend 'cli)
  (feishu-project-mcp-oauth
   '(:client-name "feishu-project.el" :open-browser t :grant-type device-code)))

(provide '+feishu-project)
;;; +feishu-project.el ends here
