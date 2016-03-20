#lang racket/gui

(provide keys-down%)

;; Keeps track which keyboard keys are still held down
(define keys-down%
  (class object%
    (super-new)
    ;; Keeps track which keys are held down.
    (define keys '())
    ;; Attempts to add the keyeven to the held-down list.
    ;; Mousewheel events are ignored.
    ;; Return value is whether the key is pushed down
    ;; #t: key was pushed down
    ;; #f: key was held down, or key was released, or key was a mousewheel event
    (define/public (add-key key-event)
      (define keycode (send key-event get-key-code))
      (cond
        ;; Exclude mousewheel events
        ((or (eq? keycode 'wheel-up) (eq? keycode 'wheel-down) (eq? keycode 'wheel-left) (eq? keycode 'wheel-right))
         #f)
        ;; Key release event, remove it from the list
        ((eq? keycode 'release)
         (set! keys (remove (send key-event get-key-release-code) keys))
         #f)
        ;; Key still held down, do nothing
        ((is-key-down? key-event)
         #f)
        ;; Add key to list
        (else
          (set! keys (cons keycode keys))
          #t)))
    ;; How may keys are still held down
    (define/public (num-keys) (length keys))
    ;; Is this key currently down?
    (define/public (is-key-down? key-event)
      (define keycode (send key-event get-key-code))
      (member keycode keys))
    ;; All the keys currently held down
    (define/public (all-keys-down) keys)))

; vim: expandtab:sw=2
