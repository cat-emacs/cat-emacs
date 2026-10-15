;; -*- lexical-binding: t; -*-

(use-package android-adb
  :vc (:url "https://github.com/cat-emacs/android-adb")
  :minor-transient
  (android-mode
   ["ADB"
    ("a" "adb menu" android-adb)]))

(use-package android-project
  :vc (:url "https://github.com/cat-emacs/android-project")
  :custom
  (android-project-cache-directory (concat cat-cache-dir "android")))

(use-package android-scrcpy
  :vc (:url "https://github.com/cat-emacs/android-scrcpy")
  :commands (android-scrcpy android-scrcpy-start)
  :minor-transient
  (android-mode
   ["Device"
    ("s" "screen mirror" android-scrcpy)]))

(use-package android-mode
  :vc (:url "https://github.com/cat-emacs/android-mode")
  :delight (android-mode (:eval (+with-icon "nf-md-android" " ")))
  :init
  (defun cat/android-mode ()
    (when (android-root) (android-mode t)))
  :hook ((find-file dired-mode) . cat/android-mode)
  :minor-transient
  (android-mode
   ["Start"
    ("a" "start app" android-start-app)
    ("r" "run" android-run)
    ("v" "virtual devices" android-avd)]
   ["Build"
    ("c" "build" android-gradle-build)
    ("C" "clean" android-gradle-clean)
    ("t" "test" android-gradle-test)
    ("i" "install" android-gradle-install)
    ("u" "uninstall" android-gradle-uninstall)
    ("f" "flavors" android-print-flavor)
    ("R" "refresh" android-refresh-flavors)]))

(use-package compose-preview
  :vc (:url "https://github.com/cat-emacs/compose-preview")
  :commands compose-preview
  :custom
  (compose-preview-cache-directory
   (file-name-as-directory (expand-file-name "compose-preview" cat-cache-dir)))
  :minor-transient
  (android-mode
   ["Compose"
    ("p" "preview" compose-preview)]))

(use-package elogcat
  :vc (:url "https://github.com/cat-emacs/elogcat.el")
  :minor-transient
  (android-mode
   ["Log"
    ("l" "elogcat" elogcat)])
  :config
  (add-hook 'elogcat-mode-hook #'meow-motion-mode)
  (add-hook 'elogcat-mode-hook #'cat/enable-doom-modeline-minor-modes))
