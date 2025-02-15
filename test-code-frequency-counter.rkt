#lang racket

; Program created via prompts to Claude.ai

(require rackunit)
(require rackunit/text-ui)
(require "frequency-counter.rkt")

;; Test data
(define test-hash (make-hash))
(hash-set! test-hash -1 1)
(hash-set! test-hash 1 1)
(hash-set! test-hash 2 3)
(hash-set! test-hash 3 2)
(hash-set! test-hash 5 1)

;; Define a test suite
(define frequency-tests
  (test-suite
   "Frequency Counter Tests"
   
   ;; Test find-min-max function
   (test-case "find-min-max tests"
     (let-values ([(min max) (find-min-max test-hash)])
       (check-equal? min -1 "Minimum value should be -1")
       (check-equal? max 5 "Maximum value should be 5")))

   ;; Test counting-sort function
   (test-case "counting-sort tests"
     (define sorted-pairs (counting-sort test-hash))
     (check-equal? sorted-pairs '((-1 . 1) (1 . 1) (2 . 3) (3 . 2) (5 . 1))
                   "Should produce correct sorted pairs")
     (check-equal? (map car sorted-pairs)
                   '(-1 1 2 3 5)
                   "Values should be in ascending order"))

   ;; Test empty input
   (test-case "empty input tests"
     (define empty-hash (make-hash))
     (check-exn exn:fail?
                (λ () (find-min-max empty-hash))
                "Should handle empty hash appropriately"))

   ;; Test read-frequencies with sample file
   (test-case "read-frequencies tests"
     ;; Create a temporary file with known content
     (define temp-file "test-data.txt")
     (with-output-to-file temp-file
       #:exists 'replace
       (λ () (printf "2\n2\n2\n3\n3\n-1\n1\n5\n")))
     
     ;; Test reading from file
     (define result-hash (read-frequencies temp-file))
     (check-equal? (hash-ref result-hash 2) 3 "Should count 2 three times")
     (check-equal? (hash-ref result-hash 3) 2 "Should count 3 twice")
     (check-equal? (hash-ref result-hash -1) 1 "Should count -1 once")
     
     ;; Clean up
     (delete-file temp-file))

   ;; Test complete workflow
   (test-case "complete workflow test"
     ;; Create test file
     (define test-file "workflow-test.txt")
     (with-output-to-file test-file
       #:exists 'replace
       (λ () (printf "2\n2\n2\n3\n3\n-1\n1\n5\n")))
     
     ;; Get the result and store it
     (define result (let* ([freq-table (read-frequencies test-file)]
                          [sorted-freqs (counting-sort freq-table)])
                     sorted-freqs))
     
     ;; Verify results
     (check-equal? result
                   '((-1 . 1) (1 . 1) (2 . 3) (3 . 2) (5 . 1))
                   "Complete workflow should produce correct output")
     
     ;; Clean up
     (delete-file test-file))))

;; Run all tests
(run-tests frequency-tests)