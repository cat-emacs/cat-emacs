;; -*- lexical-binding: t; -*-

(defvar cat-dark-mode-hook nil)
(defvar cat-light-mode-hook nil)
(defvar cat-theme-refresh-hook nil)

(cond
 ((featurep 'nano)
  (add-hook 'cat-dark-mode-hook #'nano-theme-set-dark)
  (add-hook 'cat-light-mode-hook #'nano-theme-set-light)
  (add-hook 'cat-theme-refresh-hook #'nano-refresh-theme))
 ((featurep '+nano)
  (add-hook 'cat-dark-mode-hook #'nano-dark)
  (add-hook 'cat-light-mode-hook #'nano-light))
 ((featurep '+doom)
  (add-hook 'cat-dark-mode-hook #'doom-dark-theme)
  (add-hook 'cat-light-mode-hook #'doom-light-theme)))

(defun cat-dark-mode-p ()
  "Return non-nil when the current system appearance is dark."
  (cond
   (IS-WSL
    (let ((theme (getenv "GTK_THEME")))
      (and theme (string-match-p "-Darker" theme))))
   (IS-WINDOWS
    (let ((value (ignore-errors
                   (string-trim
                    (shell-command-to-string
                     "powershell.exe -WindowStyle Hidden -C Get-ItemPropertyValue -Path HKCU://Software/Microsoft/Windows/CurrentVersion/Themes/Personalize -Name AppsUseLightTheme")))))
      (and value (string= "0" value))))
   (IS-LINUX
    (let ((theme (ignore-errors
                   (shell-command-to-string
                    "gsettings get org.gnome.desktop.interface gtk-theme"))))
      (and theme (string-match-p "-dark" theme))))
   ((and IS-MACPORT (display-graphic-p))
    (string= (plist-get (mac-application-state) :appearance)
             "NSAppearanceNameDarkAqua"))
   ((and IS-MACPLUS (display-graphic-p))
    (eq 'dark ns-system-appearance))
   (IS-MAC
    (let ((style (ignore-errors
                   (string-trim
                    (shell-command-to-string
                     "defaults read -g AppleInterfaceStyle")))))
      (and style (string= "Dark" style))))))

(defun cat-load-theme (&optional color)
  "Load the Cat theme for COLOR, or match the current system appearance.
COLOR may be `dark' or `light'.  Unknown COLOR values fall back to
`cat-dark-mode-p', so appearance hooks that pass platform-specific
arguments still detect correctly."
  (interactive)
  (cat-benchmark 'beg "load theme.")
  (mapc #'disable-theme custom-enabled-themes)
  (let ((appearance
         (if (memq color '(dark light))
             color
           (if (cat-dark-mode-p) 'dark 'light))))
    (if (eq appearance 'dark)
        (run-hooks 'cat-dark-mode-hook)
      (run-hooks 'cat-light-mode-hook)))
  (run-hooks 'cat-theme-refresh-hook)
  (cat-benchmark 'end "load theme."))

(unless (or noninteractive (daemonp))
  (add-hook 'after-init-hook #'cat-load-theme))
(cond
 (IS-MACPORT
  (add-hook 'mac-effective-appearance-change-hook #'cat-load-theme))
 (IS-MACPLUS
  (add-hook 'ns-system-appearance-change-functions #'cat-load-theme)))
(when (daemonp)
  (add-hook 'server-after-make-frame-hook #'cat-load-theme))
