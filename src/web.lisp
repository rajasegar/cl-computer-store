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

;; ;;
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
     (select ((:as :products.code :p-code)
	      (:as :products.name :p-name)
	      :price
	      :manufacturer
	      (:as :manufacturers.name :man-name))
        (from :products)
       (inner-join :manufacturers :on (:= :products.manufacturer :manufacturers.code))
       )))))
    (format t "~a~%" products)
  (render #P"products.html" (list :products products))))

(defroute "/products/:id" (&key id)
 (with-connection (db)
    (let ((product (retrieve-one
			 (select :*
			   (from :products)
			   (where (:= :code id))))))
      (format t "~a~%" product)
      (render #P"product-detail.html" (list :product product)))))


;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
