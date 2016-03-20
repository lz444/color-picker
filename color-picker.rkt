#lang racket/gui
(require framework)
(require "cp-resources.rkt")
(require "cp-callbacks.rkt")
(require "cp-convert.rkt")
(require "my-color.rkt")
(require "sliders-panel.rkt")
(require "text-preview.rkt")
(require "color-picker-frame.rkt")

;; Variables holding internal state
(define (using-mode?)
  (define mode (send mode-selector get-selection))
    (cond
      ((= 0 mode) 'rgb)
      ((= 1 mode) 'hsl)
      ((= 2 mode) 'cmyk)))
(define (using-alpha?) (send alpha-selector get-value))

(application:current-app-name AppName)

;; Define areas for the various controls
(define mainwindow (new color-picker-frame%
                        [label AppName]
                        [width AppWidth]
                        [height AppHeight]))

;; App is divided into two halves
(define halves (new horizontal-pane%
                    [parent mainwindow]))

#|
;; Left half holds the text
(define textarea (new vertical-pane%
                      [parent halves]))

;; Editor for the text
(define ec (new editor-canvas%
                     [parent textarea]))

;; Buttons for the text
(define textcontrols (new horizontal-pane%
                          [parent textarea]
                          [alignment '(right center)]
                          [min-height WidgetStripHeight]
                          [stretchable-height #f]))
|#
;; Left half holds the text, help messages, and additional controls
(define text-and-help (new vertical-pane%
                           [parent halves]))

(define textarea (new text-preview%
                      [parent text-and-help]
                      [text LoremIpsum]
                      [font huge-control-font]
                      [style '(no-focus)]))

;; Not used currently, just set the height to 0 to make it invisible
(define helpmsgs (new vertical-pane%
                      [parent text-and-help]
                      [min-height 0]
                      [stretchable-height #f]))

(define extra-buttons (new horizontal-pane%
                           [parent text-and-help]
                           [alignment '(right center)]
                           [min-height WidgetStripHeight]
                           [stretchable-height #f]))

(define swap-colors-button (new button%
                                [parent extra-buttons]
                                [label SwapColorsMsg]
                                [callback
                                  (λ (button event)
                                     (swap-digits FGSliders BGSliders))]))


;; Right half holds the color controls
(define colorarea (new vertical-pane%
                       [parent halves]
                       [min-width ColorControlsWidth]
                       [stretchable-width #f]))

;; Choose between RGB, HSL, CMYK, and toggle Alpha
(define modes (new horizontal-pane%
                   [parent colorarea]
                   [min-height WidgetStripHeight]
                   [stretchable-height #f]))

;; Add Sliders panels
(define FGSliders (new sliders-panel%
                       [label FGMsg]
                       [parent colorarea]
                       [color (make-my-color-from-color-string DefaultFGColor)]
                       [externals (list (send textarea get-text-color))]
                       [external-containers (list textarea)]))
(define BGSliders (new sliders-panel%
                       [label BGMsg]
                       [parent colorarea]
                       [color (make-my-color-from-color-string DefaultBGColor)]
                       [externals (list (send textarea get-background-color))]
                       [external-containers (list textarea)]))

;; Add controls onto the areas
;; Editor for the text
#|
(define textsample (new text%
                      [auto-wrap #t]))
(send ec set-editor textsample)

;; Buttons for the text
(define edit-text-button (new button%
                              [label EditTextMsg]
                              [parent textcontrols]
                              [callback (λ (button event) (switch-edit-text button textsample))]))
(define change-font-button (new button%
                                [label ChangeFontMsg]
                                [parent textcontrols]
                                [callback (λ (button event) (font-selection textstyle textsample mainwindow))]))
|#

;; Mode switch
(define mode-selector (new radio-box%
                           [label #f]
                           [parent modes]
                           [choices (list RGBMsg HSLMsg CMYKMsg)]
                           [style '(horizontal)]
                           [horiz-margin RGBRadioPadding]
                           [callback
                             (λ (radio-box event)
                                (send FGSliders set-mode (using-mode?))
                                (send BGSliders set-mode (using-mode?)))]))
(define alpha-selector (new check-box%
                            [label AlphaModeMsg]
                            [parent modes]
                            [horiz-margin AlphaCheckboxPadding]
                            [callback
                              (λ (check-box event)
                                 (send FGSliders set-alpha (using-alpha?))
                                 (send BGSliders set-alpha (using-alpha?)))]))

(send mainwindow set-FGBG-sliders (list FGSliders BGSliders))
(send mainwindow show #t)

; vim: expandtab:sw=2
