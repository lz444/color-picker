#lang racket/gui

(require "cp-resources.rkt")
(require "cp-callbacks.rkt")
(require "my-color.rkt")

(provide text-preview%)

;; Holds the preview text
(define text-preview%
  (class canvas%
    (init [text LoremIpsum])
    (init [font normal-control-font])
    (init [text-color (make-my-color-from-color-string "DimGray")])
    (init [text-position-x 20])
    (init [text-position-y 20])
    (init [background-color (make-my-color-from-color-string "DarkSlateGray")])
    (init [checker-size 40])
    (init [checker-color (make-my-color-from-color-string "DarkGray")])
    (init [alpha #f])
    (define current-text text)
    (define current-font font)
    (define current-text-color text-color)
    (define current-text-x text-position-x)
    (define current-text-y text-position-y)
    (define current-bg-color background-color)
    (define current-checker-size checker-size)
    (define current-checker-color checker-color)
    (define current-alpha alpha)
    (super-new)
    ;; Standard getter/setter methods
    (define/public (get-text) current-text)
    (define/public (get-font) current-font)
    (define/public (get-text-color) current-text-color)
    (define/public (get-text-position-x) current-text-x)
    (define/public (get-text-position-y) current-text-y)
    (define/public (get-background-color) current-bg-color)
    (define/public (get-checker-size) current-checker-size)
    (define/public (get-checker-color) current-checker-color)
    (define/public (get-alpha) current-alpha)
    (define/public (set-text text) (set! current-text text))
    (define/public (set-font font) (set! current-font font))
    (define/public (set-text-color color) (set! current-text-color color))
    (define/public (set-text-position-x x) (set! current-text-x x))
    (define/public (set-text-position-y y) (set! current-text-y y))
    (define/public (set-background-color color) (set! current-bg-color color))
    (define/public (set-checker-size size) (set! current-checker-size size))
    (define/public (set-checker-color color) (set! current-checker-color color))
    (define/public (set-alpha alpha) (set! current-alpha alpha))

    ;; Always draw the text when on-paint is called
    (define/override (on-paint)
                     (define this-dc (send this get-dc))
                     ;; Draw the checkers first, if necessary
                     (if current-alpha
                       (draw-checkers this this-dc #:size current-checker-size #:color (send current-checker-color as-color))
                       (void))
                     ;; Draw the background
                     (let-values ([(width height) (send this-dc get-size)])
                       (send this-dc set-pen no-pen)
                       (send this-dc set-brush (send current-bg-color as-color) 'solid)
                       (send this-dc draw-rectangle 0 0 width height))
                     ;; Draw the text
                     (send this-dc set-text-foreground (send current-text-color as-color))
                     (send this-dc set-font current-font)
                     (send this-dc draw-text current-text current-text-x current-text-y)
				 (super on-paint))
    ))

; vim: expandtab:sw=2
