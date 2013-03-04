---
format: markdown+lhs
...

This page is written in literate Haskell.  You can see its source
[here](/_showraw/Literate Haskell Example).  This source can be loaded
directly into `ghci`.

Recursion
=========

A recursive implementation that calculates the nth Fibonacci number can be written remarkably close to the mathematical definition:

> fibr :: Integer -> Integer
> fibr n
>     | n == 0  = 0
>     | n == 1  = 1
>     | n  > 1  = fibr (n-1) + fibr (n-2)

Alternatively, the recursive `fibr` function can be written using pattern-matching instead of guards. This looks less like the mathematical definition, but is more concise. (And also, strictly speaking, wrong for inputs less than zero, for `fibp` doesn't terminate in this case.) This is a test to see 
what happens when I have a lot of embedded code...

fibp :: Integer -> Integer
fibp 0 = 0
fibp 1 = 1
fibp n = fibp (n-1) + fibp (n-2)

Infinite Lists
==============

The recursive definition is elegant but inefficient since for each call of fib with n > 1 we are recalculating Fibonacci numbers that had already been calculated before. Another issue is the stack, fib is not tail recursive and so we risk a stack overflow.

We can utilize Haskell's laziness and define our Fibonacci numbers as an infinite lazy list. This is less readable, but takes only linear time.

> fibl :: Integer -> Integer
> fibl n = fibs !! (fromIntegral n)
>   where
>     fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

where `zipWith` is a function defined in the Haskell prelude which builds a new list by taking the head element of each list and applying a function (here +) to them. For example 
lskdjf lksdjf lkjsdalkfj lksdjf lskadjflksjad ;lkf jsldkjf 
;lksdjaflkjsadlkfjlksadjflkjsdalkfjlsdkajf :

    *Main> zipWith (+) [0,1,2] [3, 4, 5] 
    [3,5,7]

As the list is being calculated, zipWith unfolds as follows:

    0 : 1 : zipWith (+) (0 : 1 : ...) (1 : ...)
    0 : 1 : (0 + 1) : zipWith (+) (1 : 1 : ...) (1 : ...)
    0 : 1 : 1 : (1 + 1) : zipWith (+) (1 : 2 : ...) (2 : ...)
    0 : 1 : 1 : 2 : (1 + 2) : zipWith (+) (2 : 3 : ...) (3 : ...)

You can compare the speed yourself if you calculate the 25th Fibonacci number at the Haskell interactive prompt using `fibl` and `fibr`. `fibr` will take some time while `fibl` will give you the result instantly.

Source: <http://en.literateprograms.org/Fibonacci_numbers_(Haskell)>, released under MIT/X11 license.

