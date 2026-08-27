;; -*- lexical-binding: t; -*-

(use-package agent-shell
  :delight
  (agent-shell-ui-mode "")
  (agent-shell-completion-mode "")
  :bind
  (:map agent-shell-ui-mode-map
        ("C-c C-p" . agent-shell-ui-backward-block)
        ("C-c C-n" . agent-shell-ui-forward-block))
  :custom
  (agent-shell-dot-subdir-function #'agent-shell--dot-subdir-in-cache)
  (agent-shell-preferred-agent-config 'pi)
  :transient
  (cat-agent-shell
   (:description (+with-icon "nf-dev-terminal" nil " Agent Shell"))
   ["Action"
    ("s" "agent-shell" agent-shell)
    ("n" "new shell" agent-shell-new-shell)]
   ["Tools"
    ("w" "workspace" agent-shell-workspace-toggle)
    ("m" "manager" agent-shell-manager-toggle)])
  (cat-vibe
   ["Shell"
    ("s" "agent-shell" cat-agent-shell)])
  :config
  (defun agent-shell--dot-subdir-in-cache (subdir)
    "Return path to agent-shell/SUBDIR under the `cat-cache-dir'.

For example:

  (agent-shell--dot-subdir-in-cache \"screenshots\")
  => \"/path/to/cat-cache-dir/agent-shell/project-dir/screenshots\""
    (concat cat-cache-dir "agent-shell" (agent-shell-cwd) subdir)))

(use-package agent-shell-sidebar
  :cat sidebar
  :after agent-shell
  :vc (:url "https://github.com/cmacrae/agent-shell-sidebar")
  :bind
  (:map agent-shell-ui-mode-map
        ("C-c C-s" . agent-shell-sidebar-toggle-focus))
  :transient
  (cat-agent-shell
   ["Sidebar"
    ("t" "toggle" agent-shell-sidebar-toggle)
    ("f" "toggle focus" agent-shell-sidebar-toggle-focus)
    ("c" "change provider" agent-shell-sidebar-change-provider)
    ("r" "reset" agent-shell-sidebar-reset)]))

(use-package agent-shell-bookmark
  :cat bookmark
  :after agent-shell
  :vc (:url "https://github.com/dcluna/agent-shell-bookmark")
  :demand t)

(use-package agent-shell-ol
  :cat bookmark
  :ensure nil
  :after (agent-shell-bookmark org)
  :demand t)

(use-package agent-shell-workspace
  :cat workspace
  :after agent-shell
  :commands #'agent-shell-workspace-toggle
  :vc (:url "https://github.com/gveres/agent-shell-workspace"))

(use-package agent-shell-manager
  :cat manager
  :after agent-shell
  :commands #'agent-shell-manager-toggle
  :vc (:url "https://github.com/jethrokuan/agent-shell-manager"))
