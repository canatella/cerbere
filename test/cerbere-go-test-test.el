;;; cerbere-go-test-test.el --- Tests for Cerbere Go lang backend

;; Copyright (C) Nicolas Lamirault <nicolas.lamirault@gmail.com>

;; Copyright (C) 2014  Nicolas Lamirault

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


(require 'test-helper)
(require 'cerbere)


(defun go-test-command (&rest arg)
  (apply 's-concat "go test " arg))


;; Arguments

(ert-deftest test-go-test-get-program-without-args ()
  (should (string= (go-test-command)
		   (go-test-get-program (go-test-arguments "")))))

(ert-deftest test-go-test-add-verbose-argument ()
  (let ((go-test-verbose-mode t))
    (should (string= (go-test-command " -v")
		     (go-test-get-program (go-test-arguments ""))))))


(provide 'gotest-test)
;;; cerbere-go-test-test.el ends here
