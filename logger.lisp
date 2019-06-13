(uiop:define-package #:cl-fluent-logger/logger
  (:use #:cl)
  (:shadow #:log
           #:trace
           #:debug
           #:warn
           #:error)
  (:import-from #:cl-fluent-logger/logger/level
                #:with-log-level)
  (:use-reexport #:cl-fluent-logger/logger/base
                 #:cl-fluent-logger/logger/fluent
                 #:cl-fluent-logger/logger/text
                 #:cl-fluent-logger/logger/null
                 #:cl-fluent-logger/logger/level
                 #:cl-fluent-logger/logger/broadcast)
  (:import-from #:alexandria
                #:hash-table-alist)
  (:export #:*logger*
           #:with-logger
           #:log
           #:trace
           #:debug
           #:info
           #:warn
           #:error
           #:fatal))
(in-package #:cl-fluent-logger/logger)

(defvar *logger*
  (make-instance 'null-logger))

(defmacro with-logger (logger &body body)
  `(let ((*logger* ,logger))
     ,@body))

(defun log (tag data)
  (post *logger* tag data))

(declaim (ftype function trace debug info warn error fatal))

#.`(progn
     ,@(loop for level in '(trace debug info warn error fatal)
             collect `(defun ,level (tag data)
                        (with-log-level ,(intern (symbol-name level) :keyword)
                          (log tag
                               (cons '("level" . ,(intern (symbol-name level) :keyword))
                                     (typecase data
                                       (hash-table (hash-table-alist data))
                                       (cons data)
                                       (otherwise
                                        `(("payload" . ,data))))))))))

(declaim (notinline log post))
