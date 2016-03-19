#lang racket/gui

(require "cp-resources.rkt")
(provide (all-defined-out))

;; Helper functions used by the callback functions
;; Bring up a font selection dialog when user clicks on the Change Font button
(define (font-selection textstyle textsample mainwindow)
  (define oldfont (send (send (send textsample get-style-list) basic-style) get-font))
  (define newfont (get-font-from-user #f mainwindow oldfont))
  (if newfont
    (begin
      (send textstyle set-face (send newfont get-face))
      (send textsample change-style textstyle 0))
    (void)))

;; Switches between editing text or not
(define (switch-edit-text button textsample)
  (if (send textsample is-locked?)
    (begin
      ;; Change button text
      (send button set-label FinishEditMsg)
      ;; Unlock editor
      (send textsample lock #f)
      (send textsample hide-caret #f))
    (begin
      ;; Change button text
      (send button set-label EditTextMsg)
      ;; Lock editor
      (send textsample lock #t)
      (send textsample hide-caret #t))))

;; Swaps values in the textfields assoicated with the sliders between two slider-panels
(define (swap-digits SP1 SP2)
  (let ([old1 (send SP1 get-digits)]
        [old2 (send SP2 get-digits)])
    (send SP1 set-digits old2)
    (send SP2 set-digits old1)))


;; Draws a checkerbox background
(define (draw-checkers
          canvas
          dc
          #:color [ch-color (send the-color-database find-color "darkgray")]
          #:size [ch-size 10])
  ;; First we make a checker bitmap. We will use this bitmap as a stipple
  ;; later, so make it monochrome here.
  (define checkers (make-monochrome-bitmap ch-size ch-size))
  (define checker-dc (send checkers make-dc))
  ;; Set the pen & brush
  (send checker-dc set-brush "black" 'solid)
  (send checker-dc set-pen no-pen)
  ;; Define areas for the checker squares
  (define ¼size (ceiling (/ ch-size 4)))       ; CTRL-v u 00bc
  (define ½size (truncate (/ ch-size 2)))      ; CTRL-v u 00bd
  (define ¾size (ceiling (* 3 (/ ch-size 4)))) ; CTRL-v u 00be
  ;; Draw four small corner rectangles
  (send checker-dc draw-rectangle 0 0 ¼size ¼size)
  (send checker-dc draw-rectangle ¾size 0 ¼size ¼size)
  (send checker-dc draw-rectangle 0 ¾size ¼size ¼size)
  (send checker-dc draw-rectangle ¾size ¾size ¼size ¼size)
  ;; Draw one larger rectangle in the middle
  (send checker-dc draw-rectangle ¼size ¼size ½size ½size)
  (let-values ([(width height) (send dc get-size)])
    ;; Now we use the checker bitmap as a stipple. The checkers will take the color now
    (define checker-brush (new brush% [color ch-color] [stipple checkers]))
    ;; Draw the entire canvas with the checkerboxes
    (send dc set-pen no-pen)
    (send dc set-brush checker-brush)
    (send dc draw-rectangle 0 0 width height)))

; vim: expandtab:sw=2
