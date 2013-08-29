" Normally za or zR will open the folds- zM will close them all.
" File header "{{{
" --------------------------------------------------------------
"  FILE:            vimUnit.vim
"  AUTHOR:          Staale Flock, Staale -- lexholm .. no + Dane Summers
"  VERSION:         1.0
"  LASTMODIFIED:    20 Dec 2012
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
""}}}
"Global variables {{{
" Define true and false 
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

"Variables
"	Variables Global
"	Global variables might be set in vimrc

if !exists('g:vimUnitVerbosity')
	"At the moment there is just 0 (quiet) and 1(verbose)
	let g:vimUnitVerbosity = 1
endif

if !exists('g:vimUnitFailFast')
	"Defaults to false (legacy behavior)
	let g:vimUnitFailFast = 0
endif

if !exists('g:vimUnitTestFilePattern')
	"What to setup :make support for:
	let g:vimUnitTestFilePattern = '*[Tt]est.vim'
endif

if !exists("g:vimUnitVimPath")
	let g:vimUnitVimPath = "vim"
endif

if has("autocmd")
	" Automatically determine where the vutest.sh script is based on the
	" location of this script:
	exe "autocmd BufNewFile,BufRead ". g:vimUnitTestFilePattern ." set makeprg=".
				\substitute(expand('<sfile>'),"\\v\\w+\/[^\/]+$","","")
				\.'vutest.sh\ -e\ '. g:vimUnitVimPath .'\ %'
	" This was helpful: http://stackoverflow.com/questions/1525377/vim-errorformat
	exe "autocmd BufNewFile,BufRead ". g:vimUnitTestFilePattern 
				\.' set errorformat=%PFile:\ %f,%.%#\|line\ %l\|%m,%-G%.%#,%Q'
endif

"}}}
" Script only support variables and functions"{{{

"function VUAutoRun 
" We have to make a check so we can AutoRun vimUnit.vim itself
if !exists('s:vimUnitAutoRun')
	let s:vimUnitAutoRun = 0
endif

if s:vimUnitAutoRun == 0
"	Variables Script
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

" convert an object to a string smartly
fun! s:str(str)
  if type(a:str) != 1
    return string(a:str)
  end
  return a:str
endf

function! s:MsgSink(caller,msg)
    " recording of the last failure
	let trace = split(expand("<sfile>"), '\.\.')
	let msg = [[ a:caller,a:msg, (len(trace) >= 3 ? trace[-3] : '') ]]
	if g:vimUnitVerbosity > 0
		let s:msgSink = s:msgSink + msg
		"echo a:caller.': '.a:msg
	endif
	if g:vimUnitFailFast
		throw string("VU " . msg[0][0] .": ". msg[0][1])
	endif
endfunction

"}}}
" VULog "{{{
" PURPOSE:
"	Log a message for a test.
" ARGUMENTS:
" 	msg :
" PURPOSE:
function! VULog(msg)
	call add(s:msgSink,"VULog: ". a:msg)
endfunction
" }}}
" VUAssertEquals"{{{
"	Compare arguments
" ARGUMENTS:
" 	arg1 : Argument to be tested.
" 	arg2 : Argument to test against.
"	  ...  : Optional message.
" RETURNS:
"	1 if arg1 == arg2
"	0 if arg1 != arg2
" ---------------------------------------------------------------------
function! VUAssertEquals(arg1, arg2, ...) "
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
		" TODO provide some 'verbose' option that prints out all the differences
		" between the objects.
		call s:MsgSink('AssertEquals', arg1text .'!='. arg2text . msg)
	endif
	let s:lastAssertionResult = bFoo
	return bFoo
endfunction"}}}
"	VUAssertTrue"{{{
" PURPOSE:
" 	Check that the passed argument validates to true
" ARGUMENTS:
" 	arg1: Should validate to TRUE() == (1==1)
" 	... : Optional message placeholder.
" RETURNS:
" 	TRUE() if true and
" 	FALSE() if false
" ---------------------------------------------------------------------
function! VUAssertTrue(arg1, ...) "
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == TRUE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call s:MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE()." MSG: ".a:1)
        else
            call s:MsgSink('VUAssertTrue','arg1='.a:arg1.'!='.TRUE())
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo
endfunction"}}}
" VUAssertFalse"{{{
" PURPOSE:
"	Test if the argument equals false
" ARGUMENTS:
"	arg1:	Contains something that will be evaluated to true or false
" 	... : Optional message placeholder.
" RETURNS:
"	0 if true
"	1 if false
" ---------------------------------------------------------------------
function! VUAssertFalse(arg1, ...) "
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == FALSE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
		if (exists('a:1'))
			call s:MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE()." MSG: ".a:1)
		else
			call s:MsgSink('AssertFalse','arg1='.a:arg1.'!='.FALSE())
		endif
	endif	
	let s:lastAssertionResult = bFoo
	return bFoo
endfunction
"}}}
" VUAssertNotNull"{{{
" VUAssert that the arg1 is initialized (is not null)
" Is this situation possible in vim script?
function! VUAssertNotNull(arg1, ...) "	
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
		call s:MsgSink('AssertNotNull','arg1: Does not exist')
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo		
endfunction
"}}}
" VUAssertNotSame"{{{
" VUAssert the the two variables dos not reference the same memory ?
" NOTE: Do not think we can control this in vim
function! VUAssertNotSame(arg1,arg2,...) "
	let s:testRunCount = s:testRunCount + 1
	"Could not do: if &a:arg1 != &a:arg2
	if a:arg1 != a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call s:MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2." MSG: ".a:1)
        else
            call s:MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo		
endfunction
"}}}
" VUAssertSame"{{{
"Assert that arg1 and arg2 reference the same memory
"NOTE: Don't know how to test this in vim
function! VUAssertSame(arg1, arg2, ...) "
	let s:testRunCount = s:testRunCount + 1
	"TODO: This does not ensure the same memory reference.
	if a:arg1 == a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (exists('a:1'))
            call s:MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2." MSG: ".a:1)
        else
            call s:MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo	
endfunction
"}}}
" VUAssertFail"{{{
" Fail a test with no arguments
function! VUAssertFail(...) "
	let s:testRunCount = s:testRunCount + 1	
	let s:testRunFailureCount = s:testRunFailureCount + 1
    if (exists('a:1'))
        call s:MsgSink('AssertFail','MSG: '.a:1)
    else
        call s:MsgSink('AssertFail','')
    endif
    let s:lastAssertionResult = FALSE()
	return FALSE()	
endfunction
"}}}
" Deprecated functions (non fail fast)"{{{
" ---------------------------------------------------------------------
" FUNCTION:	VUTraceMsg
" PURPOSE:
"	Add a debug message to the final testing report.
" ARGUMENTS:
" 	msg : The debug message
" ---------------------------------------------------------------------
function! VUTraceMsg(msg) 
    call s:MsgSink('', a:msg)
endfunction

" VURunner 
function! VURunnerRunTest(test) 
	try
		let did_vim_unit_vim = 1
		"exe "call ".sFoo.'()'
		call s:VURunnerInit()
		echo "Running: ".a:test
		call {a:test}()
		call VURunnerPrintStatistics('VUAutoRun:'.a:test)
	catch /.*/
		echo "Failed: ". a:test
		echo "Error: ". v:exception ." -- ". v:throwpoint
	endtry
endfunction
" ----------------------------------------- 
" FUNCTION:	VURunnerPrintStatistics"{{{
" PURPOSE:
"	Print statistics about test's
" ARGUMENTS:
"	None
" RETURNS:
"	String containing statistics
" -----------------------------------------
function! VURunnerPrintStatistics(caller,...) "
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
endfunction"}}}

function! s:VURunnerInit() "
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
" FUNCTION:	s:VURunnerStartSuite
" PURPOSE:
"	When we run a UnitTestSuite we do not want statistics to be corrupted by
"	the TestGroup.
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------
function! s:VURunnerStartSuite(caller) "
	call s:VURunnerInit()
	let s:suiteRunning = TRUE()
endfunction

" -----------------------------------------
" FUNCTION:	 s:VURunnerStopSuite
" PURPOSE:
"	
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------
function! s:VURunnerStopSuite(caller) "
	let s:suiteRunning = FALSE()
endfunction

" VURunnerExpectError
" PURPOSE:
"	Notify the runner that the next test is supposed to fail
" ARGUMENTS:
"	
" RETURNS:
"	
" -----------------------------------------

function! VURunnerExpectFailure(...) "
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
endfunction"}}}
"function VURunAllTests "{{{
" -----------------------------------------
" FUNCTION: VURunAllTests
" PURPOSE:  Runs all the tests in the current file.
"
" ARGUMENTS:
"   - optional test name. If set, then only tests matching this name will be
"   run. 
"
"   - optional boolean. If true, then this function will exit vim with an error
"   code. Suitable for scripting unit tests ala
"
"       vim -nc 'so %' <filename>
"
"   - optional output file. If set, then the output is saved to the output file
"   specified. Meant to be used with the former option set to true.
"
" RETURNS:
"
"   Echos the test results.
"
" -----------------------------------------
function! VURunAllTests(...)
	let testpattern = '.*'
	if exists('a:1')
		let testpattern = a:1
	endif
	let oldFailFast = g:vimUnitFailFast
	let g:vimUnitFailFast = 1
	let oldvfile = &verbosefile
	let oldverbose = &verbose

	"Locate function line on line with or above current line
	let messages = []
	let goodTests = 0
	let failedTests = 0
	let exceptTests = 0
	let goodAssertions = 0
	let failedAssertions = 0
	for fn in vimunit#util#GetCurrentFunctionLocations()
		let sFoo = vimunit#util#ExtractFunctionName(getline(fn))
		if match(sFoo,'^Test') > -1 && match(sFoo,testpattern) > -1
			if exists( '*'.sFoo)
				try
					call s:VURunnerInit()
					" TODO Make the verbose file a temp file.
					" Get the line number of this particular function
					" then grep the verbose file for the offset.
					exe "silent !rm -f vfile.txt"
					set verbosefile=vfile.txt
					set verbose=20
					call {sFoo}()
					let goodTests = goodTests + 1
				catch /.*/
					let failtype = 'Failure'
					if v:exception =~ 'VU'
						let failedTests = failedTests + 1
					else
						let exceptTests = exceptTests + 1
						let failtype = 'Exception'
					endif

					exec "set verbose=".oldverbose
					exec "set verbosefile=".oldvfile
					" for debugging an error, save the output for later use...
					exec "silent !cp vfile.txt verr-". sFoo .".txt"

					call add(messages,"\n")
					call add(messages, join(s:msgSink, " "))
					call add(messages,printf("[1;31m%s[0m| [1m%s[0m (assertions %d)| %s",failtype,sFoo,s:testRunSuccessCount,v:exception))

					" TODO this parsing of the verbose file is very hacky. We need an
					" actual solution that:
					" - notes the function enter/exit messages:
					"   - calling function
					"   - continuing in function
					"   - function.* aborted
					" By parsing this better we could reliably get the line number in the
					" test case...which at the moment sometimes does happen, and sometimes
					" doesn't.

					" Extract the line where the test failed (if there was an exception)
					let verbosefile = vimunit#util#parseVerboseFile('vfile.txt')
					call writefile([string(verbosefile)],'out'. sFoo .'.txt')
					let stacktrace = []
					let lineNo = verbosefile[sFoo]['offset'] + fn
					let lineDesc = verbosefile[sFoo]['detail']
					call add(stacktrace,printf('  %s|[1mline %3d[0m|%s',sFoo,lineNo,lineDesc))
					let curFunction = sFoo

					" The vimunit#util#parseVerboseFile function does not handly
					" recursive calls to the same function correctly. To prevent any
					" potential errors from that...cap the recursion:
					let recurses = 0
					while has_key(verbosefile[curFunction],'child') && recurses < 10
						let curFunction = verbosefile[curFunction]['child']
						let recurses = recurses + 1
						" TODO find the file that the function is in, and then compute the
						" line number of the function definition.
						if !has_key(verbosefile,curFunction) || !has_key(verbosefile[curFunction],'offset')
							break
						endif
						let lineNo = verbosefile[curFunction]['offset']
						let lineDesc = verbosefile[curFunction]['detail']
						call add(stacktrace,printf('  %s|[1moffset %d[0m|%s',curFunction,lineNo,lineDesc))
					endwhile

					call extend(messages,reverse(stacktrace))
				finally
					exec "set verbose=".oldverbose
					exec "set verbosefile=".oldvfile
					let goodAssertions = goodAssertions + s:testRunSuccessCount
					let failedAssertions = failedAssertions + s:testRunFailureCount
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

	call insert(messages, "File: ". expand('%'))
	call add(messages, "")
	call add(messages, "----------------------------------------------")
	call add(messages, printf("Passed: %d (%d assertions) Failed: %d, Exceptions: %d",goodTests,goodAssertions,failedTests,exceptTests))
	" write to a file?
	if exists('a:3')
		" check for carriage returns first.
		" TODO something is causing this this to write VULog entries twice
		let forwrite = []
		for m in messages
			call extend(forwrite,split(m,'\\n'))
		endfor
		call writefile(forwrite,a:3)
	else
		for line in messages
			echo line
		endfor
	endif
	if exists('a:2') && a:2
		if failedTests > 0
			cquit
		else
			quit
		endif
	endif
endfunction"}}}
function! VUAutoRun() "{{{
	"NOTE:If you change this code you must manualy source the file!

	let s:vimUnitAutoRun = 1
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
endfunction
endif"}}}
" vim: set noet fdm=marker:
