#lang racket
; ----------------------
; PR Bildverarbeitung
; 13.04.2017
;
; Willy, Steffi und Isi
; ----------------------
(require vigracket)
; -------------
;   Aufgabe 1
; -------------
; Wiederholung - lade ein Bild
(define blox (load-image (build-path vigracket-path "images/blox.gif")))
(define lenna (load-image (build-path vigracket-path "images/lenna_face.png")))

(show-image lenna "00 - Normal")

; -------------
;   Aufgabe 2
; -------------
; Bildkanäle werden in Graustufen angezeigt
(define red (image->red lenna))
;(show-image red "01 - Der rote Kanal")

(define green (image->green lenna))
;(show-image green "02 - Der grüne Kanal")

(define blue (image->blue lenna))
;(show-image blue "03 - Der blaue Kanal")

; Das bunte Bild besteht aus drei Kanälen (Listen), daher können wir die mit "append" zusammenfügen
;(show-image (append red green blue) "04 - Aus den Kanälen")
;(show-image (append green  red blue) "05 rot grün vertauscht")

; smoothed die zunächst in Graustufen und transportiert die wieder zurück in rgb
;(show-image (gsmooth lenna 1.0) "06 Smooth it!")

; ggradient sucht Farbübergänge in den einzelnen Kanälen
;(show-image (ggradient lenna 1.0) "07 Kanten")

; -------------
;   Aufgabe 3
; -------------
; von letzter Woche
(define (schwellenwert x)
 (if ( < x 220.0) 0.0
     254.0))

; a) Rotkanal
; das Bild wird maskiert
; (show-image (image-map schwellenwert red) "08 Das maskierte Bild")

; b) Schreibe eine Funktion, die als Parameter ein Farbbild, eine Maskierung und eine Skalierung
;    nimmt und das Bild nur an den maskierten Stellen glättet.
(define (smooth-on-masked-areas img mask scale)
  (let* ([gesmoothed (gsmooth img scale)]
        [mask-image (image-map schwellenwert (mask img))])
  (image-map (lambda (x gesmoothed img)
               ; wenn der Pixel nicht schwarz (0) ist
               (if (> x 0)
                   gesmoothed
                          img))
             mask-image gesmoothed img)))

(show-image (smooth-on-masked-areas lenna image->red 15) "09 Das maskiert gesmoothed-te Bild")

; ---------------
;  Zusatzaufgabe
; ---------------