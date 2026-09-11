;; -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'package)
(require 'package-vc)
(require 'seq)
(require 'subr-x)

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

(defun cat-package--autoloads-file (pkg-desc)
  "Return the autoload file `package-vc' generated for PKG-DESC, or nil.
A package specification may place the Lisp sources in a subdirectory, in
which case the generated file sits beside them and the package directory
holds only an indirection.  Locate the real file instead of deriving the
layout, so a package installed from an unusual checkout is left alone."
  (when-let* ((pkg-dir (package-desc-dir pkg-desc))
              ((stringp pkg-dir))
              ((file-directory-p pkg-dir))
              (auto-name (format "%s-autoloads.el"
                                 (package-desc-name pkg-desc))))
    (let* ((lisp-dir (and (package-vc-p pkg-desc)
                          (ignore-errors
                            (package-vc--checkout-dir pkg-desc 'lisp-dir))))
           (candidates (delq nil (list (and lisp-dir
                                            (expand-file-name auto-name
                                                              lisp-dir))
                                       (expand-file-name auto-name pkg-dir)))))
      (seq-find #'file-exists-p candidates))))

(defun cat-package--stale-compiled-files (pkg-desc file)
  "Return superseded byte-compiled autoload files for PKG-DESC and FILE.
`load' prefers a byte-compiled file over a newer source, so a stale copy
keeps the previous definitions in effect.  Cover the package directory as
well, which holds the indirection when sources live in a subdirectory."
  (let ((candidates (list (concat file "c")))
        (pkg-dir (package-desc-dir pkg-desc)))
    (when (stringp pkg-dir)
      (let ((indirection (expand-file-name
                          (format "%s-autoloads.el"
                                  (package-desc-name pkg-desc))
                          pkg-dir)))
        (unless (equal indirection file)
          (push (concat indirection "c") candidates))))
    (seq-filter
     (lambda (compiled)
       (when-let* ((compiled-seconds (cat-package--file-seconds compiled))
                   (source (string-remove-suffix "c" compiled))
                   (source-seconds (cat-package--file-seconds source)))
         (> source-seconds compiled-seconds)))
     candidates)))

(defun cat-package--stale-autoloads-p (pkg-desc)
  "Return non-nil when the autoload file of PKG-DESC predates its sources.
`package-vc' regenerates autoloads only while upgrading, so a working
tree updated by any other means keeps autoloads that omit newly added
cookies."
  (when-let* ((file (cat-package--autoloads-file pkg-desc))
              (generated (cat-package--file-seconds file))
              ;; Regenerate only beside the sources.  The package directory of
              ;; a `:lisp-dir' package holds an indirection that must survive.
              (newest (cat-package--newest-source-seconds
                       (file-name-directory file))))
    (> newest generated)))

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
          (when-let* ((file (cat-package--autoloads-file pkg-desc))
                      (seconds (cat-package--file-seconds file)))
            (when (> seconds generated)
              (throw 'stale t))))))))

(defun cat-package--regenerate-autoloads (pkg-desc name file)
  "Rebuild autoload FILE for PKG-DESC named NAME beside its sources.
`loaddefs-generate' keeps the header of an existing file and appends to
it, so a file missing the `load-path' header would never regain it.
Stage the removal so a failed generation cannot destroy a usable file."
  (let* ((dir (file-name-directory file))
         (backup (and (file-exists-p file) (make-temp-file "cat-autoloads-")))
         (succeeded nil))
    (unwind-protect
        (progn
          (when backup
            (copy-file file backup t t)
            (delete-file file))
          (package-generate-autoloads name dir)
          (setq succeeded t))
      (when backup
        (if succeeded
            (delete-file backup)
          (copy-file backup file t t)
          (delete-file backup))))))

(defun cat-package-regenerate-stale-autoloads (&optional skip-quickstart)
  "Repair package autoload files that are not in effect.
Rebuild the ones that predate their sources and drop byte-compiled copies
that `load' would prefer over a newer source.  Load each rebuilt file,
because `package-activate-all' has already applied the superseded
definitions before core initialization.  Refresh the quickstart file when
it no longer covers every autoload file, unless SKIP-QUICKSTART is
non-nil because the caller refreshes it anyway.  Return the list of
packages that needed repair."
  (interactive)
  (let (repaired)
    (dolist (entry package-alist)
      (dolist (pkg-desc (cdr entry))
        (when-let* ((file (cat-package--autoloads-file pkg-desc))
                    (name (package-desc-name pkg-desc)))
          (condition-case err
              (let ((changed nil))
                (when (cat-package--stale-autoloads-p pkg-desc)
                  (cat-package--regenerate-autoloads pkg-desc name file)
                  (setq changed t))
                ;; Deleting the compiled copy is a repair on its own: an
                ;; indirection has no sources to rebuild from.
                (dolist (compiled
                         (cat-package--stale-compiled-files pkg-desc file))
                  (delete-file compiled)
                  (setq changed t))
                (when changed
                  (load file nil 'nomessage)
                  (push name repaired)))
            (error
             (message "Could not repair autoloads for %s: %s"
                      name (error-message-string err)))))))
    (setq repaired (nreverse repaired))
    (when repaired
      (message "Repaired package autoloads: %s"
               (mapconcat #'symbol-name repaired " ")))
    (when (and (not skip-quickstart)
               (or repaired (cat-package--stale-quickstart-p)))
      (cat-package--refresh-quickstart t))
    repaired))

(provide 'cat-package-autoloads)
