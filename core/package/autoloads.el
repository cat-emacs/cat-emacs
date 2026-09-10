;; -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'package)
(require 'package-vc)

(defvar cat-package--quickstart-needs-refresh nil
  "Non-nil when a deferred `package-quickstart-refresh' is pending.")

(defun cat-package--without-quickstart-refresh (function)
  "Call FUNCTION without regenerating `package-quickstart-file'.
package.el rebuilds and byte-compiles that concatenated autoload file
after every install or deletion.  Remember whether a refresh was
requested so the caller can do it once."
  (cl-letf (((symbol-function 'package--quickstart-maybe-refresh)
             (lambda ()
               (setq cat-package--quickstart-needs-refresh t))))
    (funcall function)))

(defun cat-package--refresh-quickstart (&optional force)
  "Regenerate the quickstart file to match the installed packages.
Refresh when FORCE is non-nil or a deferred refresh is pending.
package.el refreshes it after installs and deletions, but not after
`package-vc-upgrade-all', and the file must be created once initially."
  (when (and (bound-and-true-p package-quickstart)
             (or force cat-package--quickstart-needs-refresh))
    (setq cat-package--quickstart-needs-refresh nil)
    (package-quickstart-refresh)))

(defun cat-package--file-seconds (file)
  "Return the modification time of FILE in seconds, or nil when absent."
  (when-let* ((attributes (file-attributes file)))
    (float-time (file-attribute-modification-time attributes))))

(defun cat-package--newest-source-seconds (dir)
  "Return the newest modification time among Lisp sources in DIR."
  (let (newest)
    (dolist (file (directory-files dir t "\\.el\\'" t) newest)
      (unless (string-match-p "\\(?:-autoloads\\|-pkg\\)\\.el\\'" file)
        (let ((seconds (cat-package--file-seconds file)))
          (when (and seconds (or (null newest) (> seconds newest)))
            (setq newest seconds)))))))

(defun cat-package--lisp-dir (pkg-desc)
  "Return the directory holding the Lisp sources of PKG-DESC.
A VC package specification may place them in a subdirectory of the
checkout."
  (let ((dir (package-desc-dir pkg-desc)))
    (or (and (package-vc-p pkg-desc)
             (ignore-errors (package-vc--checkout-dir pkg-desc 'lisp-dir)))
        dir)))

(defun cat-package--autoloads-indirection (name pkg-dir lisp-dir)
  "Write the autoload indirection for NAME from PKG-DIR to LISP-DIR.
`package-vc' puts the generated file next to the Lisp sources and leaves
a single `load' form in the package directory."
  (let ((auto-name (format "%s-autoloads.el" name)))
    (write-region
     (concat
      ";; Autoload indirection for package-vc -*- lexical-binding: t -*-\n\n"
      (prin1-to-string
       `(load ,(if (file-in-directory-p lisp-dir pkg-dir)
                   `(expand-file-name
                     ,(file-relative-name
                       (expand-file-name auto-name lisp-dir)
                       pkg-dir)
                     (or (and load-file-name
                              (file-name-directory load-file-name))
                         (car load-path)))
                 (expand-file-name auto-name lisp-dir)))))
     nil (expand-file-name auto-name pkg-dir))))

(defun cat-package--stale-autoloads-p (pkg-desc)
  "Return non-nil when the autoload file of PKG-DESC predates its sources.
`package-vc' regenerates autoloads only while upgrading, so a working
tree updated by any other means keeps autoloads that omit newly added
cookies.  A missing file counts as stale, including the indirection that
points at a `:lisp-dir' subdirectory."
  (when-let* ((pkg-dir (package-desc-dir pkg-desc))
              ((stringp pkg-dir))
              ((file-directory-p pkg-dir))
              (lisp-dir (cat-package--lisp-dir pkg-desc))
              ((file-directory-p lisp-dir))
              (newest (cat-package--newest-source-seconds lisp-dir)))
    (let* ((auto-name (format "%s-autoloads.el"
                              (package-desc-name pkg-desc)))
           (generated (cat-package--file-seconds
                       (expand-file-name auto-name lisp-dir))))
      (or (null generated)
          (> newest generated)
          ;; The indirection must exist for the generated file to load.
          (not (file-exists-p (expand-file-name auto-name pkg-dir)))))))

(defun cat-package--quickstart-seconds ()
  "Return the modification time of the loaded quickstart file."
  (when (bound-and-true-p package-quickstart-file)
    (let ((compiled (concat package-quickstart-file "c")))
      ;; `package-activate-all' prefers the byte-compiled file.
      (or (cat-package--file-seconds compiled)
          (cat-package--file-seconds package-quickstart-file)))))

(defun cat-package--stale-quickstart-p ()
  "Return non-nil when the quickstart file predates any autoload file.
The quickstart file inlines every autoload file, so regenerating one
without refreshing it keeps the superseded copy in effect."
  (when-let* ((generated (cat-package--quickstart-seconds)))
    (catch 'stale
      (dolist (entry package-alist)
        (dolist (pkg-desc (cdr entry))
          (when-let* ((dir (cat-package--lisp-dir pkg-desc))
                      ((stringp dir))
                      (file (expand-file-name
                             (format "%s-autoloads.el"
                                     (package-desc-name pkg-desc))
                             dir))
                      (seconds (cat-package--file-seconds file)))
            (when (> seconds generated)
              (throw 'stale t))))))))

(defun cat-package--regenerate-autoloads (name pkg-dir lisp-dir file)
  "Rebuild autoload FILE for package NAME in LISP-DIR from scratch.
`loaddefs-generate' keeps the header of an existing file and appends to
it, so a file missing the `load-path' header would never regain it.
Stage the removal so a failed generation cannot destroy a usable file.
Restore the PKG-DIR indirection when the sources live elsewhere."
  (let ((backup (and (file-exists-p file) (make-temp-file "cat-autoloads-")))
        (succeeded nil))
    (unwind-protect
        (progn
          (when backup
            (copy-file file backup t t)
            (delete-file file))
          (package-generate-autoloads name lisp-dir)
          (unless (file-equal-p lisp-dir pkg-dir)
            (cat-package--autoloads-indirection name pkg-dir lisp-dir))
          (setq succeeded t))
      (when backup
        (if succeeded
            (delete-file backup)
          (copy-file backup file t t)
          (delete-file backup))))))

(defun cat-package-regenerate-stale-autoloads (&optional skip-quickstart)
  "Regenerate package autoload files that predate their own sources.
Load each regenerated file, because `package-activate-all' has already
applied the superseded definitions before core initialization.  Refresh
the quickstart file when it no longer covers every autoload file, unless
SKIP-QUICKSTART is non-nil because the caller refreshes it anyway.
Return the list of packages whose autoloads were regenerated."
  (interactive)
  (let (regenerated)
    (dolist (entry package-alist)
      (dolist (pkg-desc (cdr entry))
        (when (cat-package--stale-autoloads-p pkg-desc)
          (let* ((name (package-desc-name pkg-desc))
                 (pkg-dir (package-desc-dir pkg-desc))
                 (lisp-dir (cat-package--lisp-dir pkg-desc))
                 (file (expand-file-name (format "%s-autoloads.el" name)
                                         lisp-dir)))
            (condition-case err
                (progn
                  (cat-package--regenerate-autoloads
                   name pkg-dir lisp-dir file)
                  (load file nil 'nomessage)
                  (push name regenerated))
              (error
               (message "Could not regenerate autoloads for %s: %s"
                        name (error-message-string err))))))))
    (setq regenerated (nreverse regenerated))
    (when regenerated
      (message "Regenerated stale autoloads: %s"
               (mapconcat #'symbol-name regenerated " ")))
    (when (and (not skip-quickstart)
               (or regenerated (cat-package--stale-quickstart-p)))
      (cat-package--refresh-quickstart t))
    regenerated))

(provide 'cat-package-autoloads)
