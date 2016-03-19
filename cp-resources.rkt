#lang racket/gui

(provide (all-defined-out))

;; Resources for the Color Picker app
;; Strings for various UI controls
(define AppName "Color Picker")
(define LoremIpsum "Sample Text")
(define EditTextMsg " \u270f ") ;; Unicode pencil
(define FinishEditMsg " \u2713 ") ;; Unicode checkmark
(define SwapColorsMsg "FG \u21c4 BG")
(define ChangeFontMsg "Change Font")
(define LoremIpsumMsg "Lorem Ipsum text")
(define RGBMsg "RGB")
(define HSLMsg "HSL")
(define CMYKMsg "CMYK")
(define AlphaModeMsg "Alpha")
(define RedMsg "Red: ")
(define GreenMsg "Green: ")
(define BlueMsg "Blue: ")
(define AlphaMsg "Alpha: ")
(define HueMsg "Hue: ")
(define SatMsg "Sat: ")
(define LightMsg "Light: ")
(define CyanMsg "Cyan: ")
(define MagentaMsg "Magenta: ")
(define YellowMsg "Yellow: ")
(define BlackMsg "Black: ")
(define FGMsg "Foreground Color")
(define BGMsg "Background Color")
(define HexMsg "RGB Hex: ")
(define AlphaHexMsg "RGBA Hex: ")
(define ClipboardMsg "Copy hex\nto Clipboard")

;; Sizes for UI widgets
(define AppWidth 990)
(define AppHeight 320)
(define WidgetStripHeight 10)
(define ColorControlsWidth 620)
(define RGBRadioPadding 14)
(define AlphaCheckboxPadding 18)
(define SlidersWidth 610)
(define SlidersHeight 175)
(define SliderLength 430)
(define SliderLabelWidth 60)
(define SliderTextareaWidth 50)
(define HexTextareaWidth 350)
(define ColorPreviewSize 35)

;; A few additional values
(define MinSliderVal 0)
(define MaxSliderVal 255)
(define huge-control-font (make-object font% 30 'system))
(define no-pen (new pen% [style 'transparent]))
(define DefaultFGColor "Cornflower Blue")
(define DefaultBGColor "LemonChiffon")

; vim: expandtab:sw=2
