fun example#diff(a,b)
  if a:a > a:b
    return a:a - a:b
  endif
  if a:a < a:b
    return a:b - a:a
  endif
endf
