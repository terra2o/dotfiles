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

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

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
    (define-key c-mode-base-map (kbd "C-c b") #'clang-format-buffer))
  :hook (c-mode-common . (lambda ()
                           (add-hook 'before-save-hook #'clang-format-buffer nil t))))

(use-package cc-mode
  :mode ("\\.cppm\\'" . c++-mode)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((c-mode c++-mode) . ("clangd")))))

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

(use-package c-ts-mode
  :mode ("\\.cppm\\'" . c++-ts-mode)
  :init
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode)))

(use-package eglot
  :hook (prog-mode . eglot-ensure)
  :init
  (setq eglot-events-buffer-config '(:size nil :format full))
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs
               '(gdscript-mode . ("localhost" 6005))))

(add-hook 'c-mode-common-hook
          (lambda ()
            (add-hook 'before-save-hook #'eglot-format-buffer nil t)))

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

(use-package catppuccin-theme
  :ensure t
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin t))

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
  (evil-collection-init))

(use-package iedit
  :ensure t)

(use-package evil-multiedit
  :ensure t
  :after (evil iedit)
  :config
  (evil-multiedit-default-keybinds))

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
    "h"      '(:ignore t :which-key "help/emacs")
    "hr" '((lambda () (interactive) (load-file user-init-file)) :which-key "reload config")
    "f"      '(:ignore t :which-key "files")
    "ff" '(find-file :which-key "find file")
    "b"      '(:ignore t :which-key "buffers")
    "bb" '(switch-to-buffer :which-key "switch buffer")
    "bk" '(kill-current-buffer :which-key "kill buffer")
    "w"      '(:ignore t :which-key "windows")
    "wv" '(split-window-right :which-key "split vertical")
    "ws" '(split-window-below :which-key "split horizontal")
    "wc" '(delete-window :which-key "close window")
    "e"      '(:ignore t :which-key "file tree")
    "ee" '(treemacs :which-key "toggle tree")
    "ea" '(treemacs-add-project-to-workspace :which-key "add root dir")
    "er" '(treemacs-remove-project-from-workspace :which-key "remove root dir")
    "t"      '(:ignore t :which-key "tabs")
    "tn" '(centaur-tabs-forward :which-key "next tab")
    "tp" '(centaur-tabs-backward :which-key "previous tab")))

(custom-set-variables
 '(package-selected-packages
   '(cape catppuccin-theme centaur-tabs clang-format corfu elcord
	  evil-collection evil-mc evil-multiedit gdscript-mode general
	  highlight-indent-guides marginalia markdown-mode orderless
	  treemacs-evil vertico yafolding)))

(custom-set-faces
 )
