# Afterwords

R is not really a language for algorithmic programming. It is designed to be flexible and make statistical analysis and visualisation easy, but it is not designed to be fast. With modern compiler and runtime system technology, it could probably become much faster than it is today, but basic speed has just not been a priority. Programming time---the time it takes you to implement an analysis---is prioritised higher than running time---the time it takes the computer to complete the analysis. This is the sensible choice in many applications. There is no point in spending an extra week programming in order to save a day of running time. Since programmers' time is more important than computers', it usually isn't worth it to program a week to save a *month* of running time.

How much extra time you should spend on making your code run faster is a tradeoff against how long and how often you expect your code to run. If you are writing an analysis package you expect lots of people to use frequently, you should consider optimising your code; if you are writing a one-off analysis pipeline, you probably shouldn't bother. Or, at least, you shouldn't spend too much time on optimising your code.

When it comes to efficient code, the greatest speedups are achieved by carefully selecting the algorithms and data structures you use. Changing a quadratic time algorithm into a linear time algorithm will greatly speed up your analyses for even moderately sized data sets; checking set membership in logarithmic time instead of linear time will do the same. If you find that your code is too slow for your purposes, it is the algorithms and data structures you should consider doing something about first. Micro-optimising the actual code---painting it "go faster red" and putting speed stripes on it---might gain you a factor of two to ten in speed up, but changing an algorithm or data structure can gain you asymptotic improvements. When programming in R, micro-optimising is rarely worth the effort, but switching from one data structure to another just might be. Especially if you interact with data structures through a polymorphic interface---changing one data structure for another requires trivial changes to the code but can give you great performance improvements.

R doesn't have a large library of data structures to choose from. Again, this is because performance has not been the driving force behind the development of the language. But we can build our own libraries, and we can make them reusable, and each time we improve a library we make it easier for the next programmer to gain efficiency with minimal effort. I have done my little part by making the data structures described in this book available on GitHub at [https://github.com/mailund/ralgo](https://github.com/mailund/ralgo). Feel free to use my code in your analyses, and I would love to get pull requests with improvements.

This book does not provide an exhaustive list of functional data structures. There are many different variations of data structures, many of which can be translated into persistent/functional versions. I hope to see more of them in R packages in the future, and I hope this book has motivated you to try implementing some of them. If you do, I would love to hear about it.

This is the end of the book. I hope it has been useful in learning object-oriented programming as understood by the R programming language. If you liked this book, why not check out my [list of other books](http://wp.me/P9B2l-DN) or 
[sign up to my mailing list](http://eepurl.com/cwIbR5)?

## Acknowledgements

I am grateful to Christian N. Storm Pedersen for fruitful discussions.

# Bibliography
