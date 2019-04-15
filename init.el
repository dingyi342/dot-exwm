; -*- mode: emacs-lisp; eval: (display-line-numbers-mode); -*-
;;; start speed
(defconst emacs-start-time (current-time))

(defvar file-name-handler-alist-old file-name-handler-alist)

(setq package-enable-at-startup nil
      file-name-handler-alist nil
      message-log-max 16384
      gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      auto-window-vscroll nil)

(add-hook 'after-init-hook
          `(lambda ()
             (setq file-name-handler-alist file-name-handler-alist-old
                   gc-cons-threshold 800000
                   gc-cons-percentage 0.1)
             (garbage-collect)) t)

;; set background forbiding blink
;; (custom-set-faces
 ;; '(default ((t (:background "black" :foreground "#137D11")))))

;;; package
(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
			 ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;;; use-package
;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  (add-to-list 'load-path "~/.exwm.d/module/use-package")
  (require 'use-package))

(package-initialize) ;; You might already have this line

;;; general
(add-to-list 'load-path "~/.exwm.d/module/general")
(require 'general)
(general-evil-setup)
(general-evil-setup t)
(setq general-override-states '(insert
				emacs
				hybrid
				normal
				visual
				motion
				operator
				replace
				evilified
				;; exwm
				))



;;;; comma-def
(general-create-definer comma-def
  :states '(normal evilified motion)
  ;; :keymaps 'override
  :prefix ","
  )

;;;; semicolon-def
(general-create-definer semicolon-def
  :states '(normal evilified motion)
  :keymaps 'override
  :prefix ";")

(general-create-definer exwm-def
  :states 'global
  )
;; (exwm-def "s-t" 'exwm-input-char-mode)


;; (defun exwm-input--set-key (key command)
;; (exwm--log "key: %s, command: %s" key command)
;; (global-set-key key command)
;; (cl-pushnew key exwm-input--global-keys))

;; (defun exwm-def (key command &rest bindings)
;;   (while key
;;     (exwm-input-set-key (kbd key)
;; 			`(lambda ()
;; 			   (interactive)
;; 			   (start-process-shell-command ,command nil ,command)))
;;     (setq key     (pop bindings)
;; 	  command (pop bindings))))

;; (push ?\, exwm-input-prefix-keys)
;;(push ?\; exwm-input-prefix-keys)
;; (push ?\C-w exwm-input-prefix-keys)
;;(push ?\: exwm-input-prefix-keys)

(comma-def
  "d" 'bury-buffer
  "f" 'counsel-find-file
  "e" (lambda () (interactive) (find-file "~/.exwm.d/init.el"))
  "k" 'kill-current-buffer
  "q" 'kill-buffer-and-window
  )

(semicolon-def
  "s" 'save-buffer)


;;; better-defaults
(progn
  (unless (fboundp 'helm-mode)
    (ido-mode t)
    (setq ido-enable-flex-matching t))

  (autoload 'zap-up-to-char "misc"
    "Kill up to, but not including ARGth occurrence of CHAR." t)

  (require 'uniquify)
  (setq uniquify-buffer-name-style 'forward)

  (require 'saveplace)
  (setq-default save-place t)

  (global-set-key (kbd "M-/") 'hippie-expand)
  (global-set-key (kbd "C-x C-b") 'ibuffer)
  (global-set-key (kbd "M-z") 'zap-up-to-char)

  (global-set-key (kbd "C-s") 'isearch-forward-regexp)
  (global-set-key (kbd "C-r") 'isearch-backward-regexp)
  (global-set-key (kbd "C-M-s") 'isearch-forward)
  (global-set-key (kbd "C-M-r") 'isearch-backward)

  (show-paren-mode 1)
  (setq-default indent-tabs-mode nil)
  (setq save-interprogram-paste-before-kill t
        apropos-do-all t
        mouse-yank-at-point t
        require-final-newline t
        visible-bell t
        load-prefer-newer t
        ediff-window-setup-function 'ediff-setup-windows-plain
        save-place-file (concat user-emacs-directory "places")
        backup-directory-alist `(("." . ,(concat user-emacs-directory
                                                 "backups")))))

;;; exwm
(add-to-list 'load-path "~/.exwm.d/module/exwm")
(add-to-list 'load-path "~/.exwm.d/module/xelb")
(require 'exwm)
(require 'exwm-config)
(exwm-config-default)

(setq exwm-workspace-number 10
      exwm-workspace-current-index 1
      exwm-workspace-show-all-buffers nil
      exwm-layout-show-all-buffers nil
      exwm-input-line-mode-passthrough nil
      )

;;;; hide echo area
(setq exwm-workspace-minibuffer-position 'bottom)
(setq exwm-workspace-display-echo-area-timeout 1)

;;;; hide modeline
(defun exwm-input-line-mode ()
  "Set exwm window to line-mode and show mode line"
  (interactive)
  (with-current-buffer (window-buffer)
    (when (eq major-mode 'exwm-mode)
      (call-interactively #'exwm-input-grab-keyboard)
      (exwm-layout-show-mode-line))))

(defun exwm-input-char-mode ()
  "Set exwm window to char-mode and hide mode line"
  (interactive)
  (with-current-buffer (window-buffer)
    (when (eq major-mode 'exwm-mode)
      (call-interactively #'exwm-input-release-keyboard)
      (exwm-layout-hide-mode-line))))

(defun exwm-input-toggle-mode ()
  "Toggle between line- and char-mode"
  (with-current-buffer (window-buffer)
    (when (eq major-mode 'exwm-mode)
      (if (equal (cl-second (cl-second mode-line-process)) "line")
	  (exwm-input-char-mode)
	(exwm-input-line-mode)))))

(add-hook 'exwm-manage-finish-hook #'exwm-layout-hide-mode-line)

(exwm-input-set-key (kbd "s-z")
		    (lambda () (interactive)
		      (exwm-input-toggle-mode)))

;; (defvar exwm--terminal-command "guake")
;; (defvar exwm-app-launcher--prompt "$ ")
;; (defvar exwm--hide-tiling-modeline t)
;; Quick swtiching between workspaces
;; (defvar exwm-toggle-workspace 0
;;  "Previously selected workspace. Used with `exwm-jump-to-last-exwm'.")
;; (defun exwm-jump-to-last-exwm ()
;;  (interactive)
;;  (exwm-workspace-switch exwm-toggle-workspace))
;; (defadvice exwm-workspace-switch (before save-toggle-workspace activate)
;;  (setq exwm-toggle-workspace exwm-workspace-current-index))
;; 					;
;; 				;
;; (exwm-input-set-key (kbd "<s-tab>") #'exwm-jump-to-last-exwm)
;; + Bind a key to switch workspace interactively
;; 					;(exwm-input-set-key (kbd "s-w") 'exwm-workspace-switch)
;; 					;
;; (exwm-input-set-key (kbd "s-:") 'counsel-M-x)
;; (exwm-input-set-key (kbd "s-;") 'evil-ex)
;; Shell (not a real one for the moment)
;; (exwm-input-set-key (kbd "C-'") #'spacemacs/default-pop-shell)
;; Undo window configurations

(general-def
  :keymaps 'exwm-mode-map
  :prefix "s-a"
  "f" 
  )

(defun exwmx-switch-application ()
  "Select an application and switch to it."
  (interactive)
  (let ((buffer-name
         (ivy-read "EXWM-X switch application: "
                   (mapcar
                    #'(lambda (x)
                        (buffer-name (cdr x)))
                    exwm--id-buffer-alist))))
    (exwm-workspace-switch-to-buffer buffer-name)))

(exwm-input-set-key (kbd "s-b") 'exwmx-switch-application)
(exwm-input-set-key (kbd "s-C") 'kill-this-buffer)
(exwm-input-set-key (kbd "s-d") #'bury-buffer)
;; (exwm-input-set-key (kbd "s-e") 
;; (exwm-input-set-key (kbd "s-f") #'exwm-layout-toggle-fullscreen)
;; (exwm-input-set-key (kbd "s-f") #'exwm-open-firefox)

;; quit all exwm-emacs buffer minibuffer echo area.
(exwm-input-set-key (kbd "s-g") 'keyboard-quit)


(exwm-input-set-key (kbd "s-h") 'windmove-left)
(exwm-input-set-key (kbd "s-j") 'windmove-down)
(exwm-input-set-key (kbd "s-k") 'windmove-up)
(exwm-input-set-key (kbd "s-l") 'windmove-right)
;;;; Moving Windows
(exwm-input-set-key (kbd "s-H") #'evil-window-move-far-left)
(exwm-input-set-key (kbd "s-J") #'evil-window-move-very-bottom)
(exwm-input-set-key (kbd "s-K") #'evil-window-move-very-top)
(exwm-input-set-key (kbd "s-L") #'evil-window-move-far-right)
;;;; Resize
(exwm-input-set-key (kbd "M-s-h") #'shrink-window-horizontally)
(exwm-input-set-key (kbd "M-s-j") #'shrink-window)
(exwm-input-set-key (kbd "M-s-k") #'enlarge-window)
(exwm-input-set-key (kbd "M-s-l") #'enlarge-window-horizontally)

;; exwm-edit
;;(exwmx-input-set-key (kbd "s-i") 'exwmx-sendstring-from-minibuffer)
;;(exwmx-input-set-key (kbd "s-I") 'dingyi/exwmx-sendstring)


;; exwmx
(use-package exwm-x
  :ensure t
  )



(defun maximize-horizontally ()
  "Delete all windows to the left and right of the current window."
  (interactive)
  (require 'windmove)
  (save-excursion
    (while (condition-case nil (windmove-left) (error nil))
      (delete-window))
    (while (condition-case nil (windmove-right) (error nil))
      (delete-window))))

(defun maximize-vertically ()
  "Delete all windows above and below the current window."
  (interactive)
  (require 'windmove)
  (save-excursion
    (while (condition-case nil (windmove-up) (error nil))
      (delete-window))
    (while (condition-case nil (windmove-down) (error nil))
      (delete-window))))
(exwm-input-set-key (kbd "s-m") 'maximize-vertically)
(exwm-input-set-key (kbd "s-M") 'maximize-horizontally)


(exwm-input-set-key (kbd "s-o") 'counsel-linux-app)

(exwm-input-set-key (kbd "s-r") 'exwm-reset)
;;(exwm-input-set-key (kbd "s-R") 'exwm-config-reset)

(winner-mode 1)
(exwm-input-set-key (kbd "s-u") #'winner-undo)
(exwm-input-set-key (kbd "s-U") #'winner-redo)

(exwm-input-set-key (kbd "s-c") (lambda () (interactive) (exwm-input--fake-key (car (string-to-list (kbd "C-<insert>"))))))
(exwm-input-set-key (kbd "s-v") (lambda () (interactive) (exwm-input--fake-key (car (string-to-list (kbd "S-<insert>"))))))

;; s-c --> copy  s-v --> paste
;; exwm window
(general-def exwm-mode-map
  ;; "s-c" (lambda () (interactive) (exwm-input--fake-key (car (string-to-list (kbd "C-<insert>")))))
  "s-v" (lambda () (interactive) (exwm-input--fake-key (car (string-to-list (kbd "S-<insert>")))))
  )

(defun dingyi/copy-to-deft-today-file ()
  (interactive)
  (let* ((deft-directory "~/OneDrive/org/")
         (deft-today-file-name (concat (format-time-string "%Y-%m-%d") ".org"))
         (deft-today-file-path (concat deft-directory deft-today-file-name))
         )
    (if (eq major-mode 'exwm-mode)
        (exwm-input--fake-key (car (string-to-list (kbd "C-<insert>"))))
      (kill-ring-save (mark) (point)) 
      ;; (indicate-copied-region)
      )
    (sleep-for 0.1)
    (find-file-other-window deft-today-file-path)
    ;; (deft-new-file-named (format-time-string "%Y-%m-%d"))
    (goto-char (point-max))
    (org-meta-return)
    (let ((current-prefix-arg '(16)))
      (call-interactively 'org-time-stamp))
    (newline)
    ;;(evil-insert-state)
    (evil-paste-after 1)
    (save-buffer)
    (quit-window)
    )
  )

(exwm-input-set-key (kbd "s-c") 'dingyi/copy-to-deft-today-file)
(general-def "s-c" 'dingyi/copy-to-deft-today-file)
;; emacs window
;; (general-def "s-c" (general-simulate-key "C-<insert>"))
(general-def "s-v" (general-simulate-key "S-<insert>"))
;; s-c --> C-c in terminal


(exwm-input-set-key (kbd "s-Q") #'save-buffers-kill-emacs)

(exwm-input-set-key (kbd "s-:") #'eval-expression)



					;
;;(exwm-input-set-key (kbd "s-!") (lambda () (interactive) (exwm-workspace-move-window 0)))
;;(exwm-input-set-key (kbd "s-@") (lambda () (interactive) (exwm-workspace-move-window 1)))
;;(exwm-input-set-key (kbd "s-a") (lambda () (interactive) (exwm-workspace-move-window 2)))
;;(exwm-input-set-key (kbd "s-$") (lambda () (interactive) (exwm-workspace-move-window 3)))
;;(exwm-input-set-key (kbd "s-%") (lambda () (interactive) (exwm-workspace-move-window 4)))
;;(exwm-input-set-key (kbd "s-^") (lambda () (interactive) (exwm-workspace-move-window 5)))
;;(exwm-input-set-key (kbd "s-&") (lambda () (interactive) (exwm-workspace-move-window 6)))
;;(exwm-input-set-key (kbd "s-*") (lambda () (interactive) (exwm-workspace-move-window 7)))
;;(exwm-input-set-key (kbd "s-(") (lambda () (interactive) (exwm-workspace-move-window 8)))
;;(exwm-input-set-key (kbd "s-)") (lambda () (interactive) (exwm-workspace-move-window 9)))
;;(push (elt (kbd "s-!") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-@") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-#") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-$") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-%") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-^") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-&") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-*") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-(") 0) exwm-input-prefix-keys)
;;(push (elt (kbd "s-)") 0) exwm-input-prefix-keys)
;;
;;(exwm-input-set-key (kbd "s-<right>") 'exwm-volume-increment)
;;(exwm-input-set-key (kbd "S-s-<right>") 'exwm-volume-increment-slowly)
;;(exwm-input-set-key (kbd "s-<left>") 'exwm-volume-decrement)
;;(exwm-input-set-key (kbd "S-s-<left>") 'exwm-volume-decrement-slowly)
;;(exwm-input-set-key (kbd "s-m") 'exwm-toggle-mute)
;;(exwm-input-set-key (kbd "s-M") 'exwm-toggle-microphone-mute)
;;
;;(exwm-input-set-key (kbd "s-<up>") 'exwm-brightness-adjust-increase-slowly)
;;(exwm-input-set-key (kbd "S-s-<up>") 'exwm-brightness-adjust-increase-fastly)
;;(exwm-input-set-key (kbd "s-<down>") 'exwm-brightness-adjust-decrease-slowly)
;;(exwm-input-set-key (kbd "S-s-<down>") 'exwm-brightness-adjust-decrease-fastly)
;;
;;(exwm-input-set-key (kbd "s-S") 'exwm-screenshot)
;;(exwm-input-set-key (kbd "s-s") 'exwm-screenshot-part)
;;
;;(exwm-input-set-key (kbd "s-Q") 'exwm-quit)
;;(exwm-input-set-key (kbd "s-<enter>") 'exwm-toggle-terminal)
;;(exwm-input-set-key (kbd "S-s-c") 'exwm-quit-window)
;;
					;
(push ?\C-q exwm-input-prefix-keys)
(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)

;; use emacs style keybinding in exwm-mode window.
(exwm-input-set-simulation-keys
 '(([?\C-b] . left)
   ([?\C-f] . right)
   ([?\C-p] . up)
   ([?\C-n] . down)
   ([?\C-a] . home)
   ([?\C-e] . end)
   ([?\M-v] . prior)
   ([?\C-v] . next)))


(push ?\C-x exwm-input-prefix-keys)

;;; evil
(use-package evil
  :ensure t
  :init
  (setq evil-want-C-i-jump nil)         ;org-mode use tab
  :config
  (evil-mode 1)
  )

;;; ivy
(use-package counsel :ensure t)
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
  )
;;* lispy
;; (use-package lispy
;;   :ensure t
;;   :config
;;   ;; (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
;;   ;; M-: with lispy.
;;   (defun conditionally-enable-lispy ()
;;     (when (eq this-command 'eval-expression)
;;       (lispy-mode 1)))
;;   (add-hook 'minibuffer-setup-hook 'conditionally-enable-lispy)
;;   )

;; flypy -- chinese shuangpin input method

(use-package outline
  :init
  (defvar outline-minor-mode-prefix "\M-#")
  )


;;; outshine
(use-package outshine
  :ensure t
  :init
  ;; (add-hook 'outline-minor-mode-hook #'outshine-mode)
  ;; (add-hook 'prog-mode-hook #'outline-minor-mode)
  ;; (add-hook 'prog-mode-hook #'outshine-mode)
  ;; To enable M-# as prefix, before loading outshine
  ;; (defvar outline-minor-mode-prefix "\M-#")
  ;; hooks enable outshine-mode
  (add-hook 'emacs-lisp-mode-hook 'outshine-mode)
  :config
  (setq outshine-use-speed-commands nil)
  ;; Narrowing now works within the headline rather than requiring to be on it
  (advice-add 'outshine-narrow-to-subtree :before
              (lambda (&rest args) (unless (outline-on-heading-p t)
                                     (outline-previous-visible-heading 1))))
  (let ((kmap outline-minor-mode-map))
    (define-key kmap (kbd "M-RET") 'outshine-insert-heading)
    (define-key kmap (kbd "<backtab>") 'outshine-cycle-buffer)

    ;; Evil outline navigation keybindings
    (evil-define-key '(normal visual motion) kmap
      "gh" 'outline-up-heading
      "gj" 'outline-forward-same-level
      "gk" 'outline-backward-same-level
      "gl" 'outline-next-visible-heading
      "gu" 'outline-previous-visible-heading))
  ;; outshine-imenu
  (comma-def outshine-mode-map "j" 'outshine-imenu)
  )

;;; custom.el
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(package-selected-packages '(exwmx outshine lispy evil counsel)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(magit exwm-x exwmx outshine lispy evil counsel)))

;;; magit
(use-package magit
  :ensure t)
