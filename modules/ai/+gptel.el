;; -*- lexical-binding: t; -*-

(defvar cat-prompt-dir (cat-config-directory "prompt")
  "Directory for prompt templates.")

(defcustom cat-gptel-forge-prs-prompt-file nil
  "Prompt template used by gptel-forge-prs.
When nil, use the conventional prompt provided by gptel-forge-prs.  A relative
file name is resolved from the user or fallback template directory by
`cat-config-file'."
  :type '(choice (const :tag "Use the conventional prompt" nil)
                 (file :tag "Prompt template"))
  :group 'cat-emacs)

(defun cat/gptel-api-key-from-pass (path &optional field)
  "Return a function that reads FIELD from the pass entry at PATH."
  (lambda ()
    (require 'password-store)
    (or (if field
            (password-store-get-field path field)
          (password-store-get path))
        (user-error "No GPTel API key found in pass entry %s" path))))

(defcustom cat-gptel-backends
  '((gptel--gemini gptel-make-gemini "Gemini"
     :models nil :key gptel-api-key :stream t)
    (gptel--openrouter gptel-make-openai "OpenRouter"
     :models nil
     :host "openrouter.ai"
     :key gptel-api-key
     :endpoint "/api/v1/chat/completions"
     :stream t)
    (gptel--mlx gptel-make-openai "MLX"
     :models nil
     :host "localhost:8000"
     :protocol "http"
     :stream t)
    (gptel--llama gptel-make-openai "llama.cpp"
     :models nil
     :host "localhost:8080"
     :protocol "http"
     :stream t)
    (gptel--ollama gptel-make-ollama "Ollama"
     :stream t))
  "GPTel backends to register after gptel loads.
Each element is (SYMBOL CONSTRUCTOR NAME . PLIST).  A saved customization
replaces this standard value entirely.  The two sets share menu names but
not symbols, so merging would register both.

The saved expression is evaluated when this option is defined, before
gptel loads, so every PLIST value is literal data.  :auth is (PATH FIELD)
or (PATH); registration turns it into the :key pass reader."
  :type '(repeat sexp)
  :group 'cat-emacs)

(defun cat/gptel-register-backends (specs)
  "Register each GPTel backend in SPECS.
Each element is (SYMBOL CONSTRUCTOR NAME . PLIST).  :auth (PATH FIELD)
becomes the :key reader from `cat/gptel-api-key-from-pass' and is not
passed to the constructor.  See `cat-gptel-backends'."
  (dolist (spec specs)
    (let ((plist (nthcdr 3 spec))
          (args nil)
          (auth nil))
      (while plist
        (if (eq (car plist) :auth)
            (setq auth (cadr plist))
          (setq args (plist-put args (car plist) (cadr plist))))
        (setq plist (cddr plist)))
      (when auth
        (setq args (plist-put args :key
                              (apply #'cat/gptel-api-key-from-pass auth))))
      (set (car spec) (apply (cadr spec) (nth 2 spec) args)))))

(use-package gptel-model-updater
  :vc (:url "https://github.com/cat-emacs/gptel-model-updater")
  :hook
  (cat-idle-preload . gptel-model-updater-update-all)
  :custom
  (gptel-model-updater-metadata-overwrite-existing t)
  :transient
  (cat-vibe
   ["GPTel"
    ("u" "updater" gptel-model-updater-transient)]))

(use-package gptel
  :delight (gptel-mode (:eval (+with-icon "nf-md-magic_staff" " ")))
  :custom
  (gptel-expert-commands t)
  (gptel-default-mode 'org-mode)
  :transient
  (cat-vibe
   ["GPTel"
    ("g" "gptel" gptel)])
  :config
  (cat/gptel-register-backends cat-gptel-backends))

(use-package gptel-magit
  :vc (:url "https://github.com/roife/gptel-magit")
  :hook (magit-mode . gptel-magit-install)
  :custom
  (gptel-magit-commit-prompt
   (gptel-prompts-poet (cat-config-file "prompt/git-commit.yml.j2")))
  :config
  (defun cat/gptel-magit-minimize-reasoning (generate &rest args)
    "Call GENERATE with ARGS and minimal OpenRouter reasoning."
    ;; The symbol exists only when the openrouter alias resolved.
    (let ((gptel--request-params
           (if (and (boundp 'gptel--openrouter)
                    (eq (or gptel-magit-backend gptel-backend)
                        gptel--openrouter))
               (plist-put (copy-sequence gptel--request-params)
                          :reasoning '(:exclude t :effort "minimal"))
             gptel--request-params)))
      (apply generate args)))
  (advice-add 'gptel-magit--generate :around
              #'cat/gptel-magit-minimize-reasoning))

(use-package gptel-forge-prs
  :hook (forge-post-mode . gptel-forge-prs-install)
  :custom
  (gptel-forge-prs-pr-prompt
   (if cat-gptel-forge-prs-prompt-file
       (gptel-prompts-poet
        (cat-config-file cat-gptel-forge-prs-prompt-file))
     gptel-forge-prs-prompt-conventional)))

(use-package gptel-prompts
  :vc (:url "https://github.com/jwiegley/gptel-prompts")
  :commands #'gptel-prompts-poet
  :custom
  (gptel-prompts-directory cat-prompt-dir)
  (gptel-prompts-template-variables
   `(("user_name" . ,(or (getenv "USER") (user-login-name)))
     ("emacs_version" . ,(format "Emacs %s" emacs-version))
     ("git_commit_summary_max_length" . ,git-commit-summary-max-length)))
  :config
  (gptel-prompts-update)
  (gptel-prompts-add-update-watchers))

(use-package templatel)
