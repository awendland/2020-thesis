;; ======
;; Demo 2.2 - example date library
;;
;; Reference: Section 3.2 in the thesis (and also Section 3.4)
;; Dependencies: Core WebAssembly + abstract types (https://github.com/awendland/webassembly-spec-abstypes)
;;
;; NOTE: This sample is a poor implementation for a date library because it incorrectly assumes that 1 year is always 31,557,600,000 milliseconds. Do not use it.
;; ======

(module $lib_date
  (abstype_new $Date i32)
  (func (export "createDate")
    (param $day i32) (param $month i32) (param $year i32)
    (result (abstype_new_ref $Date))
    (i32.add ;; Day, Mon, Year -> Unix milliseconds
      (i32.mul (local.get $day) (i32.const 86400))
      (i32.add
        (i32.mul (local.get $month) (i32.const 2592000))
        (i32.mul (i32.const 31557600)
          (i32.sub (local.get $year) (i32.const 1970)))))
  )
  (func (export "yearsBetweenDates") (param (abstype_new_ref $Date))
    (param (abstype_new_ref $Date)) (result i32)
    (i32.sub (local.get 0) (local.get 1))
    (i32.div_s (i32.const 31557600))
  )
  (export "Date" (abstype_new_ref $Date))
)
(register "lib_date" $lib_date)

(module $main
  (import "lib_date" "Date" (abstype_sealed $Date))
  (import "lib_date" "createDate" (func $createDate
    (param i32) (param i32) (param i32)
    (result (abstype_sealed_ref $Date))))
  (import "lib_date" "yearsBetweenDates" (func $yearsBetweenDates
    (param (abstype_sealed_ref $Date))
    (param (abstype_sealed_ref $Date)) (result i32)))
  (func (export "main") (result i32)
    (call $createDate
      (i32.const 2) (i32.const 20) (i32.const 1962))
    (call $createDate
      (i32.const 8) (i32.const 26) (i32.const 1918))
    (call $yearsBetweenDates)
  )
)
(assert_return (invoke $main "main") (i32.const 43))



;; ======
;; Addendum: Comparable OCaml
;;
;; ```ocaml
;; (* lib.ml *)
;; module Date = sig
;;   type date (* public, abstract type *)
;; end =
;; struct
;;   type date = {day : int;  month : int;  year : int} (* private, concrete type *)
;;   val create : ?days:int -> ?months:int -> ?years:int -> unit -> date
;;   val yearsBetweenDates : date -> date -> int
;;   val month : date -> int
;;   ...
;; end
;;
;; (* consumer.ml *)
;; let kjohnson_bday : Date.date = Date.create 8 26 1918 () in
;; let mercury_launch : Date.date = Date.create 2 20 1962 () in
;; let kj_age_at_launch = Date.yearsBetweenDates kjohnson_bday mercury_launch in ...
;; (* kjognson_bday.day <- this access is invalid *)
;; ```
;; ======



;; ======
;; Addendum: Alternative Abstract Type Syntax
;;
;; ```commonlisp
;; (module $lib_date
;;   (export "Date" (newtype $Date i32))
;;   (func (export "createDate")
;;     (param $day i32) (param $month i32) (param $year i32) (result (type $Date))
;;     (i32.add
;;       (i32.mul (local.get $day) (i32.const 86400))
;;       (i32.add
;;         (i32.mul (local.get $month) (i32.const 2592000))
;;         (i32.mul (i32.const 31557600)
;;           (i32.sub (local.get $year) (i32.const 1970))
;;     )))
;;   )
;;   (func (export "yearsBetweenDates")
;;     (param (type $Date)) (param (type $Date)) (result i32)
;;     (i32.sub (local.get 0) (local.get 1))
;;     (i32.div_s (i32.const 31557600))
;;   )
;; )
;; (register "lib_date" $lib_date)
;;
;; (module $main
;;   (import "lib_date" "Date" (type $Date))
;;   (import "lib_date" "createDate" (func $createDate
;;     (param i32) (param i32) (param i32) (result (type $Date))))
;;   (import "lib_date" "yearsBetweenDates" (func $yearsBetweenDates
;;     (param (type $Date)) (param (type $Date)) (result i32)))
;;   (func (export "main") (result i32)
;;     (call $createDate
;;       (i32.const 2) (i32.const 20) (i32.const 1962))
;;     (call $createDate
;;       (i32.const 8) (i32.const 26) (i32.const 1918))
;;     (call $yearsBetweenDates)
;;   )
;; )
;; ```
;; ======
