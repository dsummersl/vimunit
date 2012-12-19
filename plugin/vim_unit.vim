fun s:str(str)
  if type(a:str) != 1
    return string(a:str)
  end
  return a:str
endf

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
"
" TODO: split out the unit tests
"

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
	let diffs = vimunit#util#diff(a:arg1,a:arg2)
	let s:testRunCount = s:testRunCount + 1
	" check the types..."
	if len(diffs) == 0
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
		let arg1text = s:str(a:arg1)
		let arg2text = s:str(a:arg2)
		let msg = ''
		if (exists('a:1'))
			let msg = " MSG: ". a:1
		endif
		let diffs = vimunit#util#diff(a:arg1,a:arg2)
		if len(diffs) > 0
			call vimunit#util#MsgSink('AssertEquals',diffs[0])
		else
			call vimunit#util#MsgSink('AssertEquals','arg1='. arg1text .'!='. arg2text . msg)
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
            call vimunit#util#MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE()." MSG: ".a:1)
        else
            call vimunit#util#MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE())
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
			call vimunit#util#MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE()." MSG: ".a:1)
		else
			call vimunit#util#MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE())
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
		call vimunit#util#MsgSink('AssertNotNull','arg1: Does not exist')
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
            call vimunit#util#MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2." MSG: ".a:1)
        else
            call vimunit#util#MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2)
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
            call vimunit#util#MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2." MSG: ".a:1)
        else
            call vimunit#util#MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2)
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
        call vimunit#util#MsgSink('AssertFail','MSG: '.a:1)
    else
        call vimunit#util#MsgSink('AssertFail','')
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
    call vimunit#util#MsgSink('', a:msg)
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
	echom "WARNING: VURunnerExpectFailure is deprecated."
	if g:vimUnitFailFast
		throw "VURunnerExpectFailure incompatible with g:vimUnitFailFast mode. Use try/catch blocks"
	endif
	" This function will throw an exception if the last assert statement did
	" not fail. Use this to ensure that a enexpected success is caught.
	let s:testRunExpectedFailuresCount = s:testRunExpectedFailuresCount + 1
	"if (a:caller == s:msgSink[-1][0] && s:lastAssertionResult == 0)
	if (s:lastAssertionResult)
		if (len(s:msgSink) > 0)
			throw "Expected failure, but last assertion passed: ".s:str(s:msgSink[-1])
		else
			throw "Expected failure, but last assertion passed."
		endif
	endif
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
	for fn in vimunit#util#GetCurrentFunctionLocations()
		let sFoo = vimunit#util#ExtractFunctionName(getline(fn))
		if match(sFoo,'^Test') > -1
			if exists( '*'.sFoo)
				try
					call VURunnerInit()
					" TODO Make the verbose file a temp file.
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
					" for debugging an error, save the output for later use...
					"exec "silent !cp vfile.txt verr-". sFoo .".txt"
					call add(messages,printf("%-25s| Good assertions: %3d",sFoo,s:testRunSuccessCount))
					call add(messages,"  Error: ". v:exception)
					" Extract the line where the test failed (if there was an exception)
					exec "silent !grep -B 3 'function .*". sFoo ."\.\..* aborted' vfile.txt > vline.txt"
					let lineNo = ''
					let lineDesc = ''
					let fun  = ''
					for line in readfile('vline.txt')
						let matches = matchlist(line,'^\v\s*line (\d+):\s*(.*)$')
						if  len(matches) > 2
							let lineNo = matches[1]
							let lineDesc = matches[2]
						endif
						let matches = matchlist(line,'^\v\s*function .*'. sFoo .'\.\.(.*) aborted')
						if len(matches) > 0
							let fun = matches[1]
						endif
					endfor
					call add(messages,printf('  %-20s offset %3d: %s',fun,lineNo,lineDesc))

					" Extract the line of test function:
					exec "silent !grep -A 2 'continuing in function.*". sFoo ."$' vfile.txt | grep line | tail -n 1 > vline.txt"
					let vline = readfile('vline.txt')
					if len(vline) > 0
						let lineno = vline[0]
						let matches = matchlist(lineno,'^\v\s*line (\d+):\s*(.*)$')
						if len(matches) > 2
							call add(messages,printf('  %-20s   line %3d: %s',sFoo,str2nr(matches[1])+fn,matches[2]))
						endif
					endif
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
			"call add(messages,"NOTE: Found function name: ".sFoo." Does not start with Test.So we will not run it automaticaly")
		endif
	endfor

	" final deletion of log files.
	exe "silent !rm -f vfile.txt"
	exe "silent !rm -f vline.txt"
	let g:vimUnitFailFast = oldFailFast

	call add(messages, "")
	call add(messages, "----------------------------------------------")
	" TODO add a differentiation between failed assertions and un expected
	" exceptions. simpletest does this:
	" Test cases run: 1/1, Passes: 0, Failures: 2, Exceptions: 0
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
	let sFoo = vimunit#util#ExtractFunctionName(vimunit#util#GetCurrentFunctionName())
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

" vim: set noet fdm=marker:
