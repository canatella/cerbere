;;; cerbere-phpunit.el --- Launch PHP unit tests using phpunit

;; Copyright (C) 2014  Nicolas Lamirault <nicolas.lamirault@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;; Commentary:

;;; Code:


(require 's)
(require 'f)

(require 'cerbere-common)

(defgroup cerbere-ruby-minitest nil
  "Ruby Minitest utility"
  :group 'cerbere)

(defcustom cerbere-ruby-minitest-bundle-command "bundle exec"
  "Bundle command to use as prefix for rake and ruby."
  :type 'string
  :group 'cerbere-ruby-minitest)

(defcustom cerbere-ruby-minitest-verbose-mode nil
  "Display debugging information during test execution."
  :type 'boolean
  :group 'cerbere-ruby-minitest)


(defconst cerbere--ruby-minitest-beginning-of-test-regexp
  "\\(test\\s-+\"\\([^\"]+\\)\"\\|def\\s-+test_\\([0-9a-zA-Z_!]+\\)\\)"
  "Regular expression for a ruby minitest definition.")


;; Commands
;; -----------

(defun cerbere--ruby-minitest-executable (exec path)
  "Return bundle EXEC PATH if a Gemfile is found, EXEC PATH otherwise."
  (if (locate-dominating-file path "Gemfile")
      (format "%s %s" cerbere-ruby-minitest-bundle-command exec)
    exec))

(defun cerbere--ruby-minitest-test-at-point ()
  "Return the test at point.

Return a proprety list containing the test name and the test file for
the current buffer point, nil if there are no test."
  (save-excursion
    (end-of-line)
    (when (re-search-backward cerbere--ruby-minitest-beginning-of-test-regexp nil 't)
      (let ((test-name (or (match-string 2) (match-string 3))))
        (set-text-properties 0 (length test-name) nil test-name)
        `(:file ,(buffer-file-name (current-buffer))
          :test ,(concat "test_" (replace-regexp-in-string " " "_" test-name)))))))

(defun cerbere--ruby-minitest-test-for-buffer ()
  "Return the test for the current buffer."
  `(:file ,(buffer-file-name (current-buffer))))

(defun cerbere--ruby-minitest-command (test)
  "Return command for running TEST using rake."
  (let* ((test-file (and test (plist-get test :file)))
         (test-name (and test (plist-get test :test))))
    (format "%s test%s%s"
            (cerbere--ruby-minitest-executable "rake" (or test-file "./"))
            (if test-file (format " TEST=\"%s\"" test-file) "")
            (if test-name (format " TESTOPTS=\"--name='%s'\"" test-name) ""))))

(defun cerbere--ruby-minitest-directory (test)
  "Return the TEST parent directory having a Rakefile."
  (locate-dominating-file (or (and test (plist-get test :file)) "./") "Rakefile"))

(defun cerbere--ruby-minitest-run (test)
  "Run TEST."
  (let ((defaut-directory (cerbere--ruby-minitest-directory test)))
    (cerbere--build (cerbere--ruby-minitest-command test))))

;; API
;; ----

(defun cerbere--ruby-minitest-test (test)
  "Launch ruby minitest on TEST."
  (cerbere--ruby-minitest-run test))

(defun cerbere--ruby-minitest-current-test ()
  "Launch ruby minitest on current test."
  (interactive)
  (let ((test (cerbere--ruby-minitest-test-at-point)))
    (cerbere--ruby-minitest-run test)
    test))

(defun cerbere--ruby-minitest-current-class ()
  "Launch ruby minitest on current class."
  (interactive)
  (let ((test (cerbere--ruby-minitest-test-for-buffer)))
    (cerbere--ruby-minitest-run test)
    test))

(defun cerbere--ruby-minitest-current-project ()
  "Launch Ruby-Minitest on current project."
  (interactive)
  (cerbere--ruby-minitest-run nil))


;;;###autoload
(defun cerbere-ruby-minitest (command &optional test)
  "Ruby-Minitest cerbere backend."
  (pcase command
    (`test (cerbere--ruby-minitest-current-test))
    (`file (cerbere--ruby-minitest-current-class))
    (`project (cerbere--ruby-minitest-current-project))))

(provide 'cerbere-ruby-minitest)
;;; cerbere-ruby-minitest.el ends here
