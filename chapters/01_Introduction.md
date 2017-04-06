
# Introduction

Welcome to the *Advanced Statistical Programming in R* series and this book, *Functional Data Structures in R*. I am writing this series, and this book, to have teaching material beyond the typical introductory level most textbooks on R have. It covers some of the more advanced techniques used in R programming such as fully exploiting functional programming, writing meta-programs (code for actually manipulating the language structures), and writing domain specific languages to embed in R.

## About the series

The *Advanced Statistical Programming in R* series consists of short, single-topic books, where each book can be used alone for teaching or learning R. That said, there will, of course, be some dependencies in topics, if not in content, among the books. For instance, functional programming is essential to understand for any serious R programming, and the first book in the series covers that. Reading the other books without understanding functional programming will not be fruitful. However, if you are already familiar with functional programming, then you can safely skip the first book.

For each book, I will make clear what I think the prerequisites for reading the book are, but for the entire series, I will expect you to be already familiar with programming and the basic R you will see in any introductory book. None of the books will give you a tutorial introduction to the R programming language.

If you have used R before for data analysis and are familiar with writing expressions and functions, and want to take it further and write more advanced R code, then the series is for you.

All that being said, the "series" exists mostly in my head right now, even when considering the books I have already published. I'm trying to sell the books to get proper printed editions, and I can't convince publishers to buy a whole series. So I write the books as a series, publish them as soon as I am done with them, but sell them individually when I get an offer. This doesn't necessarily happen in the order in which I wrote them. Below is the status of the books in series at the time I am writing this, with original titles and new titles for the books I have sold.

1. *Functional Programming in R*, now *Functional Programming in R: Advanced Statistical Programming for Data Science, Analysis and Finance* [-@mailund2017functional].
2. *Object-oriented Programming in R*
3. *Meta-programming in R*
4. *Functional Data Structures in R*


## About this book

This book gives an introduction to functional data structures. Many traditional data structures rely on the structures being mutable. We can modify search trees, change links in linked lists, rearrange values in a vector. In functional languages, and to a large degree in the R programming language, data is *not* mutable. You cannot modify existing data. The techniques that rely on modifying data structures to give us efficient building blocks for algorithmic programming cannot be used.

There are workarounds for this. R is not a *pure* functional language, and we can change variable-value bindings by modifying environment. We can exploit this to emulate pointers and implement traditional data structures this way. Or we can abandon pure R programming and implement data structures in C/C++ with some wrapper code so we can use them in our R programs. Both solutions let us use traditional data structures, but the former gives us very un-traditional R code and the latter is no use for those not familiar with other languages than R.

The good news is, however, that we don't have to abandon R when implementing data structures, if we are willing to abandon the traditional data structures instead. There are data structures we can manipulate by building new versions we can return from a function in cases where we would traditionally just modify an existing one. These data structures, so-called *functional data structures*, are different from the traditional data structures you might know, but they are worth knowing about if you plan to do serious algorithmic programming in a functional language like R.

There are not necessarily drop-in replacements for all the data structures you are used to, at least not with the same runtime performance for their operations---but there are likely to be implementations for most abstract data structures you regularly use. In cases where you might have to loose a bit of efficiency by using a functional data structures instead of a traditional one, however, you have to consider if the extra speed is worth the extra time you have to spend implementing a data structure in exotic R or a completely different language? There is always a tradeoff when it comes to speed. How much programming time is a speedup worth? If you are programming in R, chances are that you value programmer-time over computer-time. R is a high-level language and relatively slow compared to most other languages. It pays a high price in running time to provide higher levels of expressiveness. You accept this when you choose to work with R. You might have to make the same choice when it comes to choosing a functional data structure over a traditional one. Or you might conclude that you really *do* need the extra speed and choose to spend more time programming to save time when doing analysis. Only you can decide what the right choice is, based on your situation. You need to know what the choices are, though, so you need to know how you can work with data structures when you cannot modify data.


