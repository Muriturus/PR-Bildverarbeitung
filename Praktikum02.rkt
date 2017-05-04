#lang racket

(require vigracket)
(require (rename-in 2htdp/image
                    (save-image save-plt-image)
                    (image-width  plt-image-width)
                    (image-height plt-image-height)))
; ------------------------
;    Hilfsfunktion:

(define (overlay-bboxes img bboxes colors)
  (if (empty? bboxes)
       (image->bitmap img)
       (let ((bbox  (car bboxes))
             (color (car colors)))
         (underlay/xy (overlay-bboxes img (cdr bboxes) (cdr colors))
                      (- (vector-ref bbox 0) 1)
                      (- (vector-ref bbox 1) 1)
                      (rectangle (+ (- (vector-ref bbox 2) (vector-ref bbox 0)) 2)
                                 (+ (- (vector-ref bbox 3) (vector-ref bbox 1)) 2)
                                 'outline color)))))

; ------------------------

(define feldLeer1
  (load-image "/Users/5itran/Desktop/JuniorLabyrinth/3-JuniorLabyrinth/img/1FeldLeer.jpg"))
;(show-image feldLeer1)

(define feldLeer2
  (load-image "/Users/5itran/Desktop/JuniorLabyrinth/3-JuniorLabyrinth/img/2FeldLeer.jpg"))
;(show-image feldLeer2)

(define feldLeer3
  (load-image "/Users/5itran/Desktop/JuniorLabyrinth/3-JuniorLabyrinth/img/3FeldLeer.jpg"))
;(show-image feldLeer3)        

(define feldMaske (cannyedgeimage (image->red feldLeer1) 1.0  10.0 255.0))

;(show-image (cannyedgeimage (image->red feldLeer1) 1.0  10.0 255.0) "feldLeer1")

(define feldStart1
  (load-image "/Users/5itran/Desktop/JuniorLabyrinth/3-JuniorLabyrinth/img/5FeldStart.jpg"))

(define startMaske (cannyedgeimage (image->red feldStart1) 2.0  15.0 255.0))


;(show-image (cannyedgeimage (image->red feldStart1) 2.0  15.0 255.0) "feldStart1")

(define Steine
  (load-image "/Users/5itran/Desktop/JuniorLabyrinth/3-JuniorLabyrinth/img/9Spielstand.jpg"))

;(show-image (cannyedgeimage (image->red Steine) 2.0  15.0 255.0) "9Spielstand")
(define canny_feldStart  (cannyedgeimage (image->red feldStart1) 2.0  15.0 255.0))
(define canny_labels (labelimage canny_feldStart))
(define canny_features (extractfeatures canny_feldStart canny_labels))
(image->list canny_features)


(define (largestRegionID features [idx 0] [max_idx 0])
  (if (= idx (image-height features))
      max_idx
      (largestRegionID features
                       (+ idx 1)
                       (if (> (image-ref features 0 idx 0)
                              (image-ref features 0 max_idx 0))
                           idx
                           max_idx))))

;;Uses the above function to find the bounding box of the largest region
(define (largestRegionBBox image)
  (let* ((labels (labelimage image))
         (features (extractfeatures image labels))
         (max_region_id (largestRegionID features 2 2)))
(vector (inexact->exact (image-ref features 1 max_region_id 0)) ;left
        (inexact->exact (image-ref features 2 max_region_id 0)) ;upper
        (inexact->exact (image-ref features 3 max_region_id 0)) ;right
        (inexact->exact (image-ref features 4 max_region_id 0)) ;lower
)))

(define bbox1 (largestRegionBBox startMaske))

;(show-image (racket-image->image (overlay-bboxes feldStart1 (list bbox1) '(green))))

(define crop_img (subimage feldStart1 (vector-ref bbox1 0)
                                       (vector-ref bbox1 1)
                                       (vector-ref bbox1 2)
                                       (vector-ref bbox1 3)))
(show-image crop_img "geschnitten")
;Spielfeld aufteilen in die einzelnen Karten

(define Feld1 (subimage crop_img 20 18 100 98))
(define Feld2 (subimage crop_img 100 99 180 179))
(define Feld25 (subimage crop_img (+ 100 242) (+ 100 244) (+ 242 180) (+ 244 180)))

;-----Helfer Variablen-----
;vordere x-Koordinate in Relation
(define vornFeld (* 0.0456621 (image-width crop_img)))

;hintere x-Koordinate in Relation
(define hintenFeld (* 0.2283105 (image-width crop_img)))

;obere y-Koordinate in Relation
(define obenFeld (* 0.040724 (image-height crop_img)))

;untere y-Koordinate in Relation
(define untenFeld (* 0.22171946 (image-height crop_img)))

;breite einer Karte in Relation
(define breiteFeld (* 0.18493151 (image-width crop_img)))

;höhe einer Karte in Relation
(define hoeheFeld (* 0.18552036 (image-height crop_img)))

;----- Helfer für ein Feld-----
(define (FeldN indexReihe indexSpalte)
  (subimage crop_img (inexact->exact (round (+ vornFeld (* indexReihe breiteFeld))))
            (inexact->exact (round (+ obenFeld (* indexSpalte hoeheFeld))))
            (inexact->exact (round (+ hintenFeld (* indexReihe breiteFeld))))
            (inexact->exact (round (+ untenFeld (* indexSpalte hoeheFeld))))))

(show-image (FeldN 0 0) "Helfer")
(show-image (FeldN 4 3) "Feld 4 3")
(show-image (FeldN 4 4) "letztes Feld")

;--------Wegerkennung------
