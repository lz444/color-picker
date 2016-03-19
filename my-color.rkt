#lang racket/gui

(require "cp-convert.rkt")
(require "cp-resources.rkt")

(provide my-color%)
(provide make-my-color-from-color-string)

;; my-color% class holds RGBA color values, from 0 to 255 inclusive.
;; Has functions to get as various types:
;; * RGB and RGBA hex string
;; * Racket color%
;; * HSL and CMYK
(define my-color%
  (class object%
    (init [red 0])
    (init [green 0])
    (init [blue 0])
    (init [alpha 255])
    (define r red)
    (define g green)
    (define b blue)
    (define a alpha)
    (super-new)
    ;; Standard Getter/Setter functions
    (define/public (get-red) r)
    (define/public (get-green) g)
    (define/public (get-blue) b)
    (define/public (get-alpha) a)
    (define/public (get-rgba-list) (list r g b a))
    (define/public (set-red red) (set! r red))
    (define/public (set-green green) (set! g green))
    (define/public (set-blue blue) (set! b blue))
    (define/public (set-alpha alpha) (set! a alpha))
    (define/public (set-rgba-list colors)
      (set! r (first colors))
      (set! g (second colors))
      (set! b (third colors))
      (set! a (fourth colors)))
    (define/public (change-color color)
      (set! r (send color get-red))
      (set! g (send color get-green))
      (set! b (send color get-blue))
      (set! a (send color get-alpha)))
    ;; Setter functions from various formats
    (define/public (set-from-rgb-hex hex)
      (define colors (hex->rgb hex))
      (set! r (first colors))
      (set! g (second colors))
      (set! b (third colors)))
    (define/public (set-from-rgba-hex hex)
      (define colors (hex->rgba hex))
      (set! r (first colors))
      (set! g (second colors))
      (set! b (third colors))
      (set! a (fourth colors)))
    (define/public (set-from-color color)
      (set! r (send color red))
      (set! g (send color green))
      (set! b (send color blue))
      (set! a (exact-round (* (send color alpha) 255))))
    (define/public (set-from-hsl hue sat light)
      (define colors (hsl->rgb hue sat light))
      (set! r (first colors))
      (set! g (second colors))
      (set! b (third colors)))
    (define/public (set-from-cmyk c m y k)
      (define colors (cmyk->rgb c m y k))
      (set! r (first colors))
      (set! g (second colors))
      (set! b (third colors)))
    ;; Conversion functions
    (define/public (as-rgb-hex) (rgb->hex r g b))
    (define/public (as-rgba-hex) (rgba->hex r g b a))
    (define/public (as-color) (make-color r g b (/ a 255.0)))
    (define/public (as-hsl) (rgb->hsl r g b))
    (define/public (as-cmyk) (rgb->cmyk r g b))))

;; Takes a color string and makes a new my-color% from it.
;; See http://docs.racket-lang.org/draw/color-database___.html
;; for the list of color strings
(define (make-my-color-from-color-string str)
  (define color (send the-color-database find-color str))
  (if color
    (let
      ([return (new my-color%)])
      (send return set-from-color color)
      return)
    ;; Color is #f means the color wasn't found
    color))

; vim: expandtab:sw=2
