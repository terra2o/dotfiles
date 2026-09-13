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

(set-face-attribute 'default nil :font "JetBrains Mono-14")
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

(setq-default line-spacing 0.2)

(set-fringe-mode '(12 . 12))

(global-set-key (kbd "C-+") #'text-scale-increase)
(global-set-key (kbd "C-=") #'text-scale-increase)
(global-set-key (kbd "C--") #'text-scale-decrease)
(global-set-key (kbd "C-0") (lambda () (interactive) (text-scale-increase 0)))

(use-package server
  :config
  (unless (server-running-p)
    (server-start))
  (add-hook 'server-switch-hook #'raise-frame))

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

(setq treesit-font-lock-level 4)

(with-eval-after-load 'treesit
  (defun my/treesit-font-lock-markers-to-pos (orig-fn start end &rest args)
    (apply orig-fn
           (if (markerp start) (marker-position start) start)
           (if (markerp end) (marker-position end) end)
           args))
  (advice-add 'treesit-font-lock-fontify-region :around #'my/treesit-font-lock-markers-to-pos))


(use-package c-ts-mode
  :mode ("\\.cppm\\'" . c++-ts-mode)
  :init
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  :custom
  (c-ts-mode-indent-style 'bsd)
  (c-ts-mode-indent-offset 4))

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
  (setq-default eglot-ignored-server-capabilities '(:inlayHintProvider :semanticTokensProvider))

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

(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package autothemer :ensure t)
(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-theme "doom-gruvbox")
  :config
  (load-theme 'doom-one t)

  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'doom-gruvbox t)
(global-hl-line-mode 1)

(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-delay 0.05))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

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
  :config
  (setq treemacs-width 30
	treemacs-no-png-images t
	treemacs-move-files-by-mouse-dragging nil)
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
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(autothemer cape centaur-tabs clang-format consult corfu diff-hl
        diminish elcord evil-collection evil-mc evil-multiedit
        evil-nerd-commenter gdscript-mode general
        highlight-indent-guides hl-todo ligature magit
        marginalia markdown-mode orderless rainbow-delimiters
        treemacs-evil vertico
        yafolding)))
