# 21sep20 Software Lab. Alexander Burger

# *NoLint

(private) (global? local? dlsym? lint1 lint2 lintVar lintDup lintLoop
_lintq lintFun A C Lst S X Y *L *X *Var *Dup *Def *Bnd *Use)

(de noLint (X V)
   (if V
      (push1 '*NoLint (cons X V))
      (or (memq X *NoLint) (push '*NoLint X)) ) )

(de global? (S)
   (or
      (memq S '(NIL ^ @ @@ @@@ This T))
      (member (char S) '(`(char '*) `(char '+)))
      (== '\~ (car (pair (val S))))
      (and
         (>= (length S) 4)
         (fully upp? (chop S)) ) ) )

(de local? (S)
   (or
      (str? S)
      (member (char S) '(`(char '*) `(char '_))) ) )

(de dlsym? (S)
   (and
      (car (setq S (split (chop S) ':)))
      (cadr S)
      (low? (caar S)) ) )

(de lint1 (X)
   (cond
      ((atom X)
         (when (sym? X)
            (cond
               ((memq X *L) (setq *Use (delq X *Use)))
               ((local? X) (lint2 (val X)))
               (T
                  (or
                     (getd X)
                     (global? X)
                     (member (cons *X X) *NoLint)
                     (memq X *Bnd)
                     (push '*Bnd X) ) ) ) ) )
      ((num? (car X)))
      (T
         (casq (car X)
            ((: ::))
            (; (lint1 (cadr X)))
            (quote
               (let F (fun? (cdr X))
                  (if (or (and (pair F) (not (fin @))) (== '@ F))
                     (use *L (lintFun (cdr X)))
                     (lint2 (cdr X)) ) ) )
            ((de dm)
               (let *X (cadr X)
                  (lintFun (cddr X)) ) )
            (recur
               (let recurse (cdr X)
                  (lintFun recurse) ) )
            (task
               (lint1 (cadr X))
               (let Y (cddr X)
                  (use *L
                     (while (num? (car Y))
                        (++ Y) )
                     (while (and (car Y) (sym? @))
                        (lintVar (++ Y))
                        (lint1 (++ Y)) )
                     (mapc lint1 Y) ) ) )
            (macro
               (lint2 (cdr X)) )
            ((let? buf)
               (use *L
                  (lintVar (cadr X))
                  (mapc lint1 (cddr X)) ) )
            (let
               (use *L
                  (if (atom (cadr X))
                     (lintVar (cadr X))
                     (for (L (cadr X) L (cddr L))
                        (if (pair (car L))
                           (mapc lintVar
                              (fish
                                 '((X) (and X (atom X)))
                                 (car L) ) )
                           (lintVar (car L)) )
                        (lint1 (cadr L)) ) )
                  (mapc lint1 (cddr X)) ) )
            (use
               (use *L
                  (if (atom (cadr X))
                     (lintVar (cadr X))
                     (mapc lintVar (cadr X)) )
                  (mapc lint1 (cddr X)) ) )
            (for
               (use *L
                  (let Y (cadr X)
                     (cond
                        ((atom Y)            # (for X (1 2 ..) ..)
                           (lint1 (caddr X))
                           (lintVar Y)
                           (lintLoop (cdddr X)) )
                        ((atom (cdr Y))      # (for (I . X) (1 2 ..) ..)
                           (lintVar (car Y))
                           (lint1 (caddr X))
                           (lintVar (cdr Y))
                           (lintLoop (cdddr X)) )
                        ((atom (car Y))      # (for (X (1 2 ..) ..) ..)
                           (lint1 (cadr Y))
                           (lintVar (car Y))
                           (mapc lint1 (cddr Y))
                           (lintLoop (cddr X)) )
                        (T                     # (for ((I . L) (1 2 ..) ..) ..)
                           (lintVar (caar Y))
                           (lint1 (cadr Y))
                           (lintVar (cdar Y))
                           (mapc lint1 (cddr Y))
                           (lintLoop (cddr X)) ) ) ) ) )
            ((case casq state)
               (lint1 (cadr X))
               (for X (cddr X)
                  (mapc lint1 (cdr X)) ) )
            ((cond nond)
               (for X (cdr X)
                  (mapc lint1 X) ) )
            (loop
               (lintLoop (cdr X)) )
            (do
               (lint1 (cadr X))
               (lintLoop (cddr X)) )
            (=:
               (lint1 (last (cddr X))) )
            ((dec inc pop push push1 queue fifo val idx accu)
               (_lintq '(T)) )
            ((cut port)
               (_lintq '(NIL T)) )
            (set
               (_lintq '(T NIL .)) )
            (xchg
               (_lintq '(T T .)) )
            (T
               (cond
                  ((pair (car X))
                     (lint1 @)
                     (mapc lint2 (cdr X)) )
                  ((memq (car X) *L)
                     (setq *Use (delq (car X) *Use))
                     (mapc lint2 (cdr X)) )
                  ((fun? (val (car X)))
                     (if (num? @)
                        (mapc lint1 (cdr X))
                        (when (local? (car X))
                           (lint2 (val (car X))) )
                        (let Y (car (getd (++ X)))
                           (while (and (pair X) (pair Y))
                              (lint1 (++ X))
                              (++ Y) )
                           (if (or (== '@ Y) (= "Prg" Y) (= "*Prg" Y))
                              (mapc lint1 X)
                              (lint2 X) ) ) ) )
                  (T
                     (or
                        (str? (car X))
                        (dlsym? (car X))
                        (== '@ (car X))
                        (memq (car X) *NoLint)
                        (memq (car X) *Def)
                        (push '*Def (car X)) )
                     (mapc lint1 (cdr X)) ) ) ) ) ) ) )

(de lint2 (X Mark)
   (cond
      ((memq X Mark))
      ((atom X)
         (and (memq X *L) (setq *Use (delq X *Use))) )
      (T (lint2 (car X))
         (lint2 (cdr X) (cons X Mark)) ) ) )

(de lintVar (X Flg)
   (cond
      ((or (not (sym? X)) (memq X '(NIL *DB *Solo ^ meth quote T)))
         (push '*Var X) )
      ((not (global? X))
         (or
            Flg
            (member (cons *X X) *NoLint)
            (memq X *Use)
            (push '*Use X) )
         (push '*L X) ) ) )

(de lintDup (X Lst)
   (and
      (memq X Lst)
      (not (member (cons *X X) *NoLint))
      (push '*Dup X) ) )

(de lintLoop (Lst)
   (for Y Lst
      (if (and (pair Y) (or (=T (car Y)) (not (car Y))))
         (mapc lint1 (cdr Y))
         (lint1 Y) ) ) )

(de _lintq (Lst)
   (mapc
      '((X Flg)
         (lint1 (if Flg (strip X) X)) )
      (cdr X)
      Lst ) )

(de lintFun (Lst)
   (let A (and (pair Lst) (car Lst))
      (while (pair A)
         (lintDup (car A) (cdr A))
         (lintVar (++ A) T) )
      (when A
         (lintVar A) )
      (mapc lint1 (cdr Lst)) ) )

(de lint (X C)
   (let (*L NIL  *Var NIL  *Dup NIL  *Def NIL  *Bnd NIL  *Use NIL)
      (when (pair X)
         (setq  C (cdr X)  X (car X)) )
      (cond
         (C  # Method
            (let *X (cons X C)
               (lintFun (method X C)) ) )
         ((pair (val X))  # Function
            (let *X X
               (lintFun (val X)) ) )
         ((info X)  # File name
            (let *X X
               (in X (while (read) (lint1 @))) ) )
         (T (quit "Can't lint" X)) )
      (when (or *Var *Dup *Def *Bnd *Use)
         (make
            # Bad variables
            (and *Var (link (cons 'var *Var)))
            # Duplicate parameters
            (and *Dup (link (cons 'dup *Dup)))
            # Undefined functions
            (and *Def (link (cons 'def *Def)))
            # Unbound variables
            (and *Bnd (<> `(char '_) (char X)) (link (cons 'bnd *Bnd)))
            # Unused variables
            (and *Use (link (cons 'use *Use))) ) ) ) )

(de lintAll @
   (let *Dbg NIL
      (make
         (for X (all)
            (cond
               ((and (= `(char "+") (char X)) (pair (val X)))
                  (for Y @
                     (and
                        (pair Y)
                        (fun? (cdr Y))
                        (lint (car Y) X)
                        (link (cons (cons (car Y) X) @)) ) ) )
               ((and (not (global? X)) (pair (getd X)) (lint X))
                  (link (cons X @)) ) ) )
         (while (args)
            (let A (next)
               (and (lint A) (link (cons A @))) ) ) ) ) )
