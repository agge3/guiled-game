(use-modules ((sdl2)          #:prefix SDL:)
             ((sdl2 render)   #:prefix SDL:)
             ((sdl2 surface)  #:prefix SDL:)
             ((sdl2 video)    #:prefix SDL:)
             ((sdl2 events)   #:prefix SDL:)
             ((sdl2 image)    #:prefix SDL:)
             ((sdl2 rect)     #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:)) 
(use-modules  (rnrs bytevectors)
              (srfi srfi-9)
              (system foreign))

;(define (player-mover))

; seed random state from OS
(set! *random-state* (random-state-from-platform))

(define (handle-event event player-rect)
  ;(display "Handling events...\n")
  (cond
    ;((SDL:quit-event? event)
     ;(display "Game exited.\n"))

    ; keyboard-down is key pressed        
    ((SDL:keyboard-down-event? event)
     (display "Key: ")  (display (SDL:keyboard-event-key event)) 
                        (newline)
     (display "Scan: ") (display (SDL:keyboard-event-scancode event))
                        (newline)
     (display "Mod: ")  (display (SDL:keyboard-event-modifiers event))
                        (newline)

     ; handle key pressed
     (let ((key (SDL:keyboard-event-scancode event))
           (mod (SDL:keyboard-event-modifiers event)))
       (cond
         ((eq? key 'up)
          (display "Move UP\n")
          (SDL:set-rect-y! player-rect (- (SDL:rect-y player-rect) 7)))
         ((eq? key 'down)
          (display "Move DOWN\n")
          (SDL:set-rect-y! player-rect (+ (SDL:rect-y player-rect) 7)))
         ((eq? key 'left)
          (display "Move LEFT\n")
          (SDL:set-rect-x! player-rect (- (SDL:rect-x player-rect) 7)))
         ((eq? key 'right)
          (display "Move RIGHT\n")        
          (SDL:set-rect-x! player-rect (+ (SDL:rect-x player-rect) 7)))
       )))

    ; keyboard-up is key released
    ((SDL:keyboard-up-event? event)
     ; do stuff
    )
))

; default (no texture) render procedure
(define (render ren)
  (SDL:set-renderer-draw-color! ren 0 0 0 255)
  (SDL:clear-renderer ren)
  (SDL:present-renderer ren)
)

; draw (with texture(s)) render procedure
(define (draw ren texture rect list)
  (SDL:clear-renderer ren)
  (SDL:render-copy ren texture #:dstrect rect)
  (SDL:set-renderer-draw-color! ren 255 0 0 255)
  (SDL:render-fill-rects ren list)
  (SDL:present-renderer ren)
)

(define (spawn-berry x y)
  (let ((height 26) (width 26))
    (SDL:make-rect x y height width)))

;(define (kill-berry berry-rect))

(define (random-berry-spawn list ren width height)
  ; 1/19 chance to spawn berry
  (if (eq? 1 (random 20))
    ; spawn berry and add to berries list
    (append! list (SDL:make-rect (random width) (random height) 26 26))
    (display "I spawned a berry!\n")))

;(define (update)
;  ; to be implemented
;)

(define (main)
  ; init initial settings
  (let ((width 640) (height 480)
        ; more here...
        )
    (SDL:sdl-init '(video events))
    (display "SDL initialized.\n")
    ; print SDL version
    (display "SDL version: ") (display (SDL:sdl-version)) (newline)

    (SDL:call-with-window (SDL:make-window #:title "Guiled Game"
                                           #:position
                                             (list ffi:SDL_WINDOWPOS_CENTERED
                                                   ffi:SDL_WINDOWPOS_CENTERED)
                                           #:size (list width height) 
                                           #:show? #t)
      (lambda (window)
        ; with hardware acceleration, with vsync
        (SDL:call-with-renderer (SDL:make-renderer window '(accelerated vsync))
          (lambda (ren) (
            ; scoped initialization context for game to run in
            (let* ((player-surface  (SDL:load-image "player.png"))
                   (player-texture  (SDL:surface->texture ren player-surface))
                   ; (make-rect x y w h): (x, y) is player spawn position
                   (player-rect     (SDL:make-rect 320 10 52 52))
                   )
            (display "Run game.\n")
            (render ren)

            (let ((berries (make-list 0)))
            (let loop ((event (SDL:poll-event)))
              (if event
                (cond
                  ((SDL:quit-event? event)
                   (display "Exit game.\n")
                   ; NOTE: break out of recursion, no SDL cleanup
                   (exit)
                   )
                  (else
                    (display "Handling events.\n")
                    (handle-event event player-rect)
                    (display "Should I spawn a berry?\n")
                    (random-berry-spawn berries ren height width)
                    (draw ren player-texture player-rect berries)
                    ;(display "Done handling events.\n")
                    (loop (SDL:poll-event))
                    )))
              ;(display "No events to handle.\n")
              (display "Should I spawn a berry?\n")
              (random-berry-spawn berries ren height width)
              (draw ren player-texture player-rect berries)
              (loop (SDL:poll-event))))
))))))))

(main)

;(define (random-berry-spawn list ren width height)
;  ; 1/19 chance to spawn berry
;  (if (eq? 1 (random 20))
;    ; spawn berry and add to berries list
;    (let* ((berry-width (random width)) (berry-height (random height))
;           ; 8-bit color depth
;           (surface (SDL:make-rgb-surface berry-width berry-height 8))
;           ; berries are 26x26px
;           (rect (SDL:make-rect berry-width berry-height 26 26)) 
;      ;(color (random 5))
;      ;(bytevector-s32-set! bv 0 
;      ;(cond
;      ;  ((eq? color 0)
;      ;   ; SEE: ffi:SDL_MapRGBA to make SDL color
;      ;   (display ("I'm making a blue berry...\n"))
;      ;   (SDL:fill-rect surface rect #x0000FF)
;      ;   )
;      ;  (else
;      ;    (SDL:fill-rect surface rect #xFFFFFF)))
;
;      (append! list (SDL:make-rect (random width) (random height) 26 26))
;      (display "I spawned a berry!\n")
;)))

;(define (init width height)
;  (display "Initializing...\n")
;  (SDL:sdl-init '(video events))
;  ; print SDL version
;  (display "SDL version: ") (display (SDL:sdl-version)) (newline)
;  (let ((win (SDL:make-window #:title "Guiled Game"
;                              #:position (list ffi:SDL_WINDOWPOS_CENTERED
;                                               ffi:SDL_WINDOWPOS_CENTERED)
;                              #:size (list width height) 
;                              #:show? #t)))
;    (let ((ren (SDL:make-renderer win '(accelerated vsync))))
;      (SDL:set-renderer-draw-color! ren 255 255 255 255)
;      ren
;      )))
              
            ;(let ((event (SDL:poll-event)))
            ;    (if event 
            ;      (if ((SDL:quit-event? event))
            ;        (display "Exit game.\n")
            ;        (close-window! window))
            ;      (else 
            ;        (handle-events event)))
            ;    (render ren)
            ;)))))))))
;          (lambda (ren)
;            (let ((event (SDL:poll-event)))
;              (if event
;                (if (SDL:quit-event? event) (close-window! window))
;                (handle-events event))
;              (render ren)
;              ))))
;    (SDL:sdl-quit)
;))

;(define (init width height)
;  (display "Initializing...\n")
;  (SDL:sdl-init '(video events))
;  (let ((win (SDL:make-window #:title "Guiled Game"
;                              #:position (list ffi:SDL_WINDOWPOS_CENTERED
;                                               ffi:SDL_WINDOWPOS_CENTERED)
;                              #:size (list width height) 
;                              #:show? #t)))
;    (let ((ren (SDL:make-renderer win '(accelerated vsync))))
;      (SDL:set-renderer-draw-color! ren 255 255 255 255)
;      ren
;      )))

;(define (main)
;  (let (
;        ;(src-rect (SDL:make-rect 0 0 0 0))
;        ;(dst-rect (SFL:make-rect 0 0 0 0))
;        (width 640) (height 480))
;    (catch #t
;           (lambda ()
;             (let* ((ren (init width height)))
;               (let loop ((event SDL:poll-event)))
;                 (if event
;                   (cond
;                     ((SDL:quit-event? event)
;
;                   (handle-events event)
;                   (render ren)
;                      ))
;             (display "Exiting game loop...\n")
;             )
;           (lambda (key . args)
;             (format #t "Have exception '~a' with detail info: ~{ ~A ~}~%" key args))
;           )
;    (display "Exiting error catching...\n")
;    )
;  (SDL:sdl-quit)
;)
;
;(main)
  
;(define (hello-sdl)
;  (catch 'sdl-error
;         (lambda ()
;           (SDL:sdl-init '(video))
;           (let ((win (SDL:make-window #:title "Guiled Game"
;                                          #:position 
;                                          (list ffi:SDL_WINDOWPOS_CENTERED
;                                                ffi:SDL_WINDOWPOS_CENTERED)
;                                          #:size '(640 480)
;                                          #:show? #t)))
;             ; (make-renderer win #:flags='(see doc 3.7 rendering))
;             (let ((ren (SDL:make-renderer win)))
;               (SDL:set-renderer-draw-color! ren 255 0 0 255)
;               (SDL:clear-renderer ren)
;               (SDL:present-renderer ren)
;               (sleep 5)
;               )))
;  (SDL:sdl-quit)
;  (display "End of SDL!\n")
;  (sleep 5)
;)
;
;(hello-sdl)

;(define (draw render)
;  (let* ((surface (make-rgb-surface(640 480 8)) ; res: (640,480), bit-depth: 8
;                  (color r 255)
;                  (color g 0)
;                  (color b 0)
;                  (color a 255))
;         (texture (surface->texture render surface)))
;    (clear-renderer render)
;    (render-copy render texture)
;    (present-renderer render)
;    (sleep 2)))


;(call-with-window (make-window)
;                  (lambda (window)
;                    (call-with-renderer (make-renderer window) draw))
;
;(sdl-quit)

; decrease window size - unimplemented
           ;((or (eq? key 'keypad-minus)
           ;     (eq? key 'minus))
           ; (when (and (> (SDL:rect-w d-rect) 5) (> (SDL:rect-h d-rect) 5))
           ;   (display "Window size decreased.\n")
           ;   (SDL:rect-w-set! d-rect (- (SDL:rect-w d-rect) 5))
           ;   (SDL:rect-h-set! d-rect (- (SDL:rect-h d-rect) 5))))
           ;((or (eq? key 'keypad-plus)
           ;     (and (eq? key 'equals) (member 'left-shift map)))
           ; (begin
           ;   (display "Window size increased.\n")
           ;   (SDL:rect-w-set! d-rect (+ (SDL:rect-w d-rect) 5))
           ;   (SDL:rect-h-set! d-rect (+ (SDL:rect-h d-rect 5)))))
