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
function! TODO(funcName)	"{{{2
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
function! VUAssertEquals(arg1, arg2, ...)	"{{{2
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
        if (len(a:000) == 3)
            call <SID>MsgSink('AssertEquals','arg1='. arg1text .'!='. arg2text ." MSG: ". a:3)
        else
            call <SID>MsgSink('AssertEquals','arg1='. arg1text .'!='. arg2text)
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
function! VUAssertTrue(arg1, ...)	"{{{2
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == TRUE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (len(a:000) == 2)
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
function! VUAssertFalse(arg1, ...)	"{{{2
	let s:testRunCount = s:testRunCount + 1
	if a:arg1 == FALSE()
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (len(a:000) == 2)
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
function! VUAssertNotNull(arg1, ...)	"{{{2	
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
function! VUAssertNotSame(arg1,arg2,...)	"{{{2
	let s:testRunCount = s:testRunCount + 1
	"Could not do: if &a:arg1 != &a:arg2
	if a:arg1 != a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (len(a:000) == 3)
            call <SID>MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2." MSG: ".a:3)
        else
            call <SID>MsgSink('AssertNotSame','arg1='.a:arg1.' == arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo		
endfunction

"Assert that arg1 and arg2 reference the same memory
"NOTE: Don't know how to test this in vim
function! VUAssertSame(arg1, arg2, ...)	"{{{2
	let s:testRunCount = s:testRunCount + 1
	"TODO: This does not ensure the same memory reference.
	if a:arg1 == a:arg2
		let s:testRunSuccessCount = s:testRunSuccessCount + 1
		let bFoo = TRUE()
	else
		let s:testRunFailureCount = s:testRunFailureCount + 1
		let bFoo = FALSE()
        if (len(a:000) == 3)
            call <SID>MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2." MSG: ".a:3)
        else
            call <SID>MsgSink('AssertSame','arg1='.a:arg1.' != arg2='.a:arg2)
        endif
	endif	
    let s:lastAssertionResult = bFoo
	return bFoo	
endfunction

"Fail a test with no arguments
function! VUAssertFail(...)	"{{{2
	let s:testRunCount = s:testRunCount + 1	
	let s:testRunFailureCount = s:testRunFailureCount + 1
    if (len(a:000) == 1)
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
		"exe "call ".sFoo.'()'
		call VURunnerInit()
		echo "Running: ".a:test
		call {a:test}()
		call VURunnerPrintStatistics('VUAutoRun:'.a:test)	
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

function! VURunnerInit()	"{{{2
	if exists('s:suiteRunning') && s:suiteRunning == FALSE()
		echomsg "CLEARING: statistics"
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
function! VURunnerStartSuite(caller)	"{{{2
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

function! VURunnerExpectFailure(...)  "{{{2
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

function! <sid>MsgSink(caller,msg)  "{{{2
    " recording of the last failure
    " TODO change this so that it records the last test, and whether if failed
    " or not.
	if g:vimUnitVerbosity > 0
        let trace = split(expand("<sfile>"), '\.\.')
        let s:msgSink = s:msgSink + [[ a:caller,a:msg, (len(trace) >= 3 ? trace[-3] : '') ]]
		"echo a:caller.': '.a:msg
	endif
endfunction

"staale - GetCurrentFunctionName()
"Extract the function name the cursor is inside
function! <SID>GetCurrentFunctionName()		"{{{2
	"call s:FindBlock('\s*fu\%[nction]\>!\=\s.*(\%([^)]*)\|\%(\n\s*\\[^)]*\)*\n)\)', '', '', '^\s*endf\%[unction]', 0)
	"bWn ==> b=Search backward, W=Don't wrap around end of file,n=Do not move cursor.
	let nTop = searchpair('^\s*fu\%[nction]\%[!]\ .*','','^\s*endf\%[unction].*','bWn')
	let sLine = getline(nTop)
	return sLine
endfunction

function! <SID>ExtractFunctionName(strLine)		"{{{2
" This used to be part of the GetCurrentFunctionName() routine
" But to make as much as possible of the code testable we have to isolate code
" that do any kind of buffer or window interaction.
	let lStart = matchend(a:strLine,'\s*fu\%[nction]\%[!]\s')
	let sFoo = matchstr(a:strLine,".*(",lStart)
	let sFuncName =strpart(sFoo ,0,strlen(sFoo)-1)
	return sFuncName
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
function! TestVUAssertEquals()  "{{{2
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

function! TestVUAssertTrue()  "{{{2
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

function! TestVUAssertFalse()  "{{{2
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
function! TestVUAssertNotNull()  "{{{2
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

function! TestVUAssertNotSame()  "{{{2
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

function! TestVUAssertSame()  "{{{2
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

function! TestVUAssertFail()  "{{{2
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

function! TestSuiteVimUnitSelfTest()  "{{{1
	let sSelf = 'TestSuiteVimUnitSelfTest'
	call TestVUAssertEquals()
	call TestVUAssertTrue()
	call TestVUAssertNotNull()
	call TestVUAssertNotSame()
	call TestVUAssertSame()
	call TestVUAssertFail()
	call TestExtractFunctionName()
endfunction

" Help (Documentation) installation {{{1
"
" InstallDocumentation {{{2
" ---------------------------------------------------------------------
" Function: <SID>InstallDocumentation(full_name, revision)   
"   Install help documentation.
" Arguments:
"   full_name: Full name of this vim pluggin script, including path name.
"   revision:  Revision of the vim script. #version# mark in the document file
"              will be replaced with this string with 'v' prefix.
" Return:
"   1 if new document installed, 0 otherwise.
" Note: Cleaned and generalized by guo-peng Wen
" 
" Source: vimspell.vim s:SpellInstallDocumentation 
"         http://www.vim.org/scripts/script.php?script_id=465  
" ---------------------------------------------------------------------
function! <SID>InstallDocumentation(full_name, revision)
    " Name of the document path based on the system we use:
    if (has("unix"))
        " On UNIX like system, using forward slash:
        let l:slash_char = '/'
        let l:mkdir_cmd  = ':silent !mkdir -p '
    else
        " On M$ system, use backslash. Also mkdir syntax is different.
        " This should only work on W2K and up.
        let l:slash_char = '\'
        let l:mkdir_cmd  = ':silent !mkdir '
    endif

    let l:doc_path = l:slash_char . 'doc'
    let l:doc_home = l:slash_char . '.vim' . l:slash_char . 'doc'

    " Figure out document path based on full name of this script:
    let l:vim_plugin_path = fnamemodify(a:full_name, ':h')
    let l:vim_doc_path    = fnamemodify(a:full_name, ':h:h') . l:doc_path
    if (!(filewritable(l:vim_doc_path) == 2))
        echomsg "Doc path: " . l:vim_doc_path
        execute l:mkdir_cmd . l:vim_doc_path
        if (!(filewritable(l:vim_doc_path) == 2))
            " Try a default configuration in user home:
            let l:vim_doc_path = expand("~") . l:doc_home
            if (!(filewritable(l:vim_doc_path) == 2))
                execute l:mkdir_cmd . l:vim_doc_path
                if (!(filewritable(l:vim_doc_path) == 2))
                    " Put a warning:
                    echomsg "Unable to open documentation directory"
                    echomsg " type :help add-local-help for more informations."
                    return 0
                endif
            endif
        endif
    endif

    " Exit if we have problem to access the document directory:
    if (!isdirectory(l:vim_plugin_path)
        \ || !isdirectory(l:vim_doc_path)
        \ || filewritable(l:vim_doc_path) != 2)
        return 0
    endif

    " Full name of script and documentation file:
    let l:script_name = fnamemodify(a:full_name, ':t')
    let l:doc_name    = fnamemodify(a:full_name, ':t:r') . '.txt'
    let l:plugin_file = l:vim_plugin_path . l:slash_char . l:script_name
    let l:doc_file    = l:vim_doc_path    . l:slash_char . l:doc_name

    " Bail out if document file is still up to date:
    if (filereadable(l:doc_file)  &&
        \ getftime(l:plugin_file) < getftime(l:doc_file))
        return 0
    endif

    " Prepare window position restoring command:
    if (strlen(@%))
        let l:go_back = 'b ' . bufnr("%")
    else
        let l:go_back = 'enew!'
    endif

    " Create a new buffer & read in the pluggin file (me):
    setl nomodeline
    exe 'enew!'
    exe 'r ' . l:plugin_file

    setl modeline
    let l:buf = bufnr("%")
    setl noswapfile modifiable

    norm zR
    norm gg

    " Delete from first line to a line starts with
    " === START_DOC
    1,/^=\{3,}\s\+START_DOC\C/ d

    " Delete from a line starts with
    " === END_DOC
    " to the end of the documents:
    /^=\{3,}\s\+END_DOC\C/,$ d

    " Remove fold marks:
    % s/{\{3}[1-9]/    /

    " Add modeline for help doc: the modeline string is mangled intentionally
    " to avoid it be recognized by VIM:
    call append(line('$'), '')
    call append(line('$'), ' v' . 'im:tw=78:ts=8:ft=help:norl:')

    " Replace revision:
    exe "normal :1s/#version#/ v" . a:revision . "/\<CR>"

    " Save the help document:
    exe 'w! ' . l:doc_file
    exe l:go_back
    exe 'bw ' . l:buf

    " Build help tags:
    exe 'helptags ' . l:vim_doc_path

    return 1
endfunction

" Automatically install documentation when script runs {{{2
" This code will check file (self) and install/update documentation included
" at the bottom.
" SOURCE: vimspell.vim, function! <SID>InstallDocumentation
  let s:revision=
	\ substitute("$Revision: 0.1 $",'\$\S*: \([.0-9]\+\) \$','\1','')
  silent! let s:help_install_status =
      \ <SID>InstallDocumentation(expand('<sfile>:p'), s:revision)
  if (s:help_install_status == 1) 
	  call VURunnerRunTest('TestSuiteVimUnitSelfTest')
      echom expand("<sfile>:t:r") . ' v' . s:revision .
		\ ': Help-documentation installed.'
  endif

	if (g:vimUnitSelfTest == 1)
	  call VURunnerRunTest('TestSuiteVimUnitSelfTest')
	endif	

" Stop sourceing this file, no code after this.
finish

" Documentation {{{1
" Help header {{{2
=== START_DOC
*vimUnit.txt*    A template to create vim and winmanager managed plugins. #version#


	vimUnit. A unit-testing framework targeting vim-scripts

==============================================================================
CONTENT  {{{2                                                *vimUnit-contents*
                                                                 *unit-testing* 
	Installation        : |vimUnit-installation|                  *unittesting* 
	Configuration       : |vimUnit-configuration|
	vimUnit intro       : |vimUnit|
	Requirements        : |vimUnit-requirements|
	vimUnit commands    : |vimUnit-commands|
	Bugs                : |vimUnit-bugs|
	Tips                : |vimUnit-tips|
	Todo list           : |vimUnit-todo|
	Change log          : |vimUnit-cahnge-log|

==============================================================================
1. vimUnit Installation {{{2                            *vimUnit-installation*

	TODO: Write documentation, Installation
	
	Copy the file vimUnit.vim to your ftplugin directory. That would normaly 
	be ~/.vim/ftplugin/ on *nix and $VIM/vimfiles/ftplugin/ on MS-Windows.

	The next time you start vim (or gvim) after you have installed the plugin 
	this documentation si suposed to automaticaly be installed.
	
==============================================================================
1.1 vimUnit Configuration {{{2                         *vimUnit-configuration*
															|vimUnit-content|
															
															*vimUnit-AutoRun*
															      *VUAutoRun*
	To ease testing of scripts there is a AutoRun (VUAutoRun()) routine. When 
	called from the commandline or a mapping of your preference it takes the 
	curser position in the file and figure out if your inside a function 
	starting with 'Test'. If you are the file your in will be saved and sourced.
	Then the function will be called, and you get a printout of the statistics.
	So placing the cursor on call (in a vim file) inside the function:
	
		function! TestThis()
			call VUAssertTrue(TRUE(),'Simple test of true')	
		endfunction
		
	And calling:
		:call VUAutoRun()
		
	Will give you the statistics.

	
                                                           *vimUnit-verbosity*
	When we are running test cases to much output could be annoying. turn msg 
	output off in your vimrc file with:
		let g:vimUnitVerbosity = 0
	Default value is 1.
                                                            *vimUnit-selftest*
	vimUnit has code to test that it work as expected. This code will run the 
	first time vim is running after you installed vimUnit. After that it will 
	only run again if there is changes to the vimUnit.vim file. If you want 
	vimUnit to do a self-test every time it is loaded (sourced) you should add
	this line to your vimrc file:
		let g:vimUnitSelfTest = 1

==============================================================================
1.1 vimUnit Requirements {{{2                           *vimUnit-requirements*
															|vimUnit-content|
	TODO: Write documentation, Requirements
	
	Just a working vim environment
	
==============================================================================
2. vimUnit Intro {{{2                                 *VU* *VimUnit* *vimUnit*
															|vimUnit-content|
	TODO: Write documentation, Intro
	
	The phillosophy behind test-first driven development is simple. 
	When you consider to write some code, you normaly have an idea of what you
	want the code to do. So, instead of just thinking of what your code should 
	do try to write down a test case formalising your thoughts. When you have 
	a test case you start writing the code to make the test case complete 
	successfully. If your work discover problem areas, error conditions or
	suche write a test to make shure your code handels it. And will continue 
	to handel it the next time you make some changes. Writing code, also test
	code, is hard (but fun) work.
	Ex:
		"First we have an ide of how our function Cube should work
		func! TestCaseCube()
			call VUAssertEquals(<SID>Cube(1),1,'Trying to cube 1)')
			call VUAssertEquals(<SID>Cube(2),2*2*2,'Trying to cube 2)')
			call VUAssertEquals(<SID>Cube(3),3*3*3,'Trying to cube 3)')
			"Take a look at the statistics
			call VURunnerPrintStatistics()
		endfunc
		"We write ouer Cube Function
		func! <SID>Cube(arg1)
			let nFoo = arg1*arg1*arg1
			return nFoo
		endfunc
		
		"Enter commands to run the test
		"Source the current file (in current window)
		:so %
		"call the TestCase
		:call TestCaseCube()

	That's it If we get errors we must investigate. We should make test's 
	discovering how our function handels obvious error conditions. How about
	adding this line to our TestCase:
		call VUAssertEquals(<SID>Cube('tre'),3*3*3,'Trying to pass a string')
		
	Do we get a nice error message or does our script grind to a halt?
	Should we add a test in Cube that ensure valide arguments?
		if type(arg1) == 0
			...
		else
			echomsg "ERROR: You passed a string to the Cube function."
		endif
		
	After some itterations and test writings we should feel confident that our
	Cube function works like expected, and will continue to do so even if we 
	make changes to it.

==============================================================================
3. vimUnit Commands {{{2                                    *vimUnit-commands*
															|vimUnit-content|
	TODO: Write documentation, Commands
	
	When you se ... at the end of the argument list you may optionaly provide 
	a message string.
	
	VUAssertEquals(ar1, arg2, ...)
		VUAssert that arg1 is euqal in content to arg2.
	VUAssertTrue(arg1, ...)
		VUAssert that arg1 is true.
	VUAssertFalse(arg1, ...)
		VUAssert that arg1 is false.
	VUAssertNotNull(arg1, ...)
		VUAssert that arg1 is initiated.
	VUAssertNotSame(arg1, arg2, ...)
		VUAssert that arg1 and arg2 reference diffrent memory.
	VUAssertSame(arg1, arg2, ...)
		VUAssert that arg1 and arg2 are from the same memory.
	VUAssertFail(...)
		Log a userdefined failure.
		


	VURunnerInit()
		TODO:
	VURunnerStartSuite(caller)
		TODO:
	VURunnerStopSuite(caller)
		TODO:
==============================================================================
4. vimUnit Bugs {{{2                                            *vimUnit-bugs*
															|vimUnit-content|
	TODO: Write documentation, Bugs
	
	Bugs, what bugs..;o)
	
==============================================================================
5. vimUnit Tips {{{2                                            *vimUnit-tips*
															|vimUnit-content|
	TODO: Write documentation, Tips
	
==============================================================================
6. vimUnit Todo list {{{2                                       *vimUnit-todo*   
															|vimUnit-content|
	TODO: Write more documentation
	TODO: Cleanup function header comments	

	TODO: TestResult methodes are not implemented 		{{{3
		TestResultAddError(test, ...)
		TestResultAddFailure(test, ...)
		TestResultAddListener(listener, ...)
		TestResultCloneListener()
		TestResultErrorCount()
		TestResultErrors()
		TestResultFailureCount()
		TestResultFailures()
		TestResultRemoveListener(listener, ...)
		TestResultRun(testCase, ...)
		TestResultRunCount()
		TestResultShouldStop()
		TestResultStartTest(test)
		TestResultStop()
		TestResultWasSuccessful()
		}}}
==============================================================================
7. vimUnit Change log  {{{2                               *vimUnit-change-log*
															|vimUnit-content|
Developer reference: (breake up mail address)
---------------------------------------------
SF = Staale Flock, staale -- lexholm .. no

------------------------------------------------------------------------------
By	Date		Description, if version nr changes place it first.
------------------------------------------------------------------------------
SF	8 Nov 2004	0.1	Initial uppload
==============================================================================
" Need the next formating line inside the help document
" vim: ts=4 sw=4 tw=78: 
=== END_DOC
" vim: ts=4 sw=4 tw=78 foldmethod=marker
