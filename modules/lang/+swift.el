;; -*- lexical-binding: t; -*-

(prosody-register 'objc '(:modes objc-mode :font code-apple))

(use-package swift-mode
  :font-rule code-apple
  :unless EMACS29+)

(use-package swift-ts-mode
  :font-rule code-apple
  :when EMACS29+)

(use-package ob-swiftui
  :demand t
  :after org
  :config
  (ob-swiftui-setup))
