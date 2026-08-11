;; -*- lexical-binding: t; -*-

(use-package prosody
  :vc (:url "https://github.com/cat-emacs/prosody")
  :demand t
  :custom
  (prosody-stacks
   '((fallback
      :symbol ("Apple Symbols" "Symbola")
      :mathematical ("STIX Two Math"
                     "DejaVu Math TeX Gyre"
                     "Noto Sans Math")
      :emoji ("Apple Color Emoji"))
     (sans-serif
      :extends fallback
      :ascii ("Inter" "Avenir Next" "DejaVu Sans")
      :cjk ("LXGW Neo XiHei" "Source Han Sans SC" "PingFang SC"
            "Noto Sans CJK SC" "Hiragino Sans GB" "Microsoft YaHei"))
     (serif
      :extends fallback
      :ascii ("EB Garamond" "Athelas" "Iowan Old Style" "Baskerville"
              "Roboto Serif" "DejaVu Serif" "Georgia")
      :cjk ("Zhuque Fangsong (technical preview)" "LXGW Neo ZhiSong"
            "Source Han Serif SC VF" "Songti SC" "STFangsong"
            "LXGW WenKai" "Noto Serif CJK SC"))
     (slab-serif
      :extends serif
      :ascii ("Roboto Slab" "American Typewriter"))
     (cursive
      :extends serif
      :ascii ("Snell Roundhand" "Apple Chancery" "Zapfino")
      :cjk ("Xingkai SC" "Kaiti SC" "STKaiti"))
     (quasi-proportional
      :extends serif
      :ascii ("Iosevka Etoile" "Iosevka Aile")
      :cjk ("Pengli WenKai" "LXGW WenKai"))
     (monospace-narrow
      :extends fallback
      :ascii ("Iosevka" "Iosevka Term")
      :symbol ("Iosevka")
      :cjk ("LXGW WenKai Mono" "Sarasa Mono SC"))
     (monospace-align
      :extends monospace-narrow
      :ascii ("Maple Mono")
      :cjk ("Maple Mono CN"))
     (monospace-code
      :extends monospace-align
      :ascii ("Source Code Pro"))
     (monospace-sans-serif
      :extends monospace-narrow
      :ascii ("Roboto Mono" "DejaVu Sans Mono"))))
  (prosody-roles
   `((default :stack monospace-narrow
              :height ,(if (eq system-type 'darwin) 160 140))
     (title :stack serif :weight heavy :height 2.0)
     (heading :stack serif :height 1.5)
     (body :stack monospace-sans-serif)
     (documentation :extends body)
     (prose :stack quasi-proportional)
     (decorative :stack cursive)
     (ui :stack sans-serif)
     (metadata-label :stack monospace-sans-serif)
     (metadata-value :stack monospace-narrow)
     (mono :stack monospace-sans-serif)
     (code :stack monospace-code)
     (table :stack monospace-align)
     (code-jvm :extends code :fonts ("JetBrains Mono"))
     (code-python :extends code :fonts ("Cascadia Code"))
     (code-diagram :extends code :fonts ("Fira Code"))
     (code-apple :extends code :fonts ("SF Mono"))
     (code-config :extends code :fonts ("IBM Plex Mono"))
     (terminal :extends mono :fonts ("Menlo"))))
  (prosody-presets
   '((modern
      (title :stack sans-serif :fonts ("Inter Display") :weight bold)
      (heading :stack sans-serif :fonts ("Inter") :weight semi-bold)
      (body :stack sans-serif :fonts ("Inter"))
      (prose :stack sans-serif :fonts ("Inter"))
      (decorative :stack sans-serif :fonts ("Inter") :slant italic)
      (ui :stack sans-serif :fonts ("Inter"))
      (metadata-label :stack sans-serif :fonts ("Inter")
                      :weight semi-bold))
     (classical
      (title :stack serif :fonts ("EB Garamond"))
      (heading :stack serif :fonts ("Athelas"))
      (body :stack serif :fonts ("Iowan Old Style"))
      (prose :stack serif :fonts ("Iowan Old Style"))
      (decorative :stack cursive)
      (metadata-label :stack slab-serif))
     (technical
      (title :stack sans-serif :fonts ("DIN Condensed") :weight bold)
      (heading :stack sans-serif :fonts ("Avenir Next")
               :weight semi-bold)
      (body :stack serif :fonts ("STIX Two Text"))
      (prose :stack serif :fonts ("STIX Two Text"))
      (decorative :stack slab-serif :fonts ("Roboto Slab"))
      (ui :stack sans-serif :fonts ("Avenir Next"))
      (metadata-label :stack sans-serif :fonts ("Avenir Next")
                      :weight semi-bold)
      (mono :stack monospace-narrow :fonts ("SF Mono"))
      (code :stack monospace-code :fonts ("SF Mono")))))
  (prosody-mode-rules
   '((:modes (nxml-mode sgml-mode toml-ts-mode conf-mode)
             :font code-config)
     (:modes prog-mode :font code)
     (:modes text-mode :font prose)))
  (use-default-font-for-symbols (not STIPPLE-COMPATIBLE-P))
  :config
  (require 'prosody-use-package)
  (require 'prosody-nerd-icons)
  (add-hook 'cat-theme-refresh-hook #'prosody-setup))

(if IS-MACPORT
    (mac-auto-operator-composition-mode)
  (use-package ligature
    :hook (after-init . global-ligature-mode)
    :config
    (ligature-set-ligatures 't '("www"
                                 "[TODO]" "todo))"
                                 "[FIXME]" "fixme))"
                                 "[DEBUG]" "[INFO]" "[WARN]" "[ERROR]"))
    (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
    (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                         ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                         "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                         "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                         "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                         "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                         "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                         "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                         ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                         "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                         "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                         "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                         "\\\\" "://"))))

(use-package nerd-icons-completion
  :hook (after-init . nerd-icons-completion-mode))

(setq face-font-rescale-alist
      '(("Noto Serif Thai" . 0.4)
        ("Noto Naskh Arabic" . 0.4)
        ("Math" . 0.7)
        ("Noto Sans .+" . 0.7)
        ("Apple Color Emoji" . 0.8)
        ("Sinhala Sangam MN" . 0.8)
        ("Apple Symbols" . 0.9)
        ("Apple Chancery" . 0.9)
        ("Noto Serif .+" . 0.9)
        ("Source Han .+" . 0.9)
        ("Zhuque Fangsong .+" . 0.9)
        ("-cdac$" . 1.3)))
