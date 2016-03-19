#lang racket/gui

(require "cp-convert.rkt")
(require "cp-resources.rkt")
(require "my-color.rkt")
(require "color-preview-patch.rkt")

(provide sliders-panel%)

;; Provides a panel holding various widgets for slider controls
;; * Sliders for setting the value
;; * Textfields for manually inputting a value
;; * Textfield for RRGGBB or RRGGBBAA hex
;; * Color preview patch
;; * Button to copy the hex value to the clipboard
;;
;; Can also be used to send the current color to external objects. External
;; objects should take a change-color method which takes a my-color% as the
;; color to be set. Also, a list for external containers which need a refresh
;; sent after the color has been changed.
;; [externals '(obj1 obj2 obj3 ...)
;; [external-containers '(cont1 cont2 cont3 ...)
(define sliders-panel%
  (class group-box-panel%
    (init [color (new my-color% [red 0] [green 0] [blue 0] [alpha MaxSliderVal])])
    (init [mode 'rgb])
    (init [alpha #f])
    (init [externals '()])
    (init [external-containers '()])
    (define current-color color)
    (define current-mode mode)
    (define current-alpha alpha)
    (define current-externals externals)
    (define current-external-containers external-containers)
    (define kb-active #f)
    (super-new)
    ;; Areas to hold the sliders
    (define ActiveBorder (new pane%
                              [parent this]
                              [alignment '(center center)]
                              [min-width SlidersWidth]
                              [min-height SlidersHeight]
                              [stretchable-width #f]
                              [stretchable-height #f]))
    (define BorderSpacing (new pane%
                               [parent ActiveBorder]
                               [alignment '(center center)]
                               [border 20]))
    (define Border (new canvas%
                        [parent ActiveBorder]
                        [style '(transparent)]))
    (define SlidersPane (new vertical-pane% [parent BorderSpacing]))
    (define SlidersContainer
      (build-list 6
                  (λ (n)
                     (new horizontal-panel%
                          [parent SlidersPane]
                          [alignment '(right center)]
                          [min-height WidgetStripHeight]))))

    ;; Now add the controls on
    ;; First the text labels
    (define Labels
      (build-list 5
                  (λ (n)
                     (new message%
                          [label MagentaMsg]
                          [parent (list-ref SlidersContainer n)]
                          [font view-control-font]
                          [auto-resize #t]))))
    ;; Then the sliders
    (define Sliders
      (build-list 5
                  (λ (n)
                     (new slider%
                          [label #f]
                          [min-value MinSliderVal]
                          [max-value MaxSliderVal]
                          [parent (list-ref SlidersContainer n)]
                          [style '(horizontal plain)]
                          [min-width SliderLength]
                          [stretchable-width #f]
                          [stretchable-height #f]
                          [callback
                            (λ (slider event)
                               ;; Push the slider value into the associated textfield
                               (define val-tf (last (send (send slider get-parent) get-children)))
                               (send val-tf set-value (number->string (send slider get-value)))
                               ;; Update the color
                               (update-color-from-textfields! current-mode current-alpha current-color SlidersContainer)
                               ;; Update the panel
                               (update-container current-mode current-alpha current-color 'slider SlidersContainer)
                               (send-color-to-externals))]))))
    ;; Textfields for the color values
    (define ColorValues
      (build-list 5
                  (λ (n)
                     (new text-field%
                          [label #f]
                          [parent (list-ref SlidersContainer n)]
                          [init-value "0"]
                          [font view-control-font]
                          [min-width SliderTextareaWidth]
                          [stretchable-width #f]
                          [stretchable-height #f]
                          [callback
                            (λ (text-field event)
                               (if (valid-digit? (send text-field get-value))
                                 (refresh-on-digit-update)
                                 (void)))]))))
    ;; Finally additional controls for the hex value
    (define HexValue (new text-field%
                            [label AlphaHexMsg]
                            [parent (last SlidersContainer)]
                            [init-value "00CC00CC"]
                            [font huge-control-font]
                            [min-width HexTextareaWidth]
                            [stretchable-width #t]
                            [stretchable-height #f]
                            [callback
                              (λ (text-field event)
                                 (define hex (send text-field get-value))
                                 (if (valid-hex? hex current-alpha)
                                   (refresh-on-hex-update hex)
                                   (void)))]))
    (define PreviewArea (new color-preview-patch%
                               [parent (last SlidersContainer)]
                               [style '(border no-focus)]
                               [color (send current-color as-color)]
                               [min-width ColorPreviewSize]
                               [min-height ColorPreviewSize]
                               [stretchable-width #f]
                               [stretchable-height #f]))
    (define CopyHexToClipboard (new button%
                                      [label ClipboardMsg]
                                      [parent (last SlidersContainer)]
                                      [font tiny-control-font]
                                      [callback
                                        (λ (button event)
                                           (send the-clipboard set-clipboard-string
                                                 (if current-alpha
                                                   (send current-color as-rgba-hex)
                                                   (send current-color as-rgb-hex))
                                                 (send event get-time-stamp)))]))

    ;; Functions to refresh the display
    (define (refresh-borders)
      (define dc (send Border get-dc))
      (if kb-active
        (let-values ([(width height) (send dc get-size)])
          (send dc set-brush "white" 'transparent)
          (send dc set-pen "black" 10 'solid)
          (send dc draw-rectangle 0 0 width height))
        (begin
          (send dc erase))))
    (define (refresh-on-hex-update hex)
      ;; set color from hex
      (if current-alpha
        (send current-color set-from-rgba-hex hex)
        (send current-color set-from-rgb-hex hex))
      ;; push new values to digit textfields
      (update-digits current-mode current-color SlidersContainer)
      ;; update the panel
      (update-container current-mode current-alpha current-color 'hex SlidersContainer)
      (send-color-to-externals))
    (define (refresh-on-digit-update)
      (update-color-from-textfields! current-mode current-alpha current-color SlidersContainer)
      (update-container current-mode current-alpha current-color 'digit SlidersContainer)
      (send-color-to-externals))

    ;; Standard getter methods
    (define/public (get-kb-active) kb-active)
    (define/public (get-color) current-color)
    (define/public (get-mode) current-mode)
    (define/public (get-alpha) current-alpha)
    (define/public (get-externals) current-externals)
    ;(define/public (get-sliders-container) SlidersContainer) ; for debugging purposes

    ;; Get/Set the slider values & associated textfields
    (define/public (get-digits)
      (build-list 5
                  (λ (n)
                     (send (get-digit n SlidersContainer) get-value))))
    (define/public (set-digits d)
      (for-each (λ (val-in-CV val-from-d)
                   (send val-in-CV set-value val-from-d))
                ColorValues
                d)
      (if (andmap (λ (n) (valid-digit? n)) d)
        (refresh-on-digit-update)
        (void)))

    ;; Get/Set the Hexadecimal value
    (define/public (get-hex)
      (send HexValue get-value))
    (define/public (set-hex hex)
      (send HexValue set-value hex)
      (if (valid-hex? hex current-alpha)
        (refresh-on-hex-update hex)
        (void)))

    ;; Setter methods for use with user interaction
    (define/public (set-kb-active a)
      (set! kb-active a)
      (refresh-borders))
    (define/public (set-mode mode)
      (set! current-mode mode)
      (update-slider-labels current-mode SlidersContainer)
      (update-sliders current-mode current-color SlidersContainer)
      (update-digits current-mode current-color SlidersContainer))
    (define/public (set-alpha alpha)
      (set! current-alpha alpha)
      (send PreviewArea set-alpha alpha)
      (send PreviewArea refresh)
      (update-alpha-controls current-alpha SlidersContainer)
      (update-hex-textarea current-alpha current-color SlidersContainer)
      (for-each (λ (l) (send l set-alpha alpha)) current-external-containers)
      (for-each (λ (l) (send l refresh)) current-external-containers))
    (define/public (set-externals externals) (set! current-externals externals))
    (define/public (set-external-containers containers) (set! current-external-containers containers))
    (define/public (send-color-to-externals)
      (for-each (λ (l) (send l change-color current-color)) current-externals)
      (for-each (λ (l) (send l refresh)) current-external-containers))

    ;; Initialize panel on load
    ;; Initialize textfields to color values
    ;; R, G, B channels
    (send (get-digit 0 SlidersContainer) set-value (number->string (send current-color get-red)))
    (send (get-digit 1 SlidersContainer) set-value (number->string (send current-color get-green)))
    (send (get-digit 2 SlidersContainer) set-value (number->string (send current-color get-blue)))
    ;; Alpha channel
    (send (get-digit 4 SlidersContainer) set-value (number->string (send current-color get-alpha)))
    ;; Initialize the widgets
    (update-alpha-controls current-alpha SlidersContainer)
    (update-slider-labels current-mode SlidersContainer)
    (update-container current-mode current-alpha current-color 'digit SlidersContainer)
    (send-color-to-externals)))

;; Gets the various widgets out of SlidersContainer
(define (get-slider-panel n SlidersContainer)
  (list-ref SlidersContainer n))

(define (get-label n SlidersContainer)
  (first (send (get-slider-panel n SlidersContainer) get-children)))

(define (get-slider n SlidersContainer)
  (second (send (get-slider-panel n SlidersContainer) get-children)))

(define (get-digit n SlidersContainer)
  (last (send (get-slider-panel n SlidersContainer) get-children)))

(define (get-alpha-panel SlidersContainer)
  (fifth SlidersContainer))

(define (get-alpha-label SlidersContainer)
  (first (send (get-alpha-panel SlidersContainer) get-children)))

(define (get-alpha-slider SlidersContainer)
  (second (send (get-alpha-panel SlidersContainer) get-children)))

(define (get-alpha-digit SlidersContainer)
  (last (send (get-alpha-panel SlidersContainer) get-children)))

(define (get-hex SlidersContainer)
  (first (send (last SlidersContainer) get-children)))

(define (get-color-patch SlidersContainer)
  (second (send (last SlidersContainer) get-children)))

;; Refreshes Alpha on controls
(define (update-alpha-controls alpha SlidersContainer)
  (send (get-alpha-panel SlidersContainer) show alpha)
  (if alpha
    (begin
      (send (get-alpha-label SlidersContainer) set-label AlphaMsg)
      (send (get-hex SlidersContainer) set-label AlphaHexMsg))
    (send (get-hex SlidersContainer) set-label HexMsg)))

;; Refreshes Slider labels
(define (update-slider-labels mode SlidersContainer)
  (define Labels (build-list 5 (λ (n) (car (send (list-ref SlidersContainer n) get-children)))))
  (cond
    ((eq? 'rgb mode)
     (send (first SlidersContainer) show #t)
     (send (first Labels) set-label RedMsg)
     (send (second SlidersContainer) show #t)
     (send (second Labels) set-label GreenMsg)
     (send (third SlidersContainer) show #t)
     (send (third Labels) set-label BlueMsg)
     (send (fourth SlidersContainer) show #f))
    ((eq? 'hsl mode)
     (send (first SlidersContainer) show #t)
     (send (first Labels) set-label HueMsg)
     (send (second SlidersContainer) show #t)
     (send (second Labels) set-label SatMsg)
     (send (third SlidersContainer) show #t)
     (send (third Labels) set-label LightMsg)
     (send (fourth SlidersContainer) show #f))
    ((eq? 'cmyk mode)
     (send (first SlidersContainer) show #t)
     (send (first Labels) set-label CyanMsg)
     (send (second SlidersContainer) show #t)
     (send (second Labels) set-label MagentaMsg)
     (send (third SlidersContainer) show #t)
     (send (third Labels) set-label YellowMsg)
     (send (fourth SlidersContainer) show #t)
     (send (fourth Labels) set-label BlackMsg))))

;; The following functions refresh the various widgets in SlidersConatiner
(define (update-color-from-textfields! mode alpha color SlidersContainer)
  (cond
    ((eq? 'rgb mode)
     (send color set-red (string->number (send (get-digit 0 SlidersContainer) get-value)))
     (send color set-green (string->number (send (get-digit 1 SlidersContainer) get-value)))
     (send color set-blue (string->number (send (get-digit 2 SlidersContainer) get-value))))
    ((eq? 'hsl mode)
     (define hue (string->number (send (get-digit 0 SlidersContainer) get-value)))
     (define sat (string->number (send (get-digit 1 SlidersContainer) get-value)))
     (define light (string->number (send (get-digit 2 SlidersContainer) get-value)))
     (send color set-from-hsl hue sat light))
    ((eq? 'cmyk mode)
     (define c (string->number (send (get-digit 0 SlidersContainer) get-value)))
     (define m (string->number (send (get-digit 1 SlidersContainer) get-value)))
     (define y (string->number (send (get-digit 2 SlidersContainer) get-value)))
     (define k (string->number (send (get-digit 3 SlidersContainer) get-value)))
     (send color set-from-cmyk c m y k)))
  (if alpha
    (send color set-alpha (string->number (send (get-alpha-digit SlidersContainer) get-value)))
    (send color set-alpha MaxSliderVal)))

(define (update-sliders mode color SlidersContainer)
  (cond
    ((eq? 'rgb mode)
     (send (get-slider 0 SlidersContainer) set-value (send color get-red))
     (send (get-slider 1 SlidersContainer) set-value (send color get-green))
     (send (get-slider 2 SlidersContainer) set-value (send color get-blue)))
    ((eq? 'hsl mode)
     (define hsl (send color as-hsl))
     (send (get-slider 0 SlidersContainer) set-value (first hsl))
     (send (get-slider 1 SlidersContainer) set-value (second hsl))
     (send (get-slider 2 SlidersContainer) set-value (third hsl)))
    ((eq? 'cmyk mode)
     (define cmyk (send color as-cmyk))
     (send (get-slider 0 SlidersContainer) set-value (first cmyk))
     (send (get-slider 1 SlidersContainer) set-value (second cmyk))
     (send (get-slider 2 SlidersContainer) set-value (third cmyk))
     (send (get-slider 3 SlidersContainer) set-value (fourth cmyk))))
  (send (get-alpha-slider SlidersContainer) set-value (send color get-alpha)))

(define (update-hex-textarea alpha color SlidersContainer)
  (if alpha
    (send (get-hex SlidersContainer) set-value (send color as-rgba-hex))
    (send (get-hex SlidersContainer) set-value (send color as-rgb-hex))))

(define (update-container mode alpha color widget SlidersContainer)
  (if (not (eq? widget 'hex)) (update-hex-textarea alpha color SlidersContainer) (void))
  (if (not (eq? widget 'slider)) (update-sliders mode color SlidersContainer) (void))
  (send (get-color-patch SlidersContainer) set-color (send color as-color))
  (send (get-color-patch SlidersContainer) refresh))

(define (update-digits mode color SlidersContainer)
  (cond
    ((eq? 'rgb mode)
     (send (get-digit 0 SlidersContainer) set-value (number->string (send color get-red)))
     (send (get-digit 1 SlidersContainer) set-value (number->string (send color get-green)))
     (send (get-digit 2 SlidersContainer) set-value (number->string (send color get-blue))))
    ((eq? 'hsl mode)
     (define hsl (send color as-hsl))
     (send (get-digit 0 SlidersContainer) set-value (number->string (first hsl)))
     (send (get-digit 1 SlidersContainer) set-value (number->string (second hsl)))
     (send (get-digit 2 SlidersContainer) set-value (number->string (third hsl))))
    ((eq? 'cmyk mode)
     (define cmyk (send color as-cmyk))
     (send (get-digit 0 SlidersContainer) set-value (number->string (first cmyk)))
     (send (get-digit 1 SlidersContainer) set-value (number->string (second cmyk)))
     (send (get-digit 2 SlidersContainer) set-value (number->string (third cmyk)))
     (send (get-digit 3 SlidersContainer) set-value (number->string (fourth cmyk)))))
  (send (get-alpha-digit SlidersContainer) set-value (number->string (send color get-alpha))))


; vim: expandtab:sw=2
