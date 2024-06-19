let pp_non_empty_list pp' formater list =
  let pp_sep ppf () = Format.fprintf ppf ";@ " in
  Format.(
    fprintf formater "@[[%a]@]"
      (pp_print_list ~pp_sep pp')
      (Yocaml.Nel.to_list list))
