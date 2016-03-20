#lang racket/gui

(require "sliders-panel.rkt")
(require "text-field-with-select-all.rkt")

(provide color-picker-frame%)

;; A color picker frame, with keyboard controls
(define color-picker-frame%
  (class frame%
    ;; Sliders panel for the FG & BG colors. Problem is, often they will be
    ;; defined after the frame, which means you can't pass it along with an
    ;; init. Have to define the frame first, then the sliders-panels, then
    ;; call method set-FGBG-sliders afterwards.
    (init [FGSliders '()])
    (init [BGSliders '()])
    (define FGS FGSliders)
    (define BGS BGSliders)
    (super-new)
    ;; Dummy canvas to receive the keyboard focus when the textfields should
    ;; lose the keyboard focus
    (define dummy-canvas (new canvas% 
                              [parent this]
                              [min-width 0]
                              [min-height 0]
                              [stretchable-width #f]
                              [stretchable-height #f]))
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
                     (define all-textfields (get-textfields))
                     (define focused-text-field-fwd (member receiver all-textfields))
                     (define keycode (send event get-key-code))
                     (define shift-down? (send event get-shift-down))
                     (define first-textfield (first all-textfields))
                     (define last-textfield (last all-textfields))
                     (if focused-text-field-fwd
                       ;; Textfield has the focus -- Do tab navigation, or let the user type the text in
                       (let ([focused-text-field-backwd (member receiver (reverse all-textfields))])
                         (cond
                           ;; Tab key was pressed without the shift key held down -- go forwards
                           ((and (eq? keycode #\tab) (not shift-down?))
                            (if (null? (cdr focused-text-field-fwd))
                              ;; At the last textfield, go to the first textfield
                              (begin (send first-textfield focus)); (send first-textfield select-all))
                              ;; Otherwise go forwards
                              (begin (send (cadr focused-text-field-fwd) focus))); (send (cadr focused-text-field-fwd) select-all)))
                            #t)
                           ;; Tab key was pressed with the shift key held down -- go backwards
                           ((and (eq? keycode #\tab) shift-down?)
                            (if (null? (cdr focused-text-field-backwd))
                              ;; At the first textfield, go to last textfield
                              (send last-textfield focus)
                              ;; Otherwise go backwards
                              (send (cadr focused-text-field-backwd) focus))
                            #t)
                           ;; Enter or Escape key was pressed -- textfield loses focus
                           ((or (eq? keycode #\return) (eq? keycode 'numpad-enter) (eq? keycode 'escape))
                            (send dummy-canvas focus)
                            #t)
                           ;; Tab, Enter, or Escape keys were not pressed -- don't handle the event. Let user type in textfield
                           (else #f)))
                       ;; Textfield doesn't have the focus -- we handle the event
                       ;; Enter first or last textfield on Tab or Shift+Tab
                       (begin
                         (cond
                           ((and (eq? keycode #\tab) (not shift-down?))
                            (send first-textfield focus))
                           ((and (eq? keycode #\tab) shift-down?)
                            (send last-textfield focus)))
                         #t)))))

; vim: expandtab:sw=2
