;; -*- lexical-binding: t; -*-

(mode-transient-define-prefix cat-git-misc ()
  :description (+with-icon "nf-md-git" nil " Git misc"))

(use-package git-timemachine
  :delight (git-timemachine-mode
            (:eval (+with-icon "nf-cod-history" " ")))
  :transient
  (cat-git-misc
   ["Git History"
    ("t" "git timemachine" git-timemachine-toggle)]))

(use-package git-link
  :custom
  (git-link-open-in-browser t)
  :transient
  (cat-git-misc
   ["Git Link"
    ("l" "git link" git-link-dispatch)]))

(use-package code-review
  :vc (code-review :url "https://github.com/doomelpa/code-review")
  :transient
  (cat-git-misc
   ["Code Review"
    ("r" "code review forge" code-review-forge-pr-at-point)
    ("R" "code review start" code-review-start)]))

(use-package blame-reveal
  :cat blame
  :vc (:url "https://github.com/LuciusChen/blame-reveal")
  :commands (blame-reveal-mode blame-reveal-global-mode)
  :config
  (require 'blame-reveal-recursive)
  (require 'blame-reveal-focus)
  (require 'blame-reveal-transient)
  :transient
  (cat-git-misc
   ["Blame Reveal"
    ("b" "toggle buffer" blame-reveal-mode)
    ("B" "toggle globally" blame-reveal-global-mode)]))
