#lang racket/gui

;(require "cp-classes.rkt")
(require "text-preview.rkt")
(require "my-color.rkt")
(require "cp-convert.rkt")

(define mainwindow (new frame%
                        [label "CP Tester"]
                        [width 500]
				    [height 500]))
#|
(define test (new sliders-panel%
			   [label "Testing"]
			   [parent mainwindow])) |#

(define dumbpane%
  (class pane%
    (super-new)
    (define/public (myself) this)))

(define button-pane%
  (class dumbpane%
    (super-new)
    (define button
	 (new button%
		 [label "Do nothing"]
		 [parent this]))))

(define testcanvas
  (new canvas%
	  [parent mainwindow]))

(define testtext
  (new text-preview%
       [parent mainwindow]))
  
(send mainwindow show #t)

; vim: expandtab:sw=2
