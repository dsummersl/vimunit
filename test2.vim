" Check the most basic functionality
function! TestBaseCase()
  call VUAssertEquals(example#diff(0,0),0)
endfunction

" Try one basic comparison
function! TestGreater()
  call VUAssertEqual(example#diff(3,2),1)
  call VUAssertEqual(example#diff(2,3),1)
endfunction
