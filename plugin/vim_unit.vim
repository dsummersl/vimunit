" Normally za or zR will open the folds- zM will close them all.
" File header {{{1
" --------------------------------------------------------------
"  FILE:            vimUnit.vim
"  AUTHOR:          Staale Flock, Staale -- lexholm .. no
"  VERSION:         0.1
"  LASTMODIFIED:    8 Nov 2004
"
"  PURPOSE:
"		To provide vim scripts with a simple unit testing framework and tools.
"		The framework and tools should resemble JUnit's interface definitions
"		to ease usage of both frameworks (and others based on JUnit). 
"		Obviously vim scripts are not java so I will only try to implement the
"		stuff useful to vim scripts. As a first milestone I think the 
"		junit.Assert and junit.TestResult classes to get a vim-script
"		unit-testing environment going.
"		
"  WHY:
" 		Well, I have been working on some vim-scripts and read a lot of them
" 		the last two weeks and I really, really miss my unit-test (and
" 		mock-object, but that is fare fetched I think..:O) tools to get my own
" 		stuff of the ground (and making modifications to your's).
" 		
"  THOUGHTS:
"		Writing unit-test code against a UI environment is often very difficult 
"		or demanding to creative solutions to be productive. We would like to 
"		have a mock-object framework to go with the unit-testing framework.
"		
"  INSTALLATION:
"  		Place this file in your plugin directory (~/.vim/ftplugin/)
"  		When you start vim again and open a vim file for editing you should
"  		get a message that vimUnit has installed its documentation.
"  		To get you started you could try :h vimUnit
"  		
"  TIPS:
"  		Documentation (when written..:o) is found at the bottom of this file. 
"  		Thanks to code from vimspell.vim it should be self-installing the first
"  		time this module is loaded
"
"  		If your new to test-first principles and thinking you should start
"  		with the article: 
"  			http://junit.sourceforge.net/doc/testinfected/testing.htm
"  		And then surf the web on these locations:
"  			http://www.junit.org/
"  			http://xprogramming.com/
"  			http://www.extremeprogramming.org/
" 
"  NOTE:
"		8 Nov 2004 (v 0.1) This is my initial upload. The module is far
"		from finished. But as I could do with some input from other vim users
"		So I have chosen to let people know I'm working on it. 
"
"		To be conform with vim-script naming conventions functions are
"		prepended with VU (VimUnit). So stuff you would normaly would call 
"		VUAssert are called VUAssert, TestRunner* are called VURunner and so on.
"		Global variables starts with vimUnit*
"		

"		
"  CREDITS:
"
"  Best Regards
"  Staale Flock, (staale -- lexholm .. no)
"  Norway
" ---------------------------------------------------------------------------
"  
" A first try on unit testing vim scripts
" TODO: How do I unit test autocmd's?
" TODO: How do I unit test map, imap and so on?
" TODO: How do I unit test buffers
" TODO: how do I unit test windows
" TODO: how do I unit test the CTRL-W (wincmd) commands?

" Define true and false {{{1
if !exists('g:false')
	let g:FALSE = (1 != 1)
endif
if !exists('g:true')
	let g:TRUE = (1 == 1)
endif
if !exists('false')
	let false = g:FALSE
endif
if !exists('true')
	let true = g:TRUE
endif
if !exists('*TRUE')
	function! TRUE()
		let sFoo = (1 == 1)
		return sFoo
	endfunction
endif
if !exists('*FALSE')
	function! FALSE()
		let sFoo = (1 != 1)
		return sFoo
	endfunction
endif 

"Variables {{{1
"	Variables Global{{{2
"	Global variables might be set in vimrc

if !exists('g:vimUnitSelfTest')
"	1 ==> Always run self test when loaded
"	0 ==> Do not run self test when loaded. SelfTest will however run if the
"	file is modified since the documentation was installed.
	let g:vimUnitSelfTest = 0
endif

if !exists('g:vimUnitVerbosity')
	"At the moment there is just 0 (quiet) and 1(verbose)
	let g:vimUnitVerbosity = 1
endif

if !exists('g:vimUnitFailFast')
	"Defaults to false (legacy behavior)
	let g:vimUnitFailFast = 0
endif

"	Variables Script{{{2
if !exists('s:lastAssertionResult')
    let s:lastAssertionResult = TRUE()
endif
" Messages sink
if !exists('s:msgSink')
    let s:msgSink = []
endif
" How many test's did we run
if !exists('s:testRunCount')
	let s:testRunCount = 0
endif
" How many successfully test's did we run
if !exists('s:testRunSuccessCount')
	let s:testRunSuccessCount = 0
endif
"How many test's failed
if !exists('s:testRunFailureCount')
	let s:testRunFailureCount = 0
endif
"How many test was expected to fail
if !exists('s:testRunExpectedFailuresCount')
	let s:testRunExpectedFailuresCount = 0
endif
"
if !exists('s:suiteRunning')
	let s:suiteRunning = FALSE()
endif



" VUAssert {{{1
" -----------------------------------------
" FUNCTION:	TODO:
" PURPOSE:
"	Just a reminder that a function is not (fully) implemented.
" ARGUMENTS:
"	funcName:	The name of the calling function
" RETURNS:
"	false
" -----------------------------------------
function! TODO(funcName) "{{{2
	echomsg '[TODO] '.a:funcName
	return FALSE()
endfunction
" ---------------------------------------------------------------------
" FUNCTION:	VUAssertEquals
" PURPOSE:
"	Compare arguments
" ARGUMENTS:
" 	arg1 : Argument to be tested.
" 	arg2 : Argument to test against.
"	...  : Optional message.
" RETURNS:
"	1 if arg1 == arg2
"	0 if arg1 != arg2
" ---------------------------------------------------------------------
function! VUAssertEquals(arg1, arg2, ...) "{{{2
	let s:testRunCount = s:testRunCount + 1
	" check the types..."
	if a:arg1 == a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
		let arg1text = string(a:arg1)
		let arg2text = string(a:arg2)
		let msg = ''
		if (exists('a:1'))
			let msg = " MSG: ". a:1
		endif
		" TODO implement nice comparisons for dictionaries
		" nice comparison for lists
		if type(a:arg1) == type(a:arg2) && type(a:arg1) == 3
			if len(a:arg1) != len(a:arg2)
				call <SID>MsgSink('AssertEquals','Lengths differ: len(arg1)=='. len(a:arg1) .' and len(arg2)=='. len(a:arg2) .' arg1='. arg1text .'!='. arg2text . msg)
				" TODO if they are the same length then explain which index's
				" differ
			else
				call <SID>MsgSink('AssertEquals','arg1='. arg1text .'!='. arg2text . msg)
			endif
		else
			call <SID>MsgSink('AssertEquals','arg1='. arg1text .'!='. arg2text . msg)
		endif
	endif
	let s:lastAssertionResult = bFoo
	return bFoo
endfunction
" ---------------------------------------------------------------------
" FUNCTION:	VUAssertTrue
" PURPOSE:
" 	Check that the passed argument validates to true
" ARGUMENTS:
" 	arg1: Should validate to TRUE() == (1==1)
" 	... : Optional message placeholder.
" RETURNS:
" 	TRUE() if true and
" 	FALSE() if false
" ---------------------------------------------------------------------
function! VUAssertTrue(arg1, ...) "{{{2
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == TRUE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call <SID>MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE()." MSG: ".a:1)
        else
            call <SID>MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE())
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo
endfunction
" ---------------------------------------------------------------------
" FUNCTION:	 VUAssertFalse
" PURPOSE:
"	Test if the argument equals false
" ARGUMENTS:
"	arg1:	Contains something that will be evaluated to true or false
" 	... : Optional message placeholder.
" RETURNS:
"	0 if true
"	1 if false
" ---------------------------------------------------------------------
function! VUAssertFalse(arg1, ...) "{{{2
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == FALSE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call <SID>MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE()." MSG: ".a:1)
        else
            call <SID>MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE())
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo
endfunction

" VUAssert that the arg1 is initialized (is not null)
" Is this situation possible in vim script?
function! VUAssertNotNull(arg1, ...) "{{{2	
	"NOTE: I do not think we will have a situation in a vim-script where we
	"can pass a variable containing a null as I understand it that is a 
	"uninitiated variable. 
	"
	"vim will give a warning (error) msg when we try to do this.
	"
	"BUT: We can have situations where we try to do this. Especialy if we are
	"using on-the-fly variable names. :help curly-braces-names
	"
	let s:testRunCount = s:testRunCount + 1
	if exists(a:arg1)
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
		call <SID>MsgSink('AssertNotNull','arg1: Does not exist')
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo		
endfunction

" VUAssert the the two variables dos not reference the same memory ?
" NOTE: Do not think we can control this in vim
function! VUAssertNotSame(arg1,arg2,...) "{{{2
	let s:testRunCount = s:testRunCount + 1
	"Could not do: if &a:arg1 != &a:arg2
	if a:arg1 != a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call <SID>MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2." MSG: ".a:1)
        else
            call <SID>MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo		
endfunction

"Assert that arg1 and arg2 reference the same memory
"NOTE: Don't know how to test this in vim
function! VUAssertSame(arg1, arg2, ...) "{{{2
	let s:testRunCount = s:testRunCount + 1
	"TODO: This does not ensure the same memory reference.
	if a:arg1 == a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call <SID>MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2." MSG: ".a:1)
        else
            call <SID>MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo	
endfunction

"Fail a test with no arguments
function! VUAssertFail(...) "{{{2
	let s:testRunCount = s:testRunCount + 1	
	let s:testRunFailureCount = s:testRunFailureCount + 1
    if (exists('a:1'))
        call <SID>MsgSink('AssertFail','MSG: '.a:1)
    else
        call <SID>MsgSink('AssertFail','')
    endif
    let s:lastAssertionResult = FALSE()
	return FALSE()	
endfunction

" ---------------------------------------------------------------------
" FUNCTION:	VUTraceMsg
" PURPOSE:
"	Add a debug message to the final testing report.
" ARGUMENTS:
" 	msg : The debug message
" ---------------------------------------------------------------------
function! VUTraceMsg(msg) 
    call <SID>MsgSink('', a:msg)
endfunction

" VURunner {{{1
function! VURunnerRunTest(test) 
	try
		let did_vim_unit_vim = 1
		"exe "call ".sFoo.'()'
		call VURunnerInit()
		echo "Running: ".a:test
		call {a:test}()
		call VURunnerPrintStatistics('VUAutoRun:'.a:test)
	catch /.*/
		echo "Failed: ". a:test
		echo "Error: ". v:exception ." -- ". v:throwpoint
	endtry
endfunction
" ----------------------------------------- {{{2
" FUNCTION:	VURunnerPrintStatistics
" PURPOSE:
"	Print statistics about test's
" ARGUMENTS:
"	None
" RETURNS:
"	String containing statistics
" -----------------------------------------
function! VURunnerPrintStatistics(caller,...) "{{{2
	if exists('s:suiteRunning') && s:suiteRunning == FALSE()
		if exists('a:caller')
			let sFoo = "----- ".a:caller."---------------------------------------------\n"
		else
			let sFoo ="--------------------------------------------------\n"
		endif
		if exists('a:1') && a:1 != ''
			let sFoo = sFoo."MSG: ".a:1
		endif
		if g:vimUnitVerbosity
			" only if verbosity is on
			for msg in s:msgSink
				echo msg[0].': '.msg[1].(msg[2] != '' ? ' => source: ' . msg[2] . '()' : '')
			endfor
		endif
		let sFoo = sFoo."Test count:\t".s:testRunCount."\nTest Success:\t".s:testRunSuccessCount."\nTest failures:\t".s:testRunFailureCount."\nExpected failures:\t".s:testRunExpectedFailuresCount
		let sFoo = sFoo."\n--------------------------------------------------\n"
		echo sFoo
		if s:testRunSuccessCount + s:testRunExpectedFailuresCount == s:testRunCount
			echo "\n*** SUCCESS ***\n"
		else
			echo "\n!!! FAILURE !!!\n"
		endif
		return sFoo
	else
		"echomsg "SUITE RUNNING:"
		return ''
	endif
endfunction

function! VURunnerInit() "{{{2
	if exists('s:suiteRunning') && s:suiteRunning == FALSE()
		let s:lastAssertionResult = TRUE()
		let s:msgSink = []
		let s:testRunCount = 0
		let s:testRunFailureCount = 0
		let s:testRunSuccessCount = 0
		let s:testRunExpectedFailuresCount = 0
	endif
endfunction

" doc -------------------------------------
" FUNCTION:	VURunnerStartSuite
" PURPOSE:
"	When we run a UnitTestSuite we do not want statistics to be corrupted by
"	the TestGroup.
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------
function! VURunnerStartSuite(caller) "{{{2
	call VURunnerInit()
	let s:suiteRunning = TRUE()
endfunction

" -----------------------------------------
" FUNCTION:	 VURunnerStopSuite
" PURPOSE:
"	
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------
function! VURunnerStopSuite(caller) "{{{2
	let s:suiteRunning = FALSE()
endfunction

" -----------------------------------------
" FUNCTION:	 VURunnerExpectError
" PURPOSE:
"	Notify the runner that the next test is supposed to fail
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------

function! VURunnerExpectFailure(...) "{{{2
	if g:vimUnitFailFast
		throw "VURunnerExpectFailure incompatible with g:vimUnitFailFast mode. Use try/catch blocks"
	endif
	" This function will throw an exception if the last assert statement did
	" not fail. Use this to ensure that a enexpected success is caught.
	let s:testRunExpectedFailuresCount = s:testRunExpectedFailuresCount + 1
	"if (a:caller == s:msgSink[-1][0] && s:lastAssertionResult == 0)
	if (s:lastAssertionResult)
		if (len(s:msgSink) > 0)
			throw "Expected failure, but last assertion passed: ".string(s:msgSink[-1])
		else
			throw "Expected failure, but last assertion passed."
		endif
	endif
endfunction

function! <sid>MsgSink(caller,msg) "{{{2
    " recording of the last failure
	let trace = split(expand("<sfile>"), '\.\.')
	let msg = [[ a:caller,a:msg, (len(trace) >= 3 ? trace[-3] : '') ]]
	if g:vimUnitFailFast
		throw string(msg[0][1])
	endif
	if g:vimUnitVerbosity > 0
		let s:msgSink = s:msgSink + msg
		"echo a:caller.': '.a:msg
	endif
endfunction

"staale - GetCurrentFunctionName()
"Extract the function name the cursor is inside
function! <SID>GetCurrentFunctionName() "{{{2
	"call s:FindBlock('\s*fu\%[nction]\>!\=\s.*(\%([^)]*)\|\%(\n\s*\\[^)]*\)*\n)\)', '', '', '^\s*endf\%[unction]', 0)
	"bWn ==> b=Search backward, W=Don't wrap around end of file,n=Do not move cursor.
	let nTop = searchpair('^\s*fu\%[nction]\%[!]\ .*','','^\s*endf\%[unction].*','bWn')
	let sLine = getline(nTop)
	return sLine
endfunction

" TODO this is great function that should be all over the place (in a general
" utility library)
function! <SID>searchallpair(start,middle,end, ...) 
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

function! <SID>GetCurrentFunctionNames() "{{{2
	" Get all functions in the file.
	let matches = <SID>searchallpair('^\s*fu\%[nction]\%[!]\ .*','','^\s*endf\%[unction].*','Wb')
	let results = []
	for m in matches
		let sLine = getline(m)
		call add(results,sLine)
	endfor
	return results
endfunction

function! <SID>ExtractFunctionName(strLine) "{{{2
" This used to be part of the GetCurrentFunctionName() routine
" But to make as much as possible of the code testable we have to isolate code
" that do any kind of buffer or window interaction.
	let lStart = matchend(a:strLine,'\s*fu\%[nction]\%[!]\s')
	let sFoo = matchstr(a:strLine,".*(",lStart)
	let sFuncName =strpart(sFoo ,0,strlen(sFoo)-1)
	return sFuncName
endfunction
"function VURunAllTests {{{2
" -----------------------------------------
" FUNCTION: VURunAllTests
" PURPOSE:  Runs all the tests in the current file.
"
" ARGUMENTS:
"   optional boolean. If true, then this function will exit vim with an error
"   code. Suitable for scripting unit tests ala
"
"       vim -nc 'so %' <filename>
"
"   optional output file. If set, then the output is saved to the output file
"   specified. Meant to be used with the former option set to true.
"
" RETURNS:
"
"   Prints out the test results.
"
" -----------------------------------------
function! VURunAllTests(...)
	" Run all the tests that exist in this file.
	" NOTE:If you change this code you must manualy source the file!

	let oldFailFast = g:vimUnitFailFast
	let g:vimUnitFailFast = 1
	let oldvfile = &verbosefile
	let oldverbose = &verbose

	"Locate function line on line with or above current line
	let messages = []
	let goodTests = 0
	let badTests = 0
	let goodAssertions = 0
	let badAssertions = 0
	for fn in <SID>GetCurrentFunctionNames()
		let sFoo = <SID>ExtractFunctionName(fn)
		if match(sFoo,'^Test') > -1
			if exists( '*'.sFoo)
				try
					call VURunnerInit()
					" TODO make the verbose file a temp file.
					" Get the line number of this particular function
					" then grep the verbose file for the offset.
					exe "silent !rm -f vfile.txt"
					set verbosefile=vfile.txt
					set verbose=20
					call {sFoo}()
					let goodTests = goodTests + 1
				catch /.*/
					exec "set verbose=".oldverbose
					exec "set verbosefile=".oldvfile
					exec "silent !grep -A 2 'continuing in function.*". sFoo ."$' vfile.txt | tail -n 5 | head -n 1 > vline.txt"
					let lineno = readfile('vline.txt')[0]
					call add(messages,printf("%-15s     Good assertions: %3d",sFoo,s:testRunSuccessCount))
					call add(messages,"    Error: ". v:exception)
					call add(messages,"    ". lineno)
					let badTests = badTests + 1
				finally
					exec "set verbose=".oldverbose
					exec "set verbosefile=".oldvfile
					let goodAssertions = goodAssertions + s:testRunSuccessCount
					let badAssertions = badAssertions + s:testRunFailureCount
				endtry
			else
				call confirm ("ERROR: VUAutoRunner. Function name: ".sFoo." Could not be found by function exists(".sFoo.")")
			endif
		else
			call add(messages,"NOTE: Found function name: ".sFoo." Does not start with Test.So we will not run it automaticaly")
		endif
	endfor

	" final deletion of log files.
	exe "silent !rm -f vfile.txt"
	exe "silent !rm -f vline.txt"
	let g:vimUnitFailFast = oldFailFast

	call add(messages, "")
	call add(messages, "----------------------------------------------")
	call add(messages, "Summary:")
	call add(messages, printf(" OK (%3d tests, %3d assertions)",goodTests,goodAssertions))
	if badTests > 0
		call add(messages, printf("BAD (%3d tests)",badTests))
	endif
	if a:0 > 1
		call writefile(messages,a:000[1])
	else
		for line in messages
			echo line
		endfor
	endif
	if a:0 > 0 && a:000[0]
		if badTests > 0
			cquit
		else
			quit
		endif
	endif
endfunction

"function VUAutoRun {{{2
" We have to make a check so we can AutoRun vimUnit.vim itself
if !exists('s:vimUnitAutoRun')
	let s:vimUnitAutoRun = 0
endif
if s:vimUnitAutoRun == 0
function! VUAutoRun() 
	"NOTE:If you change this code you must manualy source the file!

	let s:vimUnitAutoRun = 1
	"Prevent VimUnit from runing selftest if we are testing VimUnit.vim
	let b:currentVimSelfTest = g:vimUnitSelfTest
	let g:vimUnitSelfTest = 0
	"Locate function line on line with or above current line
	let sFoo = <SID>ExtractFunctionName(<SID>GetCurrentFunctionName())
	if match(sFoo,'^Test') > -1 
		"We found the function name and it starts with Test so we source the
		"file and call VURunnerRunTest to run the test
		exe "w|so %"
		if exists( '*'.sFoo)
			call VURunnerRunTest(sFoo)
		else
			call confirm ("ERROR: VUAutoRunner. Function name: ".sFoo." Could not be found by function exists(".sFoo.")")
		endif
	else
		"
		echo "NOTE: Found function name: ".sFoo." Does not start with Test.So we will not run it automaticaly"
	endif
	let s:vimUnitAutoRun = 0
	let g:vimUnitSelfTest = b:currentVimSelfTest
endfunction
endif

" SelfTest VUAssert {{{1
function! TestVUAssertEquals() "{{{2
	let sSelf = 'TestVUAssertEquals'
	call VUAssertEquals(1,1)
	call VUAssertEquals(1,2)
	call VURunnerExpectFailure()

	call VUAssertEquals('str1','str1','Simple test comparing two strings')
	call VUAssertEquals('str1',"str1",'Simple test comparing two strings')
	call VUAssertEquals('str1','str2','Simple test comparing two diffrent strings,expect failure')	
	call VURunnerExpectFailure(sSelf,"AssertEquals(\'str1\',\"str1\",\"\")")

	call VUAssertEquals(123,'123','Simple test comparing number and string containing number')
	call VUAssertEquals(123,'321','Simple test comparing number and string containing diffrent number,expect failure')
	call VURunnerExpectFailure(sSelf,"AssertEquals(123,'321',\"\")")
	
	let arg1 = 1
	let arg2 = 1
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing the same number')
	let arg2 = 2
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing diffrent numbers,expect failure')
	call VURunnerExpectFailure(sSelf,'AssertEquals(arg1=1,arg2=2,"")')

	let arg1 = "test1"
	let arg2 = "test1"
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing equal strings')
	let arg2 = "test2"
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing diffrent strings,expect failure')
	call VURunnerExpectFailure(sSelf,'AssertEquals(arg1=test1,arg2=test2,"")')

	call VUAssertEquals([],[])
	call VUAssertEquals([1],[])
	call VURunnerExpectFailure(sSelf,'call VUAssertEquals([1],[])')
	call VUAssertEquals([],[1])
	call VURunnerExpectFailure(sSelf,'call VUAssertEquals([],[1])')
	call VUAssertEquals([],[[1]])
	call VURunnerExpectFailure(sSelf,'call VUAssertEquals([],[[1]])')
	call VUAssertEquals([[1]],[])
	call VURunnerExpectFailure(sSelf,'call VUAssertEquals([[1]],[])')

	call VUAssertEquals({},{})
	call VUAssertEquals({1:1},{})
	call VURunnerExpectFailure(sSelf,'AssertEquals({1:1},{})')
	call VUAssertEquals({1:{}},{1:{}})
	call VUAssertEquals({1:{2:2}},{1:{}})
	call VURunnerExpectFailure(sSelf,'AssertEquals({1:{2:2}},{1:{}})')
	call VUAssertEquals({'1':{'count':1, 'pluginCount':1, 'text':'..', 'hi':'testhi', 'plugins':['Test2'], 'line':1}},{'1':{'count':1, 'pluginCount':1, 'text':'..', 'hi':'testhi', 'plugins':['Test2'], 'line':1}})

"	call VUAssertEquals(%%%,%%%,"Simple test comparing %%%')
"	call VURunnerExpectFailure(sSelf,'AssertEquals(%%%,%%%,"")')
"	call VUAssertEquals(%%%,%%%,"Simple test comparing %%%,expect failure')
endfunction

function! TestVUAssertTrue() "{{{2
	let sSelf = 'TestVUAssertTrue'
	call VUAssertTrue(TRUE())
	call VUAssertTrue(FALSE())	
	call VURunnerExpectFailure(sSelf,'AssertTrue(FALSE(),"")')

	call VUAssertTrue(1,'Simple test passing 1')
	call VUAssertTrue(0, 'Simple test passing 0,expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertTrue(0,"")')

	let arg1 = 1
	call VUAssertTrue(arg1,'Simple test arg1 = 1')
	let arg1 = 0
	call VUAssertTrue(arg1, 'Simple test passing arg1=0,expect failure')		
	call VURunnerExpectFailure(sSelf,'AssertTrue(arg1=0,"")')

	
	call VUAssertTrue("test",'Simple test passing string')
	call VURunnerExpectFailure(sSelf,'AssertTrue("test","")')
	call VUAssertTrue("", 'Simple test passing empty string,expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertTrue("","")')

	let arg1 = 'test'
	call VUAssertTrue(arg1,'Simple test passing arg1 = test')
	call VURunnerExpectFailure(sSelf,'AssertTrue(arg1="test","")')
	call VUAssertTrue(arg1, 'Simple test passing arg1="",expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertTrue(arg1="","")')

"	call VUAssertTrue(%%%,'Simple test %%%')
"	call VURunnerExpectFailure(sSelf,'AssertTrue(%%%,"")')
"	call VUAssertTrue(%%%, 'Simple test %%%,expect failure')		
	
endfunction

function! TestVUAssertFalse() "{{{2
	let sSelf = 'TestVUAssertFalse'
	call VUAssertfalse(FALSE())	
	call VUAssertFalse(TRUE())	
	call VURunnerExpectFailure(sSelf,'AssertFalse(TRUE(),"")')

	call VUAssertFalse(0,'Simple test passing 0')
	call VUAssertFalse(1, 'Simple test passing 1,expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertFalse(1,"")')

	let arg1 = 0
	call VUAssertFalse(arg1,'Simple test arg1 = 0')
	let arg1 = 1
	call VUAssertFalse(arg1, 'Simple test passing arg1=1,expect failure')		
	call VURunnerExpectFailure(sSelf,'AssertFalse(arg1=1,"")')

	call VUAssertFalse("test",'Simple test passing string')
	call VURunnerExpectFailure(sSelf,'AssertFalse("test","")')
	call VUAssertFalse("", 'Simple test passing empty string,expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertFalse("","")')

	let arg1 = 'test'
	call VUAssertFalse(arg1,'Simple test passing arg1 = test')
	call VURunnerExpectFailure(sSelf,'AssertFalse(arg1="test","")')
	call VUAssertFalse(arg1, 'Simple test passing arg1="",expect failure')	
	call VURunnerExpectFailure(sSelf,'AssertFalse(arg1="","")')
	
endfunction
function! TestVUAssertNotNull() "{{{2
	"NOTE: I do not think we will have a situation in a vim-script where we
	"can pass a variable containing a null as I understand it that is a 
	"uninitiated variable. 
	"
	"vim will give a warning (error) msg when we try to do this.
	"
	"BUT: We can have situations where we try to do this. Especeialy if we are
	"using on-the-fly variable names. :help curly-braces-names
	"
	let sSelf = 'TestVUAssertNotNull'
	try
		let sTest = ""
		unlet sTest
		call VUAssertNotNull(sTest,'Trying to pass a uninitiated variable')
	catch
		call VUAssertFail('Trying to pass a uninitiated variable')
	endtry
    call VURunnerExpectFailure(sSelf,'Trying to pass a unlet variable')
	
	try
		call VUAssertNotNull(sTest2,'Trying to pass a uninitated variable sTest2')	
	catch
		call VUAssertFail('Trying to pass a uninitated variable sTest2')
	endtry
    call VURunnerExpectFailure(sSelf,'Trying to pass a uninitiated variable')
	
endfunction

function! TestVUAssertNotSame() "{{{2
	" VUAssert the two arguments does not reference the same memory
	" NOTE: I do not know how to test this in vim.
	" TODO: Write more relevant test's
	let sSelf = 'TestVUAssertNotSame'
	let arg1 = 'test'
	let arg2 = 'test2'
	call VUAssertNotSame(arg1,arg2,'Check to se if arg1 and arg2 reference the same memory')
	call VUAssertNotSame(arg1,arg2)
	let arg2 = arg1
	call VUAssertNotSame(arg1,arg2,'arg1 = arg2 reference the same memory, expected to fail')
	call VURunnerExpectFailure(sSelf,'arg1 = arg2 is the same')
endfunction

function! TestVUAssertSame() "{{{2
	" VUAssert the two arguments does reference the same memory
	" NOTE: I do not know how to test this in vim.
	" TODO: Write more relevant test's
	let sSelf = 'TestVUAssertSame'
	let arg1 = 'test'
	let arg2 = arg1
	call VUAssertSame(arg1,arg2,'Verify that arg1 and arg2 reference the same memory')
	call VUAssertSame(arg1,arg2)
	let arg2 = 'test2'
	call VUAssertSame(arg1,arg2,'arg1=test != arg2=test2: Does not reference the same memory, expected to fail')	
	call VURunnerExpectFailure(sSelf,'arg1 != arg2 and reference diffrent memory')
endfunction

function! TestVUAssertFail() "{{{2
	let sSelf = 'testAssertFail'
	call VUAssertFail('Expected failure')
	call VURunnerExpectFailure(sSelf,'Calling VUAssertFail()')
	call VUAssertFail()
	call VURunnerExpectFailure(sSelf,'Calling VUAssertFail()')
endfunction


function! TestExtractFunctionName() "{{{1
	let sSelf = 'TestExtractFunctionName'
	"Testing legal function declarations
	"NOTE: The markers in the test creates a bit of cunfusion
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('func TestFunction()'),'straight function declaration')
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('func! TestFunction()'),'func with !')
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName(' func TestFunction()'),'space before func')
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('		func TestFunction()'),'Two embeded tabs before func') "Two embeded tabs
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('func TestFunction()	"{{{3'),'Declaration with folding marker in comment' )
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('   func TestFunction()	"{{{3'),'Declaration starting with space and ending with commented folding marker')
	let sFoo = VUAssertEquals('TestFunction',<SID>ExtractFunctionName('func TestFunction(arg1, funcarg1, ..)'),'arguments contain func')
endfunction	"}}}
function! TestGetCurrentFunctionNames() "{{{1
	let sSelf = 'TestExtractFunctionNames'
	"Testing legal function declarations
	" TODO apparently this function isn't perfect ... the following functions
	" should have been found:
"\ 'function! VURunAllTests() ', <---
"\ 'function! <SID>GetCurrentFunctionNames() "{{{2', <----
"\ 'function! VURunnerPrintStatistics(caller,...) "{{{2', <----
	let sFoo = VUAssertEquals(<SID>GetCurrentFunctionNames(),[
		\ 'function! TestSuiteVimUnitSelfTest() "{{{1',
		\ 'function! TestGetCurrentFunctionNames() "{{{1',
		\ 'function! TestExtractFunctionName() "{{{1',
		\ 'function! TestVUAssertFail() "{{{2',
		\ 'function! TestVUAssertSame() "{{{2',
		\ 'function! TestVUAssertNotSame() "{{{2',
		\ 'function! TestVUAssertNotNull() "{{{2',
		\ 'function! TestVUAssertFalse() "{{{2',
		\ 'function! TestVUAssertTrue() "{{{2',
		\ 'function! TestVUAssertEquals() "{{{2',
		\ 'function! VUAutoRun() ',
		\ 'function! <SID>ExtractFunctionName(strLine) "{{{2',
		\ 'function! <SID>searchallpair(start,middle,end, ...) ',
		\ 'function! <SID>GetCurrentFunctionName() "{{{2',
		\ 'function! <sid>MsgSink(caller,msg) "{{{2',
		\ 'function! VURunnerExpectFailure(...) "{{{2',
		\ 'function! VURunnerStopSuite(caller) "{{{2',
		\ 'function! VURunnerStartSuite(caller) "{{{2',
		\ 'function! VURunnerInit() "{{{2',
		\ 'function! VURunnerRunTest(test) ',
		\ 'function! VUTraceMsg(msg) ',
		\ 'function! VUAssertFail(...) "{{{2',
		\ 'function! VUAssertSame(arg1, arg2, ...) "{{{2',
		\ 'function! VUAssertNotSame(arg1,arg2,...) "{{{2',
		\ 'function! VUAssertNotNull(arg1, ...) "{{{2	',
		\ 'function! VUAssertFalse(arg1, ...) "{{{2',
		\ 'function! VUAssertTrue(arg1, ...) "{{{2',
		\ 'function! VUAssertEquals(arg1, arg2, ...) "{{{2',
		\ 'function! TODO(funcName) "{{{2'
		\ ])
endfunction	"}}}

function! TestSuiteVimUnitSelfTest() "{{{1
	let sSelf = 'TestSuiteVimUnitSelfTest'
	call TestVUAssertEquals()
	call TestVUAssertTrue()
	call TestVUAssertNotNull()
	call TestVUAssertNotSame()
	call TestVUAssertSame()
	call TestVUAssertFail()
	call TestExtractFunctionName()
	call TestGetCurrentFunctionNames()
endfunction
