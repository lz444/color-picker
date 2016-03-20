#lang racket/gui

(provide text-field-with-select-all%)

;; A text-field with a select all functoin
(define text-field-with-select-all%
  (class text-field%
    (super-new)
    ;; If the mouse click is after dblclick-expire, treat it as a single click.
    ;; We get select-all on focus, and select all on first click with this
    ;; solution.
    (define dblclick-expire (current-milliseconds))

    (define/public (select-all)
      (define ed (send this get-editor))
      (define end-position (string-length (send ed get-text)))
      (send ed set-position 0 end-position))

    (define/override (on-subwindow-focus receiver on?)
                     (if on?
                       (let ([ed (send this get-editor)])
                         (set! dblclick-expire (+ (current-milliseconds) (send (send ed get-keymap) get-double-click-interval)))
                         (select-all))
                       (void)))

    (define/override (on-subwindow-event receiver event)
                     (if (send event button-down? 'left)
                       (let ([ed (send this get-editor)]
                             [ts (current-milliseconds)])
                         (if (< ts dblclick-expire)
                           (select-all)
                           (begin
                             ;; Update the doubleclick-expiration time, then let the regular
                             ;; on-subwindow-event handle the mouse event
                             (set! dblclick-expire (+ ts (send (send ed get-keymap) get-double-click-interval)))
                             (super on-subwindow-event receiver event))))
                       ;; Let the regular on-subwindow-event handle all other
                       ;; mouse events
                       (super on-subwindow-event receiver event)))))

; vim: expandtab:sw=2
