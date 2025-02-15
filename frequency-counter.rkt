#lang racket

; Program created via prompts to Claude.ai

; Export the functions we want to test
(provide read-frequencies
         find-min-max
         counting-sort
         display-frequencies
         process-file)

;; Function to read integers from file and create frequency hash table
(define (read-frequencies filename)
  (let ([freq-table (make-hash)])  ; Create empty hash table
    (with-input-from-file filename
      (lambda ()
        (let loop ()
          (let ([num (read)])
            (when (number? num)  ; Check if we successfully read a number
              (hash-update! freq-table num add1 0)  ; Increment count (or initialize to 1)
              (loop))))))
    freq-table))

;; Function to find minimum and maximum values in hash keys
(define (find-min-max freq-table)
  (let ([keys (hash-keys freq-table)])
    (values (apply min keys) (apply max keys))))

;; Counting sort implementation using hash tables
(define (counting-sort freq-table)
  (let-values ([(min-val max-val) (find-min-max freq-table)])
    (let loop ([current min-val]
               [result '()])
      (if (> current max-val)
          (reverse result)  ; Return reversed list since we built it backwards
          (if (hash-has-key? freq-table current)
              (loop (add1 current) 
                    (cons (cons current (hash-ref freq-table current)) result))
              (loop (add1 current) result))))))

;; Function to display sorted frequencies
(define (display-frequencies sorted-freqs)
  (let ([expanded-list 
         (apply append
                (for/list ([pair sorted-freqs])
                  (make-list (cdr pair) (car pair))))])
    (printf "~a~n" expanded-list)))


;; Modified to return sorted-freqs before displaying
(define (process-file filename)
  (let* ([freq-table (read-frequencies filename)]
         [sorted-freqs (counting-sort freq-table)])
    (begin
      sorted-freqs  ; Return this value
      (display-frequencies sorted-freqs))))

(process-file "/Users/Catherine/Desktop/DataFiles/Data-6.txt")