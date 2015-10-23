;; Copyright (c) 2015 Robert Virding
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;; File    : cl.lfe
;; Author  : Robert Virding, Duncan McGreggor
;; Purpose : LFE Common Lisp interface library.

(defmodule cl
  (export
   ;; Boolean conversion functions.
   (make-lfe-bool 1) (make-cl-bool 1)
   ;; Sequences.
   (find 2) (find-if 2) (find-if-not 2) (position 2) (position-if 2)
   (position-if-not 2) (count 2) (count-if 2) (count-if-not 2)
   ;; Substitution of expressions.
   (subst 3) (subst-if 3) (subst-if-not 3) (sublis 2)
   ;; Lists as sets.
   (member 2) (member-if 2) (member-if-not 2) (adjoin 2) (union 2)
   (intersection 2) (set-difference 2) (set-exclusive-or 2) (subsetp 2)
   (subtract 2)
   ;; Association list functions.
   (acons 3) (pairlis 2) (pairlis 3) (assoc 2) (assoc-if 2) (assoc-if-not 2)
   (rassoc 2) (rassoc-if 2) (rassoc-if-not 2)
   ;; Property list functions.
   (get 2) (get 3) (getl 3) (putprop 3) (remprop 3)
   (getf 2) (getf 3) (putf 3) (remf 2) (get-properties 2)
   )
  (export all))

;; Test defining CL if and cond.

(defmacro cl:if
  ((list test if-true) `(cl:if ,test ,if-true ()))
  ((list test if-true if-false)
   `(case ,test
      (() ,if-false)
      (_ ,if-true))))

(defmacro cl:cond args
  (fletrec ((exp-cond
	     ([(cons (list test) cond)]
	       `(let ((|\|-cond-test-\|| ,test))
		  (cl:if |\|-cond-test-\|| |\|-cond-test-\|| ,(exp-cond cond))))
	     ([(cons (cons test body) cond)]
	      `(cl:if ,test (progn . ,body) ,(exp-cond cond)))
	     ([()] ())))
    (exp-cond args)))

;;; Boolean conversion functions.

(defun make-lfe-bool		        ;Make an LFE bool from a CL value
  ([()] 'false)
  ([_] 'true))				;Everything else is true

(defun make-cl-bool			;Make a CL bool from an LFE value
  (['false] ())
  (['true] 'true))

;;; Lists

(defun car
  ([()] ())
  ([xs] (car xs)))

(defun first (xs)
  (cl:car xs))

(defun cdr
  ([()] ())
  ([xs] (cdr xs)))

(defun rest (xs)
  (cl:cdr xs))

(defun ncons (x)
  (cons x '()))

(defun xcons (x y)
  (cons y x))

(defun nth
  ([n xs] (when (< n 0)) ())
  ([n xs]
   (fletrec ((nth-loop
	      ([n ()] ())		;End of the list
	      ([0 xs] (car xs))		;Found the one
	      ([n xs] (nth-loop (- n 1) (cdr xs)))))
     (nth-loop n xs))))

(defun elt
  ((n xs) (when (is_list xs))
   (nth n xs))
  ((n xs) (when (is_tuple xs))
   (element (+ n 1) xs)))

(defun aref (array i j)
  (elt j (elt i array)))

;; Sequences.

(defun find (x xs)
  (fletrec ((find-loop
	     ([x (cons x1 xs)] (when (=:= x x1)) x)
	     ([x (cons x1 xs)] (find-loop x xs))
	     ([x ()] ())))
    (find-loop x xs)))

(defun find-if (pred xs)
  (fletrec ((find-if-loop
	     ([pred (cons x xs)]
	      (if (funcall pred x) x (find-if-loop pred xs)))
	     ([pred ()] ())))
    (find-if-loop pred xs)))

(defun find-if-not (pred xs)
  (fletrec ((find-if-not-loop
	     ([pred (cons x xs)]
	      (if (funcall pred x) (find-if-not-loop pred xs) x))
	     ([pred ()] ())))
    (find-if-not-loop pred xs)))

(defun position (x xs)
  (fletrec ((pos-loop
	     ([x n (cons x1 xs)] (when (=:= x x1)) n)
	     ([x n (cons x1 xs)] (pos-loop x (+ n 1) xs))
	     ([x n ()] ())))
    (pos-loop x 0 xs)))

(defun position-if (pred xs)
  (fletrec ((pos-if-loop
	     ([pred n (cons x xs)]
	      (if (funcall pred x)
		  n (pos-if-loop pred (+ n 1) xs)))
	     ([pred n ()] ())))
    (pos-if-loop pred 0 xs)))

(defun position-if-not (pred xs)
  (fletrec ((pos-if-not-loop
	     ([pred n (cons x xs)]
	      (if (funcall pred x)
		  (pos-if-not-loop pred (+ n 1) xs) n))
	     ([pred n ()] ())))
    (pos-if-not-loop pred 0 xs)))

(defun count (x xs)
  (fletrec ((count-loop
	     ([x n (cons x1 xs)]
	      (let ((n1 (if (=:= x x1) (+ n 1) n)))
		(count-loop x n1 xs)))
	     ([x n ()] n)))
    (count-loop x 0 xs)))

(defun count-if (pred xs)
  (fletrec ((count-if-loop
	     ([pred n (cons x xs)]
	      (let ((n1 (if (funcall pred x) (+ n 1) n)))
		(count-if-loop pred n1 xs)))
	     ([pred n ()] n)))
    (count-if-loop pred 0 xs)))

(defun count-if-not (pred xs)
  (fletrec ((count-if-not-loop
	     ([pred n (cons x xs)]
	      (let ((n1 (if (funcall pred x) n (+ n 1))))
		(count-if-not-loop pred n1 xs)))
	     ([pred n ()] n)))
    (count-if-not-loop pred 0 xs)))

(defun butlast (xs)
  (lists:droplast xs))

(defun nthcdr (n xs)
  (lists:nthtail (+ n 1) xs))

(defun every (pred xs)
  (lists:all pred xs))

(defun some (pred xs)
  (lists:any pred xs))

(defun notevery (pred xs)
  (not (lists:all pred xs)))

(defun notany (pred xs)
  (not (lists:any pred xs)))

(defun mapcar (func xs)
  (lists:map func xs))

;; XXX maplist flattens everything; the results need to remain grouped by
;; sublist to maintain parity with CL usage/results.

;;(defun maplist (func xs)
;;  (maplist func (mapcar func xs) xs))

;;(defun maplist
;;  ((_ acc '())
;;   acc)
;;  ((func acc `(,_ . ,xs))
;;   (maplist func (++ acc (mapcar func xs)) xs)))

(defun remove-duplicates (xs)
  (lists:usort xs))

(defun remove-if-not (func xs)
  (lists:filter func xs))

(defun reduce (func xs)
  (lists:foldl func '() xs))

(defun reduce
  ((func xs 'initial-value x)
   (lists:foldl func x xs))
  ((func xs 'from-end 'true)
   (lists:foldr func '() xs)))

(defun reduce
  ((func xs 'from-end 'true 'initial-value x)
   (lists:foldr func x xs))
  ((func xs 'initial-value x 'from-end 'true)
   (lists:foldr func x xs)))

;; Substitution of expressions

(defun subst
  ([new old tree] (when (=:= old tree)) new)
  ([new old (cons e rest)]
   (cons (subst new old e) (subst new old rest)))
  ([new old tree] tree))

(defun subst-if (new test tree)
  (if (funcall test tree) new		;cl:if?
      (case tree
	((cons e rest)
	 (cons (subst-if new test e) (subst-if new test rest)))
	(_ tree))))

(defun subst-if-not (new test tree)
  (if (funcall test tree)		;cl:if?
      (case tree
	((cons e rest)
	 (cons (subst-if-not new test e) (subst-if-not new test rest)))
	(_ tree))
      new))

(defun sublis (alist tree)
  (case (assoc tree alist)
    ((cons _ new) new)			;Found it
    (()					;Not there
     (case tree
       ((cons e rest)
	(cons (sublis alist e) (sublis alist rest)))
       (_ tree)))))

;; Lists as sets.

(defun member (item list)
  (lists:member item list))

(defun member-if
  ([pred (cons e list)]
   (if (funcall pred e)			;cl:if?
       'true
       (member-if pred list)))
  ([pred ()] ()))

(defun member-if-not
  ([pred (cons e list)]
   (if (funcall pred e)			;cl:if?
       (member-if-not pred list)
       'true))
  ([pred ()] ()))

(defun adjoin (item list)
  (if (member item list)
      list
      (cons item list)))

(defun union
  ([(cons e l1) l2]
   (if (member e l2)
       (union l1 l2)
       (cons e (union l1 l2))))
  ([() l2] l2))

(defun intersection (l1 l2)
  (lc ((<- e l1) (member e l2)) e))

(defun set-difference (l1 l2)
  (lc ((<- e l1) (not (member e l2))) e))

(defun set-exclusive-or (l1 l2)
  (++ (set-difference l1 l2) (set-difference l2 l1)))

(defun subsetp
  ([(cons e l1) l2]
   (if (member e l2)
       (subsetp l1 l2)
       'false))
  ([() l2] 'true))

(defun subtract (l1 l2)
  (lc ((<- e l1) (not (member e l2))) e))

;; Association list functions.

(defun acons (k v alist)
  (cons (cons k v) alist))

(defun pairlis (ks vs) (pairlis ks vs ()))

(defun pairlis
  ([(cons k ks) (cons v vs) alist]
   (cons (cons k v) (pairlis ks vs alist)))
  ([() () alist] alist))

(defun assoc
  ([k (cons (= (cons k1 v) pair) _)] (when (=:= k k1)) pair)
  ([k (cons _ alist)] (assoc k alist))
  ([k ()] ()))

(defun assoc-if
  ([pred (cons (= (cons k _) pair) alist)]
   (if (funcall pred k) pair		;cl:if?
       (assoc-if pred alist)))
  ([pred ()] ()))

(defun assoc-if-not
  ([pred (cons (= (cons k _) pair) alist)]
   (if (funcall pred k)			;cl:if?
       (assoc-if pred alist)
       pair))
  ([pred ()] ()))

(defun rassoc
  ([v (cons (= (cons _ v1) pair) _)] (when (=:= v v1)) pair)
  ([v (cons _ alist)] (assoc v alist))
  ([v ()] ()))

(defun rassoc-if
  ([pred (cons (= (cons _ v) pair) alist)]
   (if (funcall pred v) pair		;cl:if
       (rassoc-if pred alist)))
  ([pred ()] ()))

(defun rassoc-if-not
  ([pred (cons (= (cons _ v) pair) alist)]
   (if (funcall pred v)			;cl:if?
       (assoc-if pred alist)
       pair))
  ([pred ()] ()))

;; Property list functions.
;;  get, getl, putprop and remprop should really only work on a
;;  symbols plist not just a plist. This is coming. Hence including
;;  getf, putf and remf.

(defun get (plist pname)
  (getf plist pname))

(defun get (plist pname def)
  (getf plist pname def))

(defun getl				;This comes from LM lisp
  ([(= (list* p v plist-rest) plist) pnames]
   (if (member p pnames)
       plist
       (getl plist-rest pnames)))
  ([() pnames] ()))

(defun putprop (plist val pname)
  (putf plist val pname))

(defun remprop (plist pname) (remf plist pname))

(defun getf (plist pname)
  (getf plist pname ()))

(defun getf
  ([(list* p v plist) pname def] (when (=:= p pname)) v)
  ([(list* _ _ plist) pname def] (getf plist pname def))
  ([() pname def] def))

(defun putf				;This doesn't exist in CL
  ([(list* p _ plist) val pname] (when (=:= p pname))
   (list* pname val plist))
  ([(list* p v plist) val pname]
   (list* p v (putf plist val pname)))
  ([() val pname] (list pname val)))

(defun remf
  ([(list* p _ plist) pname] (when (=:= p pname)) plist)
  ([(list* p v plist) pname]
   (list* p v (remf plist pname)))
  ([() pname] ()))

(defun get-properties
  ([(= (list* p v plist-rest) plist) pnames]
   (if (member p pnames)
       (tuple p v plist)
       (get-properties plist-rest pnames)))
  ([() pnames] (tuple () () ())))

;;; Types

(defun type-of
  ((x) (when (is_boolean x))
   'boolean)
  ((x) (when (is_atom x))
   'atom)
  ((x) (when (is_tuple x))
   'tuple)
  ((x) (when (is_integer x))
   'integer)
  ((x) (when (is_float x))
   'float)
  ((x) (when (is_list x))
   (cond ((io_lib:printable_latin1_list x) 'string)
         ((io_lib:printable_unicode_list x) 'unicode)
         ((?= `(,a . ,b) (when (not (is_list b))) x) 'cons)
         ('true 'list)))
  ((x) (when (is_map x))
   'map)
  ((x) (when (is_function x))
   'function)
  ((x) (when (is_binary x))
   'binary)
  ((x) (when (is_bitstring x))
   'bitstring)
  ((x) (when (is_pid x))
   'pid)
  ((x) (when (is_port x))
   'port)
  ((x) (when (is_reference x))
   'reference))

(defun coerce
  ((x 'vector) (when (is_list x))
   (list_to_tuple x))
  ((x 'tuple) (when (is_list x))
   (list_to_tuple x))
  ((x 'atom) (when (is_list x))
   (list_to_atom x))
  ((x 'list) (when (is_atom x))
   (atom_to_list x))
  ((x 'list) (when (is_tuple x))
   (tuple_to_list x))
  ((x 'list) (when (is_binary x))
   (binary_to_list x))
  ((x 'list) (when (is_bitstring x))
   (bitstring_to_list x))
  ((x 'character) (when (is_atom x))
   (car (atom_to_list x)))
  ((x 'character) (when (is_list x))
   (car x))
  ((x 'integer) (when (is_float x))
   (trunc x))
  ((x 'float) (when (is_integer x))
   (list_to_float (integer_to_list x)))
  ((x 'float) (when (is_list x))
   (list_to_float x))
  ((x 'float) (when (is_atom x))
   (list_to_float (atom_to_list x)))
  ((x 't)
   x))

;;; System

(defun posix-argv ()
  (init:get_arguments))
