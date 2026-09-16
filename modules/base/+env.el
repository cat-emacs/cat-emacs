;; -*- lexical-binding: t; -*-

(use-package exec-path-from-shell
  :when
  (and (not IS-CI)
       (not (getenv "TERM_PROGRAM")))
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-variables
   '("PATH" "MANPATH" "JAVA_HOME" "HOMEBREW_PREFIX" "LIBRARY_PATH"
     "FEISHU_PROJECT_KEY" "FEISHU_PROJECT_USER_KEY"))
  :config
  (when IS-MAC
    ;; Emacs.app injects its build-time library paths into child processes.
    (setenv "LIBRARY_PATH" nil))
  (exec-path-from-shell-initialize))
