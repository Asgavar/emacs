;;; spelling-tests.el --- Test suite for so-long.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Free Software Foundation, Inc.

;; Author: Phil Sainty <psainty@orcon.net.nz>
;; Keywords: convenience

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'ert)
(require 'ispell)
(require 'cl-lib)

(when (and (executable-find "ispell")
           (member "british" (ispell-valid-dictionary-list)))
  (ert-deftest so-long-spelling ()
    "Check the spelling in the source code."
    :tags '(:unstable) ;; It works for me, but I'm not sure about others.
    ;; There could be different "british" dictionaries yielding different
    ;; results, for instance.
    (let ((process-environment process-environment)
          (tmpdir (make-temp-file "so-long." :dir ".ispell")))
      (when (file-directory-p tmpdir)
        (let ((find-spelling-mistake
               (progn
                 (push (format "HOME=%s" tmpdir) process-environment)
                 (find-library "so-long")
                 (cl-letf (((symbol-function 'ispell-command-loop)
                            (lambda (_miss _guess word _start _end)
                              (message "Unrecognised word: %s." word)
                              (throw 'mistake t))))
                   (catch 'mistake
                     (ispell-buffer)
                     nil)))))
          (delete-directory tmpdir)
          (should (not find-spelling-mistake)))))))

;;; spelling-tests.el ends here
