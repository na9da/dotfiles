
;(set-default-font "Monaco-10")
(set-face-attribute 'default nil :height 100)
(defalias 'yes-or-no-p 'y-or-n-p)


(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-h" 'backward-delete-char)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-l" 'goto-line)
(global-set-key [f1] 'help)

(custom-set-variables
 '(ido-mode 1)
 '(ido-everywhere t)
 '(ido-max-prospects 8)
 '(line-number-mode 1)
 '(indent-tabs-mode nil)
 '(blink-cursor-mode nil)
 '(column-number-mode 1)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(menu-bar-mode nil)
 '(mouse-wheel-mode t)
 '(inhibit-startup-screen t)
 '(inhibit-startup-message t)
 '(fill-column 79)
 '(make-backup-files nil))

(show-paren-mode)

(add-to-list 'load-path "~/.emacs.d")


