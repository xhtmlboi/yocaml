## Welcome on my Lipsum page !
> You are on the **lipsum** page.

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

```ocaml
type (_, 'a) effects =
  | File_exists : filepath -> (< file_exists : e ; .. >, bool) effects
  | Get_modification_time :
      filepath
      -> (< get_modification_time : e ; .. >, int Try.t) effects
  | Read_file : filepath -> (< read_file : e ; .. >, string Try.t) effects
  | Write_file :
      (filepath * string)
      -> (< write_file : e ; .. >, unit Try.t) effects
  | Read_dir :
      (filepath
      * [< `Files | `Directories | `Both ]
      * filepath Preface.Predicate.t)
      -> (< read_dir : e ; .. >, filepath list) effects
  | Log : (log_level * string) -> (< log : e ; .. >, unit) effects
  | Throw : Error.t -> (< throw : e ; .. >, 'a) effects

```

*Ugh*, that sounds perfectly **stupid**... it would be like considering that
you can only express one family of effects (you could call it ... `IO`]).
Don't panic, the first parameter of type [effect] allows you to make a
selective choice when defining `Freer`. One could say that one takes
advantage of the **non-surjective** aspect of the constructors of a sum
(thanks to the GADTs!). Well, I'd be lying if I said I was convinced it 
was a good approach, but at least it seems viable.
