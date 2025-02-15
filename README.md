# CS441-Project-1-LLM-Racket-Basics

**AI Prompts & Claude.ai generated code:**

**CatL:** Write for me a racket program that reads in a .txt file of integers on to a value frequency pair hash table. Then produce a sorted list of the values.

**Claude:** Generated Code:

    #lang racket
    
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
    
    ;; Function to sort values by frequency
    (define (sort-by-frequency freq-table)
      (sort 
       (hash->list freq-table)  ; Convert hash to list of (key . value) pairs
       >  ; Sort in descending order
       #:key cdr))  ; Compare based on frequency (value)
    
    ;; Function to display sorted frequencies
    (define (display-frequencies sorted-freqs)
      (for ([pair sorted-freqs])
        (printf "Value: ~a appears ~a time(s)~n" 
                (car pair) 
                (cdr pair))))
    
    ;; Main function to process file
    (define (process-file filename)
      (let* ([freq-table (read-frequencies filename)]
             [sorted-freqs (sort-by-frequency freq-table)])
        (display-frequencies sorted-freqs)
        sorted-freqs))  ; Return sorted frequencies for potential further processing

    (process-file "your-file.txt")

**CatL:** if given this error message, how do i better speficy the path to the existing file if it is on my desktop in a file named DataFiles? 

    open-input-file: cannot open input file
      path: /Users/X/Data-1.txt
      system error: No such file or directory; errno=2

**Claude:** If your file is on the desktop in a folder named "DataFiles", you'll need to specify the complete path correctly. Here's how to fix it:

    (process-file "/Users/X/Desktop/DataFiles/Data-1.txt")

**CatL:** For the sort-by-frequency function, sort by smallest to largest integer value instead of frequency. Do so without using the library sort function.

**Claude:** Key changes made:

- Implemented a custom merge sort algorithm instead of using the library sort function
- Changed the sorting criteria to compare by the integer value (car of the pair) rather than frequency
- The merge function handles combining two sorted lists while maintaining the sort by value order
- The merge-sort function implements the recursive divide-and-conquer strategy

Generated Code:

    #lang racket
    
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
    
    ;; Helper function for merge sort
    (define (merge lst1 lst2)
      (cond
        [(empty? lst1) lst2]
        [(empty? lst2) lst1]
        [else
         (let ([pair1 (car lst1)]
               [pair2 (car lst2)])
           (if (< (car pair1) (car pair2))  ; Compare by value (car) instead of frequency (cdr)
               (cons pair1 (merge (cdr lst1) lst2))
               (cons pair2 (merge lst1 (cdr lst2)))))]))
    
    ;; Custom merge sort implementation
    (define (merge-sort lst)
      (if (<= (length lst) 1)
          lst
          (let* ([middle (quotient (length lst) 2)]
                 [left (take lst middle)]
                 [right (drop lst middle)])
            (merge (merge-sort left) (merge-sort right)))))
    
    ;; Function to sort by value (replaces previous sort-by-frequency)
    (define (sort-by-value freq-table)
      (merge-sort (hash->list freq-table)))
    
    ;; Function to display sorted frequencies
    (define (display-frequencies sorted-freqs)
      (for ([pair sorted-freqs])
        (printf "Value: ~a appears ~a time(s)~n" 
                (car pair) 
                (cdr pair))))
    
    ;; Main function to process file
    (define (process-file filename)
      (let* ([freq-table (read-frequencies filename)]
             [sorted-freqs (sort-by-value freq-table)])
        (display-frequencies sorted-freqs)
        sorted-freqs))  ; Return sorted frequencies for potential further processing

**CatL:** Instead of implementing a merge sort, create a custom counting sort, still using a hash data structure.

**Claude:** Key changes in this version:

- Removed the merge sort implementation completely
- Added find-min-max helper function to determine the range of values
- Implemented counting-sort that:
-   Finds the minimum and maximum values in the hash table
-   Iterates through all values in that range
-   Builds the sorted list by checking each possible value in order
-   Only includes values that actually appear in the input

Generated Code:

    #lang racket
    
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
      (for ([pair sorted-freqs])
        (printf "Value: ~a appears ~a time(s)~n" 
                (car pair) 
                (cdr pair))))
    
    ;; Main function to process file
    (define (process-file filename)
      (let* ([freq-table (read-frequencies filename)]
             [sorted-freqs (counting-sort freq-table)])
        (display-frequencies sorted-freqs)
        sorted-freqs))  ; Return sorted frequencies for potential further processing

**CatL:** can you update the display-frequencies function to take the hash table and display the frequency? 

    ex: hash data ((-1 1) (1 1) (2 3) (3 2) (5 1) ) becomes (-1 1 2 2 2 3 3 5)


**Claude:** Updated function:

    ;; Updated function to display expanded frequencies
    (define (display-frequencies sorted-freqs)
      (let ([expanded-list 
             (apply append
                    (for/list ([pair sorted-freqs])
                      (make-list (cdr pair) (car pair))))])
        (printf "~a~n" expanded-list)))
