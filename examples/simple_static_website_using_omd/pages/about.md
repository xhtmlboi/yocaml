## Welcome on my page, it is about page!
> You are on the about page.

To be beautiful and modern, this project separates the description of the
programme from its interpretation. But as the composition is not really to
my taste in Preface, I decided to centralize all the effects, like the
errors, in one module.

*Ugh*, that sounds perfectly **stupid**... it would be like considering that
you can only express one family of effects (you could call it ... `IO`]).
Don't panic, the first parameter of type [effect] allows you to make a
selective choice when defining `Freer`. One could say that one takes
advantage of the **non-surjective** aspect of the constructors of a sum
(thanks to the GADTs!). Well, I'd be lying if I said I was convinced it 
was a good approach, but at least it seems viable.
