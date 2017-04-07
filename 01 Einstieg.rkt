#lang racket
; ----------------------
; PR Bildverarbeitung
; 06.04.2017
;
; Willy, Steffi und Isi
; ----------------------

; -------------
;   Aufgabe 1
; -------------

; Damit man ein Bild laden kann, muss man zunächst die VIGRA-Anbindung einbinden.
(require vigracket)

; Anschließend kann man ein Bild unter Angabe des Dateinamens laden und mit "show-image" sich anzeigen lassen. Der String dahinter
; ist optional und ist der Titel des Bildes.
(define img (load-image (build-path vigracket-path "images/blox.gif")))
(show-image img "00 Das gerade geladene Bild")

; "image->bitmap" wandelt das Bild in ein Racket-Image um. Es wird dann im Interpreter angezeigt.
; Durch die Symbol-Zuweisung können wir weiter auf dem Racket-Bild arbeiten und bsp. Objekte darauf zeichnen
; die Anzeige des Bildes erfolgt ohne Klammern, da es sich bei "racket-img" um ein Symbol handelt
;(define racket-img (image->bitmap img))

; Das Speichern erfordert den absoluten Pfad. Es unterstützt JPG, GIF, TIF, PNG und das BMP-Format.
; (save-image img "../PR_Bildverarbeitung/Aufgaben/01 SaveImage.jpg")


; -------------
;   Aufgabe 2
; -------------

; Tiefpass-Filter ("Weichzeichner")
; der Scale-Faktor der Funktion "gsmooth" bestimmt wie weit die Nachbar-Pixel vom ausgewählten Pixel entfernt sein
; dürfen und bestimmt den Mittelwert aller Pixel wodurch das Bild "weichgezeichnet" wird.
(show-image (gsmooth img 2.0) "01 Das weichgezeichnete Bild")

; Laplace-Filter ("Kantenfinder")
; der Scale-Faktor der Funktion "ggradient" ist die Standardabweichung beim Differenzieren/Ableiten des Bildes (s. Gaußsche Glocke Normalverteilung).
(show-image (ggradient img 0.5) "02 Das hartgezeichnete Bild")

; -------------
;   Aufgabe 3
; -------------

; image-map kann Bilder miteinander verrechnen. Zieht man ein geglättetes Bild von dem Originalbild ab, so erhält man
; eine Maskierung des Bildes.
(show-image (image-map - img (gsmooth img 2.0))"03 Original minus geglättetes Bild")
; (show-image (image-map + img (gsmooth img 2.0))"03.5 Original plus geglättetes Bild")
(show-image (image-map - img (ggradient img 5.0))"04 Original minus hartes Bild")
; (show-image (image-map + img (ggradient img 0.5))"04.5 Original plus hartes Bild")

; falls die Inensität kleiner als 175 (grau) ist, setze ihn auf 0 (schwarz), ansonsten setze ihn auf 254 (weiß)
(define (schwellenwert x)
(if (< x 175.0) 0.0
  254.0)
  )
; das Bild wird maskiert
(show-image (image-map schwellenwert img) "05 Das maskierte Bild")

; "labelimage" weißt jeder Zusammenhangskomponente einer Ziffer zu. mit anschließender Verwendung von "image-reduce"
; lässt sich die Anzahl der Objekte bestimmen
(image-reduce max (labelimage (image-map schwellenwert img)) 0)

; ---------------
;  Zusatzaufgabe
; ---------------
; Verändern der Bildgröße
; der Interpolationsgrad bestimmt die Berrechnung bekannter Pixelwerte untereinander.
; Beim Interpolieren entsteht immer ein Schärfeverlust.
(show-image (resizeimage img 700 700 0) "06 Das vergrößerte Bild")

; Rotation eines Bildes
(show-image (rotateimage img 45.0 2) "07 Das rotierte Bild")