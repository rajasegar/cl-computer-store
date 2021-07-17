(defsystem "cl-computer-store-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Rajasegar Chandran"
  :license ""
  :depends-on ("cl-computer-store"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "cl-computer-store"))))
  :description "Test system for cl-computer-store"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
