;;; custom.el --- Default Cat Emacs custom settings -*- lexical-binding: t; -*-

;;; Commentary:

;; This file is the fallback Custom file for Cat Emacs.  User customizations
;; should live in ~/.config/cat-emacs/custom.el.

;;; Code:

(custom-set-variables
 '(logview-additional-timestamp-formats
   '(("LogCat"
      (java-pattern . "MM-dd HH:mm:ss.SSS"))
     ("LogUtil"
      (java-pattern . "HH:mm:ss.SSS"))
     ("sing-box"
      (java-pattern . "Z yyyy-MM-dd HH:mm:ss")))
   t)
 '(logview-additional-level-mappings
   '(("LogCat"
      (error "E" "F" "S")
      (warning "W")
      (information "I")
      (debug "D")
      (trace "V"))
     ("Xray"
      (error "Error")
      (warning "Warning")
      (information "Info")
      (debug "Debug"))
     ("Rclone"
      (error "ERROR" "CRITICAL")
      (warning "NOTICE")
      (information "INFO")
      (debug "DEBUG")))
   t)
 '(logview-additional-submodes
   '(("LogCat"
      (format . "TIMESTAMP IGNORED THREAD LEVEL NAME: MESSAGE")
      (levels . "LogCat")
      (timestamp "LogCat"))
     ("LogUtil"
      (format . "TIMESTAMP LEVEL/NAME [THREAD, IGNORED]: MESSAGE")
      (levels . "LogCat")
      (timestamp "LogUtil"))
     ("Xray"
      (format . "TIMESTAMP [LEVEL]<<RX:THREAD: \\[[^]]+\\] \\| >>NAME: MESSAGE")
      (levels . "Xray"))
     ("sing-box"
      (format . "TIMESTAMP LEVEL <<RX:IGNORED:\\[\\|>><<RX:THREAD:[0-9]+\\|>><<RX:IGNORED: [^]]+\\]\\|>><<RX:NAME:[^:]+\\: \\|>>MESSAGE")
      (levels . "SLF4J")
      (timestamp "sing-box"))
     ("Rclone"
      (format . "TIMESTAMP LEVEL<<RX:IGNORED: *:>><<RX:THREAD:.+?: \\| >>MESSAGE")
      (levels . "Rclone")))
   t)
 '(gptel-model-updater-backends
   '(gptel--gemini gptel--llama gptel--mlx gptel--ollama
                   gptel--openrouter))
 '(gptel-model-updater-external-targets
   '((gptel-magit-backend gptel-magit-model "GPTel-Magit"
                          ("OpenRouter:openai/gpt-oss-120b:free"))
     (gptel-forge-prs-backend gptel-forge-prs-model "GPTel-Forge-Prs"
                              ("OpenRouter:openai/gpt-oss-120b:free"))))
 '(gptel-model-updater-models '("OpenRouter:auto"))
 '(use-short-answers t)
 '(package-native-compile t)
 '(system-packages-use-sudo nil))

;;; custom.el ends here
