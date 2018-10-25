;;; cerbere-ruby-minitest-test.el --- Unit tests for Cerbere ruby minitest backend

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

(require 'cerbere)

;; cerbere-ruby-minitest mode

(defvar cerbere--ruby-minitest-ert-test-content "require 'test_helper'

class MyTest < Minitest::Test
  def test_first_test
    # first test
  end

  def test_second_test
    # second test
  end

  test \"first spec\" do
    # first spec
  end

  test \"second spec\" do
    # second spec
  end
end
")

(defmacro cerbere--ruby-minitest-with-test-content (content &rest body)
  "Setup a buffer with CONTENT and run BODY in it."
    (declare (indent 1))
    `(save-excursion
       (with-temp-buffer
         (let ((buffer-file-name "__fake__"))
           (insert ,content)
           (goto-char (point-min))
           ,@body))))

(defmacro cerbere--ruby-minitest-with-test-buffer (&rest body)
  "Setup a buffer with our test data and run BODY in it."
    (declare (indent 0))
    `(cerbere--ruby-minitest-with-test-content cerbere--ruby-minitest-ert-test-content
       ,@body))


(ert-deftest test-cerbere--ruby-minitest ()
  (with-temp-buffer
    (ruby-mode)
    (should (featurep 'cerbere-ruby-minitest))))

(ert-deftest test-cerbere--ruby-minitest-test-at-point ()
  (cerbere--ruby-minitest-with-test-buffer
    (search-forward "def test_first_test")
    (should (equal '(:file "__fake__" :test "test_first_test")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_test")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_test")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_test")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_second_test")
                   (cerbere--ruby-minitest-test-at-point)))
    (search-forward "test \"first spec\"")
    (should (equal '(:file "__fake__" :test "test_first_spec")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_spec")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_spec")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_first_spec")
                   (cerbere--ruby-minitest-test-at-point)))
    (forward-line)
    (should (equal '(:file "__fake__" :test "test_second_spec")
                   (cerbere--ruby-minitest-test-at-point)))))

(provide 'cerbere-ruby-minitest-test)
;;; cerbere-ruby-minitest-test.el ends here
