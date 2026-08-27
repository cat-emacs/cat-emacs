;; -*- lexical-binding: t; -*-

(defvar cat-agent-shell-kind-icons
  `(("read" . ,(+with-icon "nf-md-file_eye"))
    ("edit" . ,(+with-icon "nf-md-file_edit_outline"))
    ("delete" . ,(+with-icon "nf-md-file_remove_outline"))
    ("move" . ,(+with-icon "nf-md-file_move_outline"))
    ("search" . ,(+with-icon "nf-md-magnify"))
    ("execute" . ,(+with-icon "nf-md-console_line"))
    ("fetch" . ,(+with-icon "nf-md-cloud_download_outline"))
    ("think" . ,(+with-icon "nf-md-lightbulb_on_outline"))
    ("switch_mode" . ,(+with-icon "nf-md-swap_horizontal"))
    ("other" . ,(+with-icon "nf-md-toolbox_outline")))
  "Icons for ACP tool call kinds, keyed by the kind string.
Kinds absent here fall back to the \"other\" entry.")

(defun cat/agent-shell-status-kind-label (status kind)
  "Render STATUS and KIND with a nerd icon between them.

Delegates both fragments to `agent-shell--icon-and-kind-status-kind-label'
so status faces and kind wording follow upstream, and only inserts the
per-kind icon from `cat-agent-shell-kind-icons'."
  (when-let*
      ((parts (delq nil
                    (list (agent-shell--icon-and-kind-status-kind-label
                           status nil)
                          (when kind
                            (alist-get kind cat-agent-shell-kind-icons
                                       (alist-get "other" cat-agent-shell-kind-icons
                                                  nil nil #'equal)
                                       nil #'equal))
                          (agent-shell--icon-and-kind-status-kind-label
                           nil kind)))))
    (string-join parts " ")))

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
  (agent-shell-header-style 'text)
  (agent-shell-show-welcome-message nil)
  (agent-shell-thought-process-icon (+with-icon "nf-md-lightbulb_on_outline"))
  (agent-shell-permission-icon (+with-icon "nf-md-shield_alert_outline"))
  (agent-shell-busy-indicator-frames 'dots-round)
  (agent-shell-status-kind-label-function #'cat/agent-shell-status-kind-label)
  :custom-face
  (agent-shell-section-heading ((t (:inherit (bold font-lock-doc-markup-face)))))
  (agent-shell-section-annotation ((t (:inherit (italic font-lock-doc-face)))))
  (agent-shell-thought-body ((t (:inherit italic))))
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
