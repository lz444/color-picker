#lang racket/gui

(require "keys-down.rkt")
(require "sliders-panel.rkt")

(provide color-picker-frame%)

;; A color picker frame, with keyboard controls
(define color-picker-frame%
  (class frame%
    (init keyboard-state-holder)
    ;; Sliders panel for the FG & BG colors. Problem is, often they will be
    ;; defined after the frame, which means you can't pass it along with an
    ;; init. Have to define the frame first, then the sliders-panels, then
    ;; call method set-FGBG-sliders afterwards.
    (init [FGSliders '()])
    (init [BGSliders '()])
    (define keys keyboard-state-holder)
    (define FGS FGSliders)
    (define BGS BGSliders)
    (super-new)
    ;; Takes a list holding FG and BG sliders-panels and sets them for use
    ;; with the current frame.
    ;; The first item should be the FG slider and the second item should be
    ;; the BG slider.
    (define/public (set-FGBG-sliders FGBG)
      (set! FGS (first FGBG))
      (set! BGS (second FGBG)))
    ;; Helper function to get all the textfields in the FG & BG panels
    (define (get-textfields)
      (append (send FGS get-active-textfields) (send BGS get-active-textfields)))
    ;; Custom keyboard event handling
    (define/override (on-subwindow-char receiver event)
                     (define key-pressed? (send keys add-key event))
                     (define all-textfields (get-textfields))
                     (define focused-text-field-fwd (member receiver all-textfields))
                     (if focused-text-field-fwd
                       ;; Textfield has the focus -- Do tab navigation, or let the user type the text in
                       (let ([focused-text-field-backwd (member receiver (reverse all-textfields))]
                             [first-textfield (first all-textfields)]
                             [last-textfield (last all-textfields)])
                         (cond
                           ;; Tab key was pressed without the shift key held down -- go forwards
                           ((and (eq? (send event get-key-code) #\tab) (not (send event get-shift-down)))
                            (if (null? (cdr focused-text-field-fwd))
                              ;; At the last textfield, go to the first textfield
                              (send first-textfield focus)
                              ;; Otherwise go forwards
                              (send (cadr focused-text-field-fwd) focus)))
                           ;; Tab key was pressed with the shift key held down -- go backwards
                           ((and (eq? (send event get-key-code) #\tab) (send event get-shift-down))
                            (if (null? (cdr focused-text-field-backwd))
                              ;; At the first textfield, go to last textfield
                              (send last-textfield focus)
                              ;; Otherwise go backwards
                              (send (cadr focused-text-field-backwd) focus)))
                           ;; Tab key was not pressed -- don't handle the event. Let user type in textfield
                           (else #f)))
                       ;; Textfield doesn't have the focus -- we handle the event
                       #t))
    (define/override (on-subwindow-focus receiver on?)
                     (if on?
                       (fprintf (current-output-port) "~a subwindow focus\n" receiver)
                       (fprintf (current-output-port) "Losing subwindow focus\n")))
    ))

; vim: expandtab:sw=2
