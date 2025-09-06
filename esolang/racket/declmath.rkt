#lang racket

;; DeclMath - A Math-as-Scripting Language Implementation
;; Based on the MathAsScripting project concept

(require racket/match)
(require racket/string)

;; Language configuration
(define current-lang (make-parameter 'en))
(define awaited-vars (make-parameter '()))

;; Environment for storing variables
(define env (make-hash))

;; Built-in mathematical functions
(define math-functions
  (hash 'root sqrt
        'sqrt sqrt
        'abs abs
        'sin sin
        'cos cos
        'tan tan
        'log log
        'ln log
        'exp exp
        'floor floor
        'ceil ceiling
        'round round
        'frac (lambda (num den) (/ num den))
        'pow expt
        'max max
        'min min))

;; Language-specific function names
(define lang-functions
  (hash 'en (hash 'root "root" 'frac "frac" 'print "print" 'await "await" 'end "end")
        'pt_br (hash 'root "raiz" 'frac "frac" 'print "imprimir" 'await "aguardar" 'end "fim")
        'pt_pt (hash 'root "raiz" 'frac "frac" 'print "imprimir" 'await "aguardar" 'end "fim")
        'jp (hash 'root "ルート" 'frac "分数" 'print "印刷" 'await "待つ" 'end "終了")))

;; Tokenizer
(define (tokenize input)
  (define tokens '())
  (define current-token "")
  (define in-string #f)
  (define in-comment #f)
  
  (define (add-token!)
    (when (not (string=? current-token ""))
      (set! tokens (cons current-token tokens))
      (set! current-token "")))
  
  (for ([char (string->list input)])
    (cond
      [in-comment
       (when (char=? char #\newline)
         (set! in-comment #f))]
      [(char=? char #\#)
       (add-token!)
       (set! in-comment #t)]
      [(char=? char #\')
       (add-token!)
       (set! in-string (not in-string))]
      [in-string
       (set! current-token (string-append current-token (string char)))]
      [(char-whitespace? char)
       (add-token!)]
      [(or (char=? char #\() (char=? char #\)) (char=? char #\,))
       (add-token!)
       (set! tokens (cons (string char) tokens))]
      [else
       (set! current-token (string-append current-token (string char)))]))
  
  (add-token!)
  (reverse tokens))

;; Parser for expressions
(define (parse-expression tokens)
  (match tokens
    [(list) '()]
    [(list token) 
     (cond
       [(string->number token) (string->number token)]
       [(hash-has-key? env token) (hash-ref env token)]
       [(hash-has-key? math-functions (string->symbol token)) (string->symbol token)]
       [else (string->symbol token)])]
    [(list-rest func "(" args ")" rest)
     (cons (list (string->symbol func) (parse-args args)) 
           (parse-expression rest))]
    [(list-rest left "=" right)
     (list 'assign (string->symbol left) (parse-expression right))]
    [(list-rest left op right)
     (list (string->symbol op) 
           (parse-expression (list left))
           (parse-expression right))]))

;; Parse function arguments
(define (parse-args args-string)
  (if (string=? args-string "")
      '()
      (map parse-single-arg (string-split args-string ","))))

(define (parse-single-arg arg)
  (let ([trimmed (string-trim arg)])
    (cond
      [(string->number trimmed) (string->number trimmed)]
      [(hash-has-key? env trimmed) (hash-ref env trimmed)]
      [else (string->symbol trimmed)])))

;; Evaluator
(define (evaluate expr)
  (cond
    [(number? expr) expr]
    [(symbol? expr)
     (cond
       [(hash-has-key? env (symbol->string expr)) 
        (hash-ref env (symbol->string expr))]
       [else (error "Undefined variable:" expr)])]
    [(list? expr)
     (match expr
       [(list 'assign var val)
        (let ([evaluated-val (evaluate val)])
          (hash-set! env (symbol->string var) evaluated-val)
          evaluated-val)]
       [(list 'await vars)
        (set! awaited-vars vars)
        (displayln (format "Waiting for variables: ~a" vars))
        'awaited]
       [(list 'print val)
        (displayln (evaluate val))
        'printed]
       [(list func args)
        (cond
          [(hash-has-key? math-functions func)
           (let ([f (hash-ref math-functions func)])
             (cond
               [(eq? func 'frac)
                (apply f (map evaluate args))]
               [else
                (apply f (map evaluate args))]))]
          [else (error "Unknown function:" func)])]
       [(list op left right)
        (let ([left-val (evaluate left)]
              [right-val (evaluate right)])
          (case op
            [(+) (+ left-val right-val)]
            [(-) (- left-val right-val)]
            [(*) (* left-val right-val)]
            [(/) (/ left-val right-val)]
            [(^) (expt left-val right-val)]
            [(%) (modulo left-val right-val)]
            [else (error "Unknown operator:" op)]))])]
    [else expr]))

;; Language configuration commands
(define (process-lang-command tokens)
  (match tokens
    [(list "$lang" "*" lang-code)
     (current-lang (string->symbol (string-trim lang-code "'")))
     (displayln (format "Language set to: ~a" (current-lang)))]
    [(list "$lang" "*" lang-code "->" variant)
     (current-lang (string->symbol (string-trim lang-code "'")))
     (displayln (format "Language set to: ~a with variant: ~a" 
                       (current-lang) 
                       (string-trim variant "__")))]))

;; Main interpreter function
(define (declmath-eval input)
  (let ([tokens (tokenize input)])
    (cond
      [(and (not (null? tokens)) (string=? (car tokens) "$lang"))
       (process-lang-command tokens)]
      [else
       (let ([parsed (parse-expression tokens)])
         (evaluate parsed))])))

;; REPL (Read-Eval-Print Loop)
(define (declmath-repl)
  (displayln "DeclMath Interactive Interpreter")
  (displayln "Type 'exit' to quit")
  (displayln "Examples:")
  (displayln "  x = 12")
  (displayln "  root(x)")
  (displayln "  frac(x, 4)")
  (displayln "")
  
  (let loop ()
    (display "declmath> ")
    (let ([input (read-line)])
      (cond
        [(or (eof-object? input) (string=? input "exit"))
         (displayln "Goodbye!")]
        [(string=? input "")
         (loop)]
        [else
         (with-handlers ([exn:fail? (lambda (e) 
                                     (displayln (format "Error: ~a" (exn-message e))))])
           (let ([result (declmath-eval input)])
             (when (not (or (eq? result 'awaited) (eq? result 'printed)))
               (displayln result))))
         (loop)]))))

;; Example programs
(define (run-examples)
  (displayln "Running DeclMath Examples:")
  (displayln "")
  
  ;; Example 1: Basic variable assignment and square root
  (displayln "Example 1: x = 12; root(x)")
  (declmath-eval "x = 12")
  (displayln (declmath-eval "root(x)"))
  (displayln "")
  
  ;; Example 2: Quadratic formula components
  (displayln "Example 2: Quadratic formula parts")
  (declmath-eval "a = 1")
  (declmath-eval "b = -5")
  (declmath-eval "c = 6")
  (displayln "Discriminant:")
  (displayln (declmath-eval "root(b^2 - 4*a*c)"))
  (displayln "")
  
  ;; Example 3: Fraction
  (displayln "Example 3: frac(15, 3)")
  (displayln (declmath-eval "frac(15, 3)"))
  (displayln ""))

;; Helper function to clear environment
(define (clear-env!)
  (hash-clear! env))

;; Export main functions
(provide declmath-eval
         declmath-repl
         run-examples
         clear-env!
         current-lang
         awaited-vars)

;; Run examples and start REPL when this file is run directly
(module* main racket
  (run-examples)
  (displayln "Starting REPL...")
  (declmath-repl))