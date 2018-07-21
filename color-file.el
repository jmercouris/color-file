;;; color-file.el --- Colors files/modes while using ivy and counsel
;;; on type -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2018 John Mercouris
;;
;; Author: John Mercouris
;; Version: 0.0.1
;; Keywords: color colorized-buffer color-file
;; Package-Requires: ((emacs "24.4") (ivy "0.8.0"))
;;
;; 1. Redistributions of source code must retain the above copyright
;; notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above
;; copyright notice, this list of conditions and the following
;; disclaimer in the documentation and/or other materials provided
;; with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;; FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;; COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
;; INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
;; OF THE POSSIBILITY OF SUCH DAMAGE.

(require 'ivy)
(require 's)

(setq color-file-ivy-mode-colors
      '((text-mode . "Green")
        (lisp-mode . "Blue")
        (emacs-lisp-mode . "Brown")))

(setq color-file-ivy-regex-file-colors
      '(("lisp$" . "Green")
        ("txt$" . "Blue")
        ("el$" . "Red")))

(setq color-file-ivy-default-face "black")

(defgroup color-file-ivy nil
  "Shows color for modes and file types while using ivy and counsel."
  :group 'ivy)

(defcustom color-file-ivy-buffer-commands
  '(ivy-switch-buffer
    ivy-switch-buffer-other-window
    counsel-projectile-switch-to-buffer)
  "Commands to use with `color-file-ivy-buffer-transformer'."
  :type '(repeat function)
  :group 'color-file-ivy)

(defcustom color-file-ivy-file-commands
  '(counsel-find-file
    counsel-projectile-find-file
    counsel-projectile-find-dir)
  "Commands to use with `color-file-ivy-file-transformer'."
  :type '(repeat function)
  :group 'color-file-ivy)

(defun color-file-ivy--buffer-transformer (b s)
  "Return a candidate string for buffer B named S preceded by a color."
  (let* ((mode (buffer-local-value 'major-mode b))
         (color (cdr (assoc mode color-file-ivy-mode-colors))))
    (format "%s" (propertize s 'face (list :foreground color)))))

(defun color-file-ivy-file-transformer (s)
  "Return a candidate string for filename S preceded by an icon."
  (let ((found-color "Black"))
    (loop for (key . value) in color-file-ivy-regex-file-colors
          do (when (s-match key s)
               (setf found-color value)))
    (format "%s" (propertize s 'face (list :foreground found-color)))))

(defun color-file-ivy-buffer-transformer (s)
  "Return a candidate string for buffer named S.
Assume that sometimes the buffer named S might not exists.
That can happen if `ivy-switch-buffer' does not find the buffer and it
falls back to `ivy-recentf' and the same transformer is used."
  (let ((b (get-buffer s)))
    (if b
        (color-file-ivy--buffer-transformer b s)
      (color-file-ivy-file-transformer s))))

;;;###autoload
(defun color-file-ivy-setup ()
  "Set ivy's display transformers to show relevant icons next to the candidates."
  (dolist (cmd color-file-ivy-buffer-commands)
    (ivy-set-display-transformer cmd 'color-file-ivy-buffer-transformer))
  (dolist (cmd color-file-ivy-file-commands)
    (ivy-set-display-transformer cmd 'color-file-ivy-file-transformer)))

(provide 'color-file-ivy)
