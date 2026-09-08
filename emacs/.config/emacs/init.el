(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(setq scroll-margin 8
      scroll-conservatively 101
      scroll-preserve-screen-position t)

(setq inhibit-startup-message t
      make-backup-files nil)

(set-face-attribute 'default nil :font "JetBrains Mono-14:weight=regular")
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

;; generous line height gives multi-line blocks breathing room
(setq-default line-spacing 0.2)

;; balance vertical column alignment
(set-fringe-mode '(12 . 12))

(global-set-key (kbd "C-+") #'text-scale-increase)
(global-set-key (kbd "C-=") #'text-scale-increase)
(global-set-key (kbd "C--") #'text-scale-decrease)
(global-set-key (kbd "C-0") (lambda () (interactive) (text-scale-increase 0)))

(use-package server
  :config
  (unless (server-running-p)
    (server-start)))

(use-package clang-format
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'cc-mode
    (define-key c-mode-base-map (kbd "C-c f") #'clang-format-region)
    (define-key c-mode-base-map (kbd "C-c b") #'clang-format-buffer)))

(use-package cc-mode
  :mode ("\\.cppm\\'" . c++-mode))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(use-package gdscript-mode
  :ensure t
  :mode "\\.gd\\'"
  :hook (gdscript-mode . eglot-ensure)
  :custom
  (gdscript-eglot-version 4.6)
  :config
  (setq gdscript-godot-executable "/home/terra/.local/bin/Godot_v4.7.2-stable_linux.x86_64")
  (setq gdscript-gdformat-save-and-format t)
  (setq gdscript-use-tab-indents t))

(use-package corfu
  :ensure t
  :hook (prog-mode . corfu-mode)
  :init
  (setq corfu-auto t
        corfu-quit-no-match 'separator
        corfu-auto-delay 0.1
        corfu-auto-prefix 1))

(use-package flymake
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; enable maximum tree-sitter scope recognition globally
(setq treesit-font-lock-level 4)

(use-package c-ts-mode
  :mode ("\\.cppm\\'" . c++-ts-mode)
  :init
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  :custom
  (c-ts-mode-indent-style 'bsd)
  (c-ts-mode-indent-offset 4))

;; strip noisy mode-line lighters that truncate important context
(use-package diminish
  :ensure t
  :config
  (diminish 'which-key-mode)
  (diminish 'eldoc-mode)
  (diminish 'auto-revert-mode)
  (diminish 'diff-hl-mode)
  (diminish 'highlight-indent-guides-mode))

(use-package eglot
  :hook ((c-mode c++-mode c-ts-mode c++-ts-mode) . eglot-ensure)
  :init
  (setq eglot-events-buffer-config '(:size nil :format full))
  :config
  ;; strip blurry inline hints to eliminate irregular horizontal spacing
  (setq-default eglot-ignored-server-capabilities '(:inlayHintProvider))

  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode)
                 . ("clangd")))
  (add-to-list 'eglot-server-programs
               '(gdscript-mode . ("localhost" 6005))))

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c b") #'eglot-format-buffer)
  (add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1))))

(defun my/c-mode-setup ()
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

(add-hook 'c-mode-hook #'my/c-mode-setup)
(add-hook 'c++-mode-hook #'my/c-mode-setup)
(add-hook 'c-ts-mode-hook #'my/c-mode-setup)
(add-hook 'c++-ts-mode-hook #'my/c-mode-setup)

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package vertico
  :ensure t
  :custom
  (vertico-resize t)
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package consult
  :ensure t
  :init
  (setq consult-async-input-debounce 0.1
        consult-async-input-throttle 0.2
        consult-async-refresh-delay 0.15)
  :config
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-line
   :preview-key '(:debounce 0.2 any)))

(use-package aperture
  :vc (:url "https://github.com/mattsawyer77/aperture.el" :rev :newest)
  :after vertico
  :config
  (setq aperture-display 'child-frame
        aperture-child-frame-width 0.8
        aperture-child-frame-height 0.6
        aperture-child-frame-position 'center
        aperture-child-frame-border-width 1
        aperture-child-frame-parameters nil))

(use-package catppuccin-theme
  :ensure t
  :demand t
  :init
  (setq catppuccin-flavor 'mocha)
  ;; soft charcoal background avoids halation while maintaining crisp luminance
  (setq catppuccin-mocha-color-overrides
        '((base     . "#13131a")
          (mantle   . "#0f0f15")
          (crust    . "#0a0a0e")
          (surface0 . "#1e1e28")
          (surface1 . "#2a2a38")
          (surface2 . "#3b3b4e")
          (overlay0 . "#6c7086")
          (overlay1 . "#7f849c")
          (overlay2 . "#9399b2")
          (text     . "#dcdfe7")
          (subtext0 . "#a6adc8")
          (subtext1 . "#bac2de")))
  :config
  (load-theme 'catppuccin :no-confirm))

(custom-set-faces
 ;; restful semantic hierarchy: high contrast without optical glare
 '(default ((t (:background "#13131a" :foreground "#dcdfe7"))))
 '(font-lock-keyword-face ((t (:foreground "#f38ba8" :weight bold))))
 '(font-lock-type-face ((t (:foreground "#fab387" :weight bold))))
 '(font-lock-function-call-face ((t (:foreground "#89b4fa"))))
 '(font-lock-function-name-face ((t (:foreground "#89b4fa" :weight bold))))
 '(font-lock-property-name-face ((t (:foreground "#94e2d5"))))
 '(font-lock-property-use-face ((t (:foreground "#94e2d5"))))
 '(font-lock-variable-name-face ((t (:foreground "#cdd6f4"))))
 '(font-lock-constant-face ((t (:foreground "#f9e2af" :weight bold))))
 '(font-lock-number-face ((t (:foreground "#fab387"))))
 '(font-lock-string-face ((t (:foreground "#a6e3a1"))))
 '(font-lock-comment-face ((t (:foreground "#6c7086" :slant italic))))
 '(font-lock-operator-face ((t (:foreground "#cba6f7"))))
 '(font-lock-builtin-face ((t (:foreground "#cba6f7" :weight bold))))

 ;; anchored current line and legible margins
 '(hl-line ((t (:background "#1c1d28"))))
 '(line-number ((t (:background "#13131a" :foreground "#45475a"))))
 '(line-number-current-line ((t (:background "#1c1d28" :foreground "#89b4fa" :weight bold))))
 '(mode-line ((t (:background "#1a1b24" :foreground "#cdd6f4" :box (:line-width 1 :color "#2a2a38")))))
 '(mode-line-inactive ((t (:background "#101017" :foreground "#585b70" :box (:line-width 1 :color "#181822"))))))

(global-hl-line-mode 1)

;; indent guides highlight active scope without visual noise
(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-delay 0.05)
  :config
  (set-face-foreground 'highlight-indent-guides-character-face "#222330")
  (set-face-foreground 'highlight-indent-guides-top-character-face "#585b70"))

;; soft, desaturated delimiters prevent the "christmas tree" effect
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (set-face-attribute 'rainbow-delimiters-depth-1-face nil :foreground "#cba6f7")
  (set-face-attribute 'rainbow-delimiters-depth-2-face nil :foreground "#89b4fa")
  (set-face-attribute 'rainbow-delimiters-depth-3-face nil :foreground "#94e2d5")
  (set-face-attribute 'rainbow-delimiters-depth-4-face nil :foreground "#fab387")
  (set-face-attribute 'rainbow-delimiters-depth-5-face nil :foreground "#f38ba8")
  (set-face-attribute 'rainbow-delimiters-depth-6-face nil :foreground "#f9e2af"))

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package yafolding
  :ensure t
  :hook (prog-mode . yafolding-mode)
  :commands (yafolding-show-element
             yafolding-hide-element
             yafolding-toggle-element
             yafolding-show-all
             yafolding-hide-all)
  :config
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map "zo" #'yafolding-show-element)
    (define-key evil-normal-state-map "zc" #'yafolding-hide-element)
    (define-key evil-normal-state-map "za" #'yafolding-toggle-element)
    (define-key evil-normal-state-map "zr" #'yafolding-show-all)
    (define-key evil-normal-state-map "zm" #'yafolding-hide-all)))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package evil-mc
  :ensure t
  :after evil
  :diminish
  :init
  (setq evil-mc-undo-cursors-on-keyboard-quit t)
  :config
  (global-evil-mc-mode 1)
  (define-key evil-normal-state-map (kbd "C") 'evil-mc-make-cursor-move-next-line)
  (define-key evil-normal-state-map (kbd "M-C") 'evil-mc-make-cursor-move-prev-line)
  (define-key evil-normal-state-map (kbd "g q") 'evil-mc-undo-all-cursors))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (setq evil-collection-mode-list
        (delq 'commentary (delq 'evil-nc evil-collection-mode-list)))
  (evil-collection-init))

(use-package evil-nerd-commenter
  :ensure t
  :after (evil general)
  :diminish
  :config
  (define-key evil-normal-state-map "gc" nil)
  (define-key evil-visual-state-map "gc" nil)
  (define-key evil-motion-state-map "gc" nil)

  (general-def
    :states '(normal visual)
    "gcc" #'evilnc-comment-or-uncomment-lines
    "gc"  #'evilnc-comment-operator))

(use-package iedit
  :ensure t)

(use-package evil-multiedit
  :ensure t
  :after (evil iedit)
  :config
  (evil-multiedit-default-keybinds))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :hook ((prog-mode text-mode) . turn-on-diff-hl-mode)
  :config
  (diff-hl-flydiff-mode 1))

(use-package treemacs
  :ensure t
  :defer t
  :bind ("M-0" . treemacs-select-window)
  :custom
  (treemacs-no-png-images t)
  :config
  (setq treemacs-width 30)

  (unless (listp treemacs-ignored-file-predicates)
    (setq treemacs-ignored-file-predicates nil))

  (add-to-list 'treemacs-ignored-file-predicates
               (lambda (file _)
                 (string-suffix-p ".gd.uid" file))))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package centaur-tabs
  :ensure t
  :demand t
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 32
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "*")
  (centaur-tabs-mode 1))

(use-package elcord
  :ensure t
  :config
  (elcord-mode 1))

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 'prog-mode
    '("-=" "==" "!=" "===" "!==" "=>" "->" "<-" "-->" "==>"
      "//" "///" "/*" "*/" "<!--" "-->" "||" "&&" "<<" ">>"
      "..." ".." "::" ":::" "++" "--" "+=" "-=" "*=" "/="
      "==" "!=" "<=" ">=" "<<" ">>" "??" "?:" "||=" "&&="))
  (global-ligature-mode t))

(use-package hl-todo
  :ensure t
  :config
  (global-hl-todo-mode 1))

(use-package general
  :ensure t
  :demand t
  :config
  (general-create-definer my/leader-keys
    :states '(normal visual insert motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  (my/leader-keys
    "SPC" '(consult-ripgrep :which-key "live grep")
    "/"   '(consult-line :which-key "search buffer")
    "h"   '(:ignore t :which-key "help/emacs")
    "hr"  '((lambda () (interactive) (load-file user-init-file)) :which-key "reload config")
    "f"   '(:ignore t :which-key "files")
    "ff"  '(find-file :which-key "find file")
    "b"   '(:ignore t :which-key "buffers")
    "bb"  '(consult-buffer :which-key "switch buffer")
    "bk"  '(kill-current-buffer :which-key "kill buffer")
    "s"   '(:ignore t :which-key "search")
    "sp"  '(consult-ripgrep :which-key "live grep project")
    "sd"  '(consult-find :which-key "find file by name")
    "sl"  '(consult-line :which-key "search lines")
    "w"   '(:ignore t :which-key "windows")
    "wv"  '(split-window-right :which-key "split vertical")
    "ws"  '(split-window-below :which-key "split horizontal")
    "wc"  '(delete-window :which-key "close window")
    "e"   '(:ignore t :which-key "file tree")
    "ee"  '(treemacs :which-key "toggle tree")
    "ea"  '(treemacs-add-project-to-workspace :which-key "add root dir")
    "er"  '(treemacs-remove-project-from-workspace :which-key "remove root dir")
    "t"   '(:ignore t :which-key "tabs")
    "tn"  '(centaur-tabs-forward :which-key "next tab")
    "tp"  '(centaur-tabs-backward :which-key "previous tab")
    "g"   '(:ignore t :which-key "git")
    "gg"  '(magit-status :which-key "status")
    "gb"  '(magit-blame :which-key "blame")
    "gl"  '(magit-log-buffer-file :which-key "file log")
    "gd"  '(magit-diff-dwim :which-key "diff")))

(custom-set-variables
 '(package-selected-packages
   '(cape catppuccin-theme centaur-tabs clang-format consult corfu
      diff-hl diminish elcord evil-collection evil-mc
      evil-multiedit evil-nerd-commenter gdscript-mode general
      highlight-indent-guides hl-todo ligature magit marginalia
      markdown-mode orderless rainbow-delimiters treemacs-evil
      vertico yafolding)))
