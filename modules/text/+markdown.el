;; -*- lexical-binding: t; -*-

(defun markdown-xwidget-auto-theme ()
  "Adjust `markdown-xwidget-github-theme' and `markdown-xwidget-mermaid-theme' to align with Emacs' current theme."
  (setq-default markdown-xwidget-github-theme (if (+dark-mode-p) "dark" "light")
                markdown-xwidget-mermaid-theme (if (+dark-mode-p) "dark" "default")))

(defun cat/markdown-fontify-code-font-role (lang start end)
  "Apply LANG's configured font role between START and END."
  (when (fboundp 'prosody-apply-to-region)
    (when-let* ((mode (if lang
                          (markdown-get-lang-mode lang)
                        markdown-fontify-code-block-default-mode)))
      (prosody-apply-to-region mode start end))))

(use-package mustache)

;; `md-mode' claims ".md" through its own autoload, so it must be declared
;; before `markdown-mode' for the more specific README rule below to win.
(use-package md-mode
  :cat
  :vc (:url "https://github.com/yibie/md-mode")
  :font-rule (prose
              :faces ((md-mode-callout decorative)
                      (md-mode-markup code :height 0.9)
                      (md-render-blockquote decorative)
                      (md-render-callout-title prose :weight semi-bold)
                      (md-render-header-* heading
                                          :height 1.6
                                          :height-step -0.075
                                          :weight bold
                                          :weight-step -0.5)
                      (md-render-inline-code code)
                      (md-render-link prose :weight semi-bold)
                      (md-render-source-block code)
                      (md-render-source-block-language code :height 0.9)
                      (md-render-table-* table)))
  :mode ("\\.md\\'" . md-mode)
  :custom
  ;; Prosody owns the heading scale through the font rule above; md-mode's own
  ;; absolute face heights would compound with it.
  (md-mode-heading-scaling-values '(1.0 1.0 1.0 1.0 1.0 1.0))
  (md-mode-fold-front-matter-on-open t)
  ;; `mmdr' does not accept the --backgroundColor and --scale flags md-render
  ;; passes to the Mermaid CLI.
  (md-render-mermaid-enabled nil)
  (md-render-cache-directory (expand-file-name "md-render/" cat-cache-dir))
  :major-transient
  (md-mode
   (:description (+with-icon "nf-cod-markdown" nil " Markdown"))
   ["Mode"
    ("v" "rendered view" md-mode-toggle-markup)
    ("t" "toc" md-mode-toggle-toc :transient t)]))

(use-package markdown-mode
  :font-rule (prose
             :faces ((markdown-blockquote-face decorative)
                     (markdown-code-face code)
                     (markdown-gfm-checkbox-face mono)
                     (markdown-header-face-* heading
                                              :height 1.6
                                              :height-step -0.075
                                              :weight bold
                                              :weight-step -0.5)
                     (markdown-inline-code-face code)
                     (markdown-language-info-face code :height 0.9)
                     (markdown-language-keyword-face code :height 0.9)
                     (markdown-link-face prose :weight semi-bold)
                     (markdown-markup-face code :height 0.9)
                     (markdown-math-face table)
                     (markdown-metadata-key-face metadata-label :height 0.9)
                     (markdown-metadata-value-face metadata-value :height 0.9)
                     (markdown-pre-face code)
                     (markdown-reference-face metadata-label)
                     (markdown-table-face table)
                     (markdown-url-face metadata-value :height 0.9)))
  :pin melpa-stable
  :mode ("README\\.md\\'" . gfm-mode)
  :custom
  (markdown-command "pandoc")
  (markdown-fontify-code-blocks-natively t)
  :config
  (advice-add 'markdown-fontify-code-block-natively :after
              #'cat/markdown-fontify-code-font-role))

(use-package md-babel
  :vc (:url "https://github.com/md-babel/md-babel.el")
  :demand t
  :after markdown-mode
  :bind
  (:map markdown-mode-command-map
        ("C-c" . md-babel-execute-block-at-point))
  :config
  (setq md-babel-path (executable-find "md-babel")))

(use-package markdown-xwidget
  :vc (:url "https://github.com/cfclrk/markdown-xwidget")
  :demand t
  :after markdown-mode
  :bind
  (:map markdown-mode-command-map
        ("x" . markdown-xwidget-preview-mode))
  :config
  (add-hook 'cat-theme-refresh-hook #'markdown-xwidget-auto-theme)
  (markdown-xwidget-auto-theme))

(use-package grip-mode
  :delight (grip-mode (:eval (+with-icon "nf-cod-open_preview" " ")))
  :demand t
  :after markdown-mode
  :bind
  (:map markdown-mode-command-map
        ("g" . grip-mode))
  :custom
  (grip-command 'auto))
