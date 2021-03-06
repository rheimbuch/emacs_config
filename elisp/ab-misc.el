(defun line-to-top-of-window ()
  "Scroll current line to top of window. \
 Replaces three keystroke sequence C-u 0 C-l."
  (interactive)
  (recenter 0))

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun clear-comint-buffer ()
  (interactive)
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer)))

(add-hook 'comint-mode-hook
	  (lambda () (local-set-key (kbd "C-x C-l") 'clear-comint-buffer)))

;; Revert all open buffers
(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (not (buffer-modified-p)))
        (revert-buffer t t t) )))
  (message "Refreshed open files.") )

(defun count-words (start end)
  "Print number of words in the region."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (message (number-to-string (count-matches "\\sw+"))))))

(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(defun up-slightly () (interactive) (scroll-up 5))
(defun down-slightly () (interactive) (scroll-down 5))

;; display and behavior
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode nil)
(global-font-lock-mode 1)
(setq inhibit-splash-screen 't)
(custom-set-variables
 '(auto-revert-interval 1))
(global-auto-revert-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(line-number-mode 1)
(setq visible-bell t)
(global-hl-line-mode t)
;; (global-linum-mode t)

(setq sml/theme 'dark)

;; hide-show
(defun hide-level (level)
  (interactive
   (list
    (read-number "Level: ")))
  (hs-hide-level level))

;; Compilation stuff
(setq-default display-buffer-reuse-frames t)
(setq compile-command "scons -u")
(setq compilation-scroll-output 't)
(defun my-compilation-mode-hook ()
  (define-key compilation-mode-map "\C-x\C-n" 'next-error)
  (define-key compilation-mode-map "\C-x\C-p" 'previous-error)
  )
(add-hook 'compilation-mode-hook 'my-compilation-mode-hook)

(defun practical-compilation-buffer (buffer dir command &rest args)
  "This function is designed for running external compilation commands in a buffer which 'does the right thing'. This does a few things:
   - Set DIR as the current directory
   - Add . to the front of exec-path
   - Create the buffer BUFFER (if needed)
   - Display BUFFER
   - Put it into compilation-mode (so errors are highlighted and clickable)
   - Make it read-write
   - Erases it (to remove old compilation output.)
   - Run external COMMAND with ARGS in that buffer.
"
  (let ((default-directory dir)
        (exec-path (cons nil exec-path)))
    (get-buffer-create buffer)
    (display-buffer buffer)
    (with-current-buffer buffer
      (compilation-mode)
      (read-only-mode 0)
      (erase-buffer))
    (apply 'call-process command nil buffer t args)))

;; Misc. other stuff
                                        ;(require 'rainbow-delimiters)
                                        ;(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
                                        ; (require 'tramp)
                                        ; (setq tramp-default-method "ssh")

(fset 'yes-or-no-p 'y-or-n-p)           ; easy answer to stupid question

                                        ; This makes subshells
                                        ; "interactive" so that
                                        ; e.g. `shell-command' uses
                                        ; the same environment as a
                                        ; normal shell.
(set-variable 'shell-command-switch "-ic")

                                        ; Load any local settings.
(let* ((this_dir (file-name-directory load-file-name))
       (local_config (concat this_dir "local_config.el")))
                                        ; (add-to-list 'load-pah this_dir)
  (if (file-exists-p local_config)
      (load local_config)
    (message (format "no local config %s" local_config))))
;; (condition-case nil
;;     (load local_config)
;;   (error (message ")))

; Mac keyboard hackery to correctly enable "meta" for the option key
(setq mac-command-modifier 'meta)

; But leave right-option alone.
(setq ns-right-alternate-modifier nil)

; bindings
(global-set-key [(ctrl x) (i)] 'windmove-up)
(global-set-key [(ctrl x) (m)] 'windmove-down)
(global-set-key [(ctrl x) (j)] 'windmove-left)
(global-set-key [(ctrl x) (l)] 'windmove-right)
;; (global-set-key [(ctrl x) (o)] 'other-window)
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-w" 'backward-kill-word) 
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-x\C-j" 'copy-region-as-kill)
; (global-set-key "\C-x\C-n" 'compile)
; (global-set-key "\C-cn" 'compilation-mode)
(global-set-key (kbd "<mouse-5>") 'up-slightly)
(global-set-key (kbd "<mouse-4>") 'down-slightly)
(global-set-key "\C-l" 'line-to-top-of-window)
(global-set-key [f9] 'match-paren)
(global-set-key [(ctrl f10)] 'start-kbd-macro)
(global-set-key [(meta f10)] 'end-kbd-macro)
(global-set-key [f10] 'call-last-kbd-macro)
					;(global-set-key "\C-t" (transpose-chars -1))
(global-set-key [(ctrl .)] 'comment-or-uncomment-region)


(provide 'ab-misc)
