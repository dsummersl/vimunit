"staale - GetCurrentFunctionName()
"Extract the function name the cursor is inside
function! vimunit#util#GetCurrentFunctionName() "{{{2
	"call s:FindBlock('\s*fu\%[nction]\>!\=\s.*(\%([^)]*)\|\%(\n\s*\\[^)]*\)*\n)\)', '', '', '^\s*endf\%[unction]', 0)
	"bWn ==> b=Search backward, W=Don't wrap around end of file,n=Do not move cursor.
	let nTop = searchpair('^\s*fu\%[nction]\%[!]\ .*','','^\s*endf\%[unction].*','bWn')
	let sLine = getline(nTop)
	return sLine
endfunction

" TODO this is great function that should be all over the place (in a general
" utility library)
function! vimunit#util#searchallpair(start,middle,end, ...)
	let flags = ''
	let stopline = 0
	let timeout = 0
	if a:0 > 0
		let flags = a:1
	endif
	if a:0 > 1
		let stopline = a:2
	endif
	if a:0 > 2
		let timeout = a:3
	endif
	" Return all matches in a file. Just like 'searchpair' but returns a list
	" of the matches in the file..
	" save the old position.
	let origpos = getpos('.')
	" go to line 1
	if matchstr(flags,'b')
		1
		let cmp='<='
	else
		$
		let cmp='>='
	endif

	if matchstr(flags,'W') == "" | let flags = flags .'W' | endif
	let lastcall = searchpair(a:start,a:middle,a:end,flags,stopline,timeout,'line(".")'.cmp.line('.'))
	let results = []
	while 1
		if lastcall != 0
			call add(results,lastcall)
		endif
		let curline = line('.')
		if cmp == '<='
			let nextStart = search(a:start,'W')
			if !nextStart
				break
			endif
		else
			let nextEnd = search(a:end,'bW')
			if !nextEnd
				break
			endif
		endif
		let lastcall = searchpair(a:start,a:middle,a:end,flags,stopline,timeout,'line(".")'.cmp.lastcall)
	endwhile
	call setpos('.',origpos)
	return results
endfunction

" Get all lines that have function definitions in the file.
" Returns a list of integers (line numbers).
function! vimunit#util#GetCurrentFunctionLocations() "{{{2
	" Get all functions in the file.
	return vimunit#util#searchallpair('^\s*fu\%[nction]\%[!]\ .*','','^\s*endf\%[unction].*','Wb')
endfunction

function! vimunit#util#ExtractFunctionName(strLine) "{{{2
" This used to be part of the GetCurrentFunctionName() routine
" But to make as much as possible of the code testable we have to isolate code
" that do any kind of buffer or window interaction.
	let lStart = matchend(a:strLine,'\s*fu\%[nction]\%[!]\s')
	let sFoo = matchstr(a:strLine,".*(",lStart)
	let sFuncName =strpart(sFoo ,0,strlen(sFoo)-1)
	return sFuncName
endfunction

" Check the length of a String. If it is greater than the 'maxlen'
" return a substring with the 'append' (ie, ...) appended.
"
" Note: forces 'str' to be a string if it isnt' already.
function! vimunit#util#substr(str,maxlen,append)
  let str = s:str(a:str)
  if len(str) > a:maxlen
    return strpart(str,0,a:maxlen) . a:append
  end
  return str
endfunction

fun! s:str(str)
  if type(a:str) != 1
    return string(a:str)
  end
  return a:str
endf

" Report the differences between two objects.
"
" Returns:
"     A list of differences (from most important to least important).
function! vimunit#util#diff(arg1,arg2)
  let maxstrlen = 10
  let types = {
        \0: "Number",
        \1: "String",
        \2: "Funcref",
        \3: "List",
        \4: "Dictionary",
        \5: "Float"
        \}
  " easy: the types are different
  if type(a:arg1) != type(a:arg2)
    return [printf('%s(%s) != %s(%s)',types[type(a:arg1)], vimunit#util#substr(a:arg1,maxstrlen,'...'), types[type(a:arg2)], vimunit#util#substr(a:arg2,maxstrlen,'...'))]
  endif
  let results = []
  " differences between two different lists
  if type(a:arg1) == type(a:arg2) && type(a:arg1) == 3
    if len(a:arg1) != len(a:arg2)
      call add(results,printf('len(%s)(%d) != len(%s)(%d)',vimunit#util#substr(a:arg1,maxstrlen,'...'),len(a:arg1),vimunit#util#substr(a:arg2,maxstrlen,'...'),len(a:arg2)))
    endif
    " TODO check each element in the list
  elseif type(a:arg1) == type(a:arg2) && type(a:arg1) == 4
    for key in keys(a:arg1)
      if !has_key(a:arg2,key)
        call add(results,'Only in first dictionary: {'. key .': '. s:str(a:arg1[key]) .'}')
      else
        "let sub = vimunit#util#diff(a:arg1[key],a:arg2[key])
        "if len(sub) > 0
        if a:arg1[key] != a:arg2[key]
          call add(results,'Different values for key "'. key .'": '. s:str(a:arg1[key]) .' != '. s:str(a:arg2[key]))
        endif
      endif
    endfor
    for key in keys(a:arg2)
      if !has_key(a:arg1,key)
        call add(results,'Only in second dictionary: {'. key .': '. s:str(a:arg2[key]) .'}')
      endif
    endfor
  else
    if a:arg1 != a:arg2
      call add(results,s:str(a:arg1) .' != '. s:str(a:arg2))
    endif
  endif
  return results
endfunction
