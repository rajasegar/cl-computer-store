(in-package :cl-user)
(defpackage cl-computer-store.web
  (:use :cl
        :caveman2
        :cl-computer-store.config
        :cl-computer-store.view
        :cl-computer-store.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :cl-computer-store.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;; Create manufacturers table
(with-connection (db)
  (execute
   (drop-table :manufacturers :if-exists t))
  (execute
   (create-table :manufacturers
       ((code :type 'integer
	      :primary-key t)
	(name :type 'string)))))

;; Create products table
(with-connection (db)
  (execute
   (drop-table :products :if-exists t))
  (execute
   (create-table :products
       ((code :type 'integer
	      :primary-key t)
	(name :type 'string)
	(price :type 'real)
	(manufacturer :type 'integer)))))

;; Generate data for manufacturers
(with-connection (db)
  (execute (insert-into :manufacturers (set= :code 1 :name "Sony")))
  (execute (insert-into :manufacturers (set= :code 2 :name "Creative Labs")))
  (execute (insert-into :manufacturers (set= :code 3 :name "Hewlett-Packard")))
  (execute (insert-into :manufacturers (set= :code 4 :name "Iomega")))
  (execute (insert-into :manufacturers (set= :code 5 :name "Fujitsu")))
  (execute (insert-into :manufacturers (set= :code 6 :name "Winchester")))
  (execute (insert-into :manufacturers (set= :code 7 :name "Bose"))))
   
;; Generate data for products
(with-connection (db)
  (execute (insert-into :products (set= :code 1 :name "Hard drive" :price 240 :manufacturer 5)))
  (execute (insert-into :products (set= :code 2 :name "Memory" :price 120 :manufacturer 6)))
  (execute (insert-into :products (set= :code 3 :name "ZIP drive" :price 150 :manufacturer 4)))
  (execute (insert-into :products (set= :code 4 :name "Floppy disk" :price 5 :manufacturer 6)))
  (execute (insert-into :products (set= :code 5 :name "Monitor" :price 240 :manufacturer 1)))
  (execute (insert-into :products (set= :code 6 :name "DVD drive" :price 180 :manufacturer 2)))
  (execute (insert-into :products (set= :code 7 :name "CD drive" :price 90 :manufacturer 2)))
  (execute (insert-into :products (set= :code 8 :name "Printer" :price 270 :manufacturer 3)))
  (execute (insert-into :products (set= :code 9 :name "Toner cartridge" :price 66 :manufacturer 3)))
  (execute (insert-into :products (set= :code 10 :name "DVD burner" :price 180 :manufacturer 2))))

;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))

(defroute "/manufacturers" ()
  (let ((manfs (with-connection (db)
    (retrieve-all
      (select :*
        (from :manufacturers))))))
    (format t "~a~%" manfs)
  (render #P"manufacturers.html" (list :manfs manfs))))

(defroute "/manufacturers/:id" (&key id)
  (with-connection (db)
    (let ((manufacturer (retrieve-one
			 (select :*
			   (from :manufacturers)
			   (where (:= :code id)))))
	  (products (retrieve-all
		     (select :*
		       (from :products)
		       (where (:= :manufacturer id))))))
      (format t "~a~%" manufacturer)
      (format t "~a~%" products)
      (render #P"manufacturer-detail.html" (list
					    :manufacturer manufacturer
					    :products products)))))


(defroute "/products" ()
    (let ((products (with-connection (db)
    (retrieve-all
      (select :*
        (from :products))))))
    (format t "~a~%" products)
  (render #P"products.html" (list :products products))))
;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
