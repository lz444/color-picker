#lang racket/gui

(require "cp-callbacks.rkt")
(require "cp-resources.rkt")

(provide color-preview-patch%)

;; This provides a canvas which serves as a color preview
(define color-preview-patch%
  (class canvas%
    (init [color (send the-color-database find-color "lightblue")])
    (init [checker-color (send the-color-database find-color "darkgray")])
    (init [checker-size 10])
    (init [alpha #f])
    (define current-color color)
    (define current-checker-color checker-color)
    (define current-checker-size checker-size)
    (define current-alpha alpha)
    (super-new)

    ;; Standard getter/setter functions
    (define/public (get-color) current-color)
    (define/public (get-checker-color) current-checker-color)
    (define/public (get-checker-size) current-checker-size)
    (define/public (get-alpha) current-alpha)
    (define/public (set-color color) (set! current-color color))
    (define/public (set-checker-color color) (set! current-checker-color color))
    (define/public (set-checker-size size) (set! current-checker-size size))
    (define/public (set-alpha alpha) (set! current-alpha alpha))

    ;; We always draw the checkers & color when on-paint is called
    (define/override (on-paint)
                     (define this-dc (send this get-dc))
                     (if current-alpha
                       (draw-checkers this this-dc #:color current-checker-color #:size current-checker-size)
                       (void))
                     (let-values ([(width height) (send this-dc get-size)])
                       (send this-dc set-pen no-pen)
                       (send this-dc set-brush current-color 'solid)
                       (send this-dc draw-rectangle 0 0 width height))
				 (super on-paint))))
; vim: expandtab:sw=2
