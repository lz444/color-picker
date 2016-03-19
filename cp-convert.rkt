#lang racket/gui

(require "cp-resources.rkt")

(provide (all-defined-out))

;; Various conversion functions

(define (rgb->hex r g b)
  (string-append
    (~r r #:base 16 #:min-width 2 #:pad-string "0")
    (~r g #:base 16 #:min-width 2 #:pad-string "0")
    (~r b #:base 16 #:min-width 2 #:pad-string "0")))

(define (rgba->hex r g b [a MaxSliderVal])
  (string-append
    (rgb->hex r g b)
    (~r a #:base 16 #:min-width 2 #:pad-string "0")))

(define (hex->rgb hex)
  (define r (string->number (substring hex 0 2) 16))
  (define g (string->number (substring hex 2 4) 16))
  (define b (string->number (substring hex 4 6) 16))
  (list r g b))

(define (hex->rgba hex)
  (define r (string->number (substring hex 0 2) 16))
  (define g (string->number (substring hex 2 4) 16))
  (define b (string->number (substring hex 4 6) 16))
  (define a (string->number (substring hex 6 8) 16))
  (list r g b a))

(define (hex->color hex)
  (define r (string->number (substring hex 0 2) 16))
  (define g (string->number (substring hex 2 4) 16))
  (define b (string->number (substring hex 4 6) 16))
  (define a (/ (string->number (substring hex 6 8) 16) (* MaxSliderVal 1.0)))
  (make-color r g b a))

(define (color->hex color)
  (define r (send color red))
  (define g (send color green))
  (define b (send color blue))
  (define a (exact-round (* (send color alpha) MaxSliderVal)))
  (rgba->hex r g b a))

;; Takes R, G, B from 0 to 255, returns (list H S L) from 0 to 255
(define (rgb->hsl r g b)
  (define-values (norm-r norm-g norm-b) (values (/ r 255.0) (/ g 255.0) (/ b 255.0)))
  (define min-val (min norm-r norm-g norm-b))
  (define max-val (max norm-r norm-g norm-b))
  (define delta-max (- max-val min-val))
  (define light (/ (+ max-val min-val) 2))
  (if (zero? delta-max)
    (list 0 0 (exact-round (* light 255))) ;; Hue & Sat are 0
    (let*
      ([sat
         (if (< light 0.5)
           (/ delta-max (+ max-val min-val))
           (/ delta-max (- 2 max-val min-val)))]
       [delta-r
         (/ (+ (/ (- max-val norm-r) 6) (/ delta-max 2)) delta-max)]
       [delta-g
         (/ (+ (/ (- max-val norm-g) 6) (/ delta-max 2)) delta-max)]
       [delta-b
         (/ (+ (/ (- max-val norm-b) 6) (/ delta-max 2)) delta-max)]
       [hue
         (let ([hue-t
                 (cond
                   ((= norm-r max-val) (- delta-b delta-g))
                   ((= norm-g max-val) (- (+ (/ 1 3) delta-r) delta-b))
                   ((= norm-b max-val) (- (+ (/ 2 3) delta-g) delta-r)))])
           (cond
             ((< hue-t 0) (add1 hue-t))
             ((> hue-t 1) (sub1 hue-t))
             (else hue-t)))])
      (list (exact-round (* hue 255)) (exact-round (* sat 255)) (exact-round (* light 255))))))
;; Helper function for hsl->rgb
(define (hue2rgb p q t)
  (define temp
    (cond
      ((< t 0) (add1 t))
      ((> t 1) (sub1 t))
      (else t)))
  (cond
    ((< (* 6 temp) 1) (+ p (* (- q p) 6 temp)))
    ((< (* 2 temp) 1) q)
    ((< (* 3 temp) 2) (+ p (* (- q p) (- (/ 2 3) temp) 6)))
    (else p)))
;; Takes H, S, L from 0 to 255, returns (list R G B) from 0 to 255
(define (hsl->rgb hue sat light)
  (if (zero? sat)
    (list light light light)
    (let-values ([(norm-hue norm-sat norm-light) (values (/ hue 255.0) (/ sat 255.0) (/ light 255.0))])
      (let*
        ([q
           (if (< norm-light 0.5)
             (* norm-light (add1 norm-sat))
             (- (+ norm-light norm-sat) (* norm-sat norm-light)))]
         [p (- (* 2 norm-light) q)]
         [norm-r (hue2rgb p q (+ norm-hue (/ 1 3)))]
         [norm-g (hue2rgb p q norm-hue)]
         [norm-b (hue2rgb p q (- norm-hue (/ 1 3)))])
        (map (λ (n) (exact-round (* n 255))) (list norm-r norm-g norm-b))))))

;; Takes R, G, B from 0 to 255 and returns (list C M Y K) from 0 to 255
(define (rgb->cmyk r g b)
  (define-values (norm-r norm-g norm-b) (values (/ r 255.0) (/ g 255.0) (/ b 255.0)))
  (define norm-k (- 1 (max norm-r norm-g norm-b)))
  (define norm-c (/ (- 1 norm-r norm-k) (- 1 norm-k)))
  (define norm-m (/ (- 1 norm-g norm-k) (- 1 norm-k)))
  (define norm-y (/ (- 1 norm-b norm-k) (- 1 norm-k)))
  (map (λ (n) (exact-round (* n 255))) (list norm-c norm-m norm-y norm-k)))
;; Takes C, M, Y, K from 0 to 255 and returns (list R G B) from 0 to 255
(define (cmyk->rgb c m y k)
  (define-values (norm-c norm-m norm-y norm-k) (values (/ c 255.0) (/ m 255.0) (/ y 255.0) (/ k 255.0)))
  (define norm-r (* (- 1 norm-c) (- 1 norm-k)))
  (define norm-g (* (- 1 norm-m) (- 1 norm-k)))
  (define norm-b (* (- 1 norm-y) (- 1 norm-k)))
  (map (λ (n) (exact-round (* n 255))) (list norm-r norm-g norm-b)))

(define (valid-digit? s)
  (define n (string->number s))
  (and
    (exact-nonnegative-integer? n)
    (>= n MinSliderVal)
    (<= n MaxSliderVal)))

(define (valid-hex? s alpha)
  (cond
    ((and (not alpha) (= (string-length s) 6))
     (define r (string->number (substring s 0 2) 16))
     (define g (string->number (substring s 2 4) 16))
     (define b (string->number (substring s 4 6) 16))
     (and r g b))
    ((and alpha (= (string-length s) 8))
     (define r (string->number (substring s 0 2) 16))
     (define g (string->number (substring s 2 4) 16))
     (define b (string->number (substring s 4 6) 16))
     (define a (string->number (substring s 6 8) 16))
     (and r g b a))
    (else #f)))


; vim: expandtab:sw=2
