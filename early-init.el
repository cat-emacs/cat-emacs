;; -*- lexical-binding: t; -*-

;;; startup
;; Defer GC and file-name handlers until startup finishes, then restore
;; them, keeping handlers registered during startup.
(let ((initial-gc-cons-threshold gc-cons-threshold)
      (initial-gc-cons-percentage gc-cons-percentage)
      (initial-file-name-handler-alist file-name-handler-alist))
  (setq gc-cons-threshold most-positive-fixnum
        gc-cons-percentage 0.6
        file-name-handler-alist nil)
  (add-hook 'emacs-startup-hook
            (lambda ()
              ;; gcmh owns the steady-state GC tuning when it is enabled.
              (unless (bound-and-true-p gcmh-mode)
                (setq gc-cons-threshold initial-gc-cons-threshold
                      gc-cons-percentage initial-gc-cons-percentage))
              (setq file-name-handler-alist
                    (delete-dups (append file-name-handler-alist
                                         initial-file-name-handler-alist))))))

;;; os
(defconst EMACS28+   (> emacs-major-version 27))
(defconst EMACS29+   (> emacs-major-version 28))
(defconst EMACS30+   (> emacs-major-version 29))
(defconst EMACS31+   (> emacs-major-version 30))
(defconst IS-MAC     (eq system-type 'darwin))
(defconst IS-MACPORT (functionp 'mac-application-state))
(defconst IS-MACPLUS (boundp 'ns-system-appearance))
(defconst IS-BSD     (or IS-MAC (eq system-type 'berkeley-unix)))
(defconst IS-LINUX   (eq system-type 'gnu/linux))
(defconst IS-ANDROID (string-equal system-type "android"))
(defconst IS-WINDOWS (memq system-type '(cygwin windows-nt ms-dos)))
(defconst IS-MINGW64 (and IS-WINDOWS (string-match "mingw64" (getenv "emacs_dir"))))
(defconst IS-WSL     (string-match-p "WSL2" operating-system-release))
(defconst IS-CI      (getenv "CI"))
(defconst STIPPLE-COMPATIBLE-P
  (not (or (and IS-MACPLUS (not EMACS31+))
           IS-WINDOWS
           (not EMACS30+))))

(defconst cat-emacs-name "Cat Emacs")

(when IS-CI
  (setq use-short-answers t)
  (message "%s is running on CI" cat-emacs-name))

;;; directory
(defconst cat-local-dir (concat user-emacs-directory ".local/"))
(defconst cat-assets-dir (concat user-emacs-directory "assets/"))
(defconst cat-cache-dir (concat cat-local-dir "cache/"))
(defconst cat-etc-dir (concat cat-local-dir "etc/"))

(defun +mkdir-p (dir)
  "Make directory for DIR if not exists."
  (unless (file-directory-p dir)
    (make-directory dir t)))

(+mkdir-p cat-local-dir)
(+mkdir-p cat-cache-dir)
(+mkdir-p cat-etc-dir)

;;; package
;; `package-activate-all' runs between early init and init, so quickstart
;; must be enabled here.  The file path matches the no-littering var
;; directory configured in modules/base/+package.el.
(setq package-quickstart t
      package-quickstart-file (concat cat-cache-dir "package-quickstart.el"))
;; The concatenated autoload file is large enough that native-compiling it
;; can exhaust CI runners; the byte-compiled file is sufficient.
;; `comp-run' defines this list, so attach after it loads.
(let ((quickstart-native-comp-deny
       (concat "\\`"
               (regexp-quote (expand-file-name package-quickstart-file)))))
  (if (boundp 'native-comp-jit-compilation-deny-list)
      (add-to-list 'native-comp-jit-compilation-deny-list
                   quickstart-native-comp-deny)
    (with-eval-after-load 'comp-run
      (add-to-list 'native-comp-jit-compilation-deny-list
                   quickstart-native-comp-deny))))

;;; ui
;; Strip bars from the initial frame before it is first drawn; the
;; corresponding modes are still synchronized in modules/base/+default.el.
(setq frame-inhibit-implied-resize t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(unless IS-ANDROID
  (push '(menu-bar-lines . 0) default-frame-alist))

;;; path
(when IS-ANDROID
  ;; Add Termux binaries to PATH environment
  (let ((termuxpath "/data/data/com.termux/files/usr/bin"))
    (setenv "PATH" (concat termuxpath ":" (getenv "PATH")))
    (push termuxpath exec-path)))

;;; benchmark
(defun cat-benchmark (pos &optional file)
  "Print the current time of load POS of FILE."
  (let ((file-name (abbreviate-file-name
                    (or file
                        load-file-name
                        buffer-file-name))))
    (message "%s %s of %s"
             (format-time-string "%T %3N")
             (upcase (symbol-name pos))
             file-name)))

;;; modifier-key
(cond
 (IS-MACPORT
  (setq mac-command-modifier 'meta
        mac-option-modifier 'meta
        mac-right-command-modifier 'super
        mac-right-option-modifier 'none))
 (IS-MAC
  (setq ns-command-modifier 'meta
        ns-option-modifier 'meta
        ns-right-command-modifier 'super
        ns-right-option-modifier 'none))
 (IS-WINDOWS
  (setq w32-lwindow-modifier 'super
        w32-rwindow-modifier 'super)))

(cat-benchmark 'end)
