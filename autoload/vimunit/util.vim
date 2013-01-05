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

" Return the contenxt of the 'vimunit#util#diff' method as a
" human readable string.
"
" Arguments:
"     - elements: the array returned by vimunit#util#diff
"     -      ...: optional indent level.
function! vimunit#util#diff2str(elements,...)
  let indent = 0
  if exists('a:1')
    let indent = a:1
  endif
  let results = ''
  for ad in a:elements
    if len(results) > 0
      let results = results .'\n'
    endif
    if type(ad) == 1
      let results = results . repeat(' ',indent) . ad
    else
      let results = results . vimunit#util#diff2str(ad,indent+2)
    endif
    unlet ad
  endfor
  return results
endfunction

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
  " differences between two lists
  if type(a:arg1) == type(a:arg2) && type(a:arg1) == 3
    if len(a:arg1) != len(a:arg2)
      call add(results,printf('len(%s)(%d) != len(%s)(%d)',vimunit#util#substr(a:arg1,maxstrlen,'...'),len(a:arg1),vimunit#util#substr(a:arg2,maxstrlen,'...'),len(a:arg2)))
    else
      for idx in range(len(a:arg1))
        let idxdiff = vimunit#util#diff(a:arg1[idx],a:arg2[idx])
        if len(idxdiff) > 0
          call add(results,'Different values for index '. idx)
          call add(results,idxdiff)
        endif
      endfor
    endif
  elseif type(a:arg1) == type(a:arg2) && type(a:arg1) == 4
    for key in keys(a:arg1)
      if !has_key(a:arg2,key)
        call add(results,'Only in first dictionary: {'. key .': '. s:str(a:arg1[key]) .'}')
      else
        "let sub = vimunit#util#diff(a:arg1[key],a:arg2[key])
        "if len(sub) > 0
        if a:arg1[key] != a:arg2[key]
          call add(results,'Different values for key "'. key .'"')
          call add(results,vimunit#util#diff(a:arg1[key],a:arg2[key]))
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

" Parses the file created by the 'verbose' vim option. Returns
" a map for each function with the last line that was reached
" in that function.
"
" Each key points to another dictionary with two values:
" - offset: offset into function
" - detail: the line as printed
" - status: unknown/returned/aborted
" - child: if this function aborted, this key will contain the child function
"   name (which should be in this dictionary)
function! vimunit#util#parseVerboseFile(filename)
  let results = {}
  let currentfunction = ''
  for line in readfile(a:filename)
    call VULog('line = '. line)

    if currentfunction != '' && !has_key(results,currentfunction)
      let results[currentfunction] = {}
      let results[currentfunction]['status'] = 'unknown'
      let results[currentfunction]['detail'] = ''
    endif

    if line =~ '^\v\s*calling function.*\.\.[^(]+\([^)]*\)$'
      let currentfunction = substitute(line,'^\v\s*calling function.*\.\.([^(]+)\([^)]*\)$','\=submatch(1)','')
      " if the key doesn't exist, set it up
      if !has_key(results,currentfunction)
        let results['_count_'. currentfunction] = 1
      else
        " if it does exist, set it up, and give it a new unique key
        let results['_count_'. currentfunction] = results['_count_'. currentfunction] + 1
        let currentfunction = currentfunction .'('. results['_count_'. currentfunction] .')'
      endif
      let results[currentfunction] = {}
      let results[currentfunction]['status'] = 'unknown'
      let results[currentfunction]['detail'] = ''
      call VULog('currentfunction = "'. currentfunction .'"')
    elseif line =~ 'continuing in function'
      let currentfunction = substitute(line,'^\v\s*continuing in function .*<([^. (]+)$','\=submatch(1)','')
      call VULog('currentfunction = "'. currentfunction .'"')
    elseif line =~ '^\s*function .* returning' && currentfunction != ''
      call VULog('returning '. currentfunction)
      let matches = matchlist(line,'^\s*function .* returning\v(.*)$')
      if len(matches) > 0
        let results[currentfunction]['detail'] = matches[1]
      endif
      let results[currentfunction]['status'] = 'returned'
      " for the root function that fails, it has no child..
    elseif line =~ 'Exception thrown:' && currentfunction != ''
      call VULog('except for '. currentfunction)
      let matches = matchlist(line,'Exception thrown:\v(.*)$')
      let results[currentfunction]['status'] = 'aborted'
    elseif line =~ '\vfunction .*\.\.([^.]*)\.\.([^.]*) aborted'
      " record an aborted function, and note its child function (if its
      " bubbling up the stack)
      let matches = matchlist(line,'\vfunction .*\.\.([^.]*)\.\.([^.]*) aborted')
      if !has_key(results,matches[1])
        call VULog("tempcurrentfunction = ". matches[1])
        let results[matches[1]] = {}
        let results[matches[1]]['status'] = 'unknown'
        let results[matches[1]]['detail'] = ''
      endif
      call VULog("ugcurrentfunction = ". matches[1])
      let results[matches[1]]['status'] = 'aborted'
      let results[matches[1]]['child'] = matches[2]
    elseif currentfunction != ''
      " we are within a file, if the line starts with line then we'll want to
      " parse that.
      if line =~ '^\s*line '
        call VULog('line')
        let results[currentfunction]['offset'] = str2nr(substitute(line,'^\v\s*line (\d+):','\=submatch(1)',''))
        let results[currentfunction]['detail'] = substitute(line,'^\v.*: (.*)$','\=submatch(1)','')
      else
        call VULog('unused line (cf): '. line)
      endif
    else
      " throw away...
      call VULog('unused line: '. line)
    endif
  endfor
  return results
endfunction
