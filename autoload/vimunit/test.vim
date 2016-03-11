" SelfTest VUAssert 
function! TestVUAssertEquals() 
	let sSelf = 'TestVUAssertEquals'
	call VUAssertEquals(1,1)
	try
		call VUAssertEquals(1,2)
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	call VUAssertEquals('str1','str1','Simple test comparing two strings')
	call VUAssertEquals('str1',"str1",'Simple test comparing two strings')
	try
		call VUAssertEquals('str1','str2','Simple test comparing two diffrent strings,expect failure')	
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	try
    call VUAssertEquals(123,'123','Simple test comparing number and string containing number')
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	try
		call VUAssertEquals(123,'321','Simple test comparing number and string containing diffrent number,expect failure')
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	
	let arg1 = 1
	let arg2 = 1
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing the same number')
	let arg2 = 2
	try
		call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing diffrent numbers,expect failure')
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	let arg1 = "test1"
	let arg2 = "test1"
	call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing equal strings')
	let arg2 = "test2"
	try
		call VUAssertEquals(arg1,arg2,'Simple test comparing two variables containing diffrent strings,expect failure')
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	call VUAssertEquals([],[])
	try
		call VUAssertEquals([1],[])
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	try
		call VUAssertEquals([],[1])
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	try
		call VUAssertEquals([],[[1]])
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	try
		call VUAssertEquals([[1]],[])
		call VUAssertFail()
	catch /AssertEquals/
	endtry

	call VUAssertEquals({},{})
	try
		call VUAssertEquals({1:1},{})
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	call VUAssertEquals({1:{}},{1:{}})
	try
		call VUAssertEquals({1:{2:2}},{1:{}})
		call VUAssertFail()
	catch /AssertEquals/
	endtry
	call VUAssertEquals({'1':{'count':1, 'pluginCount':1, 'text':'..', 'hi':'testhi', 'plugins':['Test2'], 'line':1}},{'1':{'count':1, 'pluginCount':1, 'text':'..', 'hi':'testhi', 'plugins':['Test2'], 'line':1}})
endfunction

function! TestVUAssertTrue() 
	let sSelf = 'TestVUAssertTrue'
	call VUAssertTrue(TRUE())
	try
		call VUAssertTrue(FALSE())
		call VUAssertFail()
	catch /AssertTrue/
	endtry

	call VUAssertTrue(1,'Simple test passing 1')
	try
		call VUAssertTrue(0, 'Simple test passing 0,expect failure')	
		call VUAssertFail()
	catch /AssertTrue/
	endtry

	let arg1 = 1
	call VUAssertTrue(arg1,'Simple test arg1 = 1')
	let arg1 = 0
	try
		call VUAssertTrue(arg1, 'Simple test passing arg1=0,expect failure')		
		call VUAssertFail()
	catch /AssertTrue/
	endtry

	
	try
		call VUAssertTrue("test",'Simple test passing string')
		call VUAssertFail()
	catch /AssertTrue/
	endtry
	try
		call VUAssertTrue("", 'Simple test passing empty string,expect failure')	
		call VUAssertFail()
	catch /AssertTrue/
	endtry

	let arg1 = 'test'
	try
		call VUAssertTrue(arg1,'Simple test passing arg1 = test')
		call VUAssertFail()
	catch /AssertTrue/
	endtry
	try
		call VUAssertTrue(arg1, 'Simple test passing arg1="",expect failure')	
		call VUAssertFail()
	catch /AssertTrue/
	endtry
endfunction

function! TestVUAssertFalse() 
	let sSelf = 'TestVUAssertFalse'
	call VUAssertFalse(FALSE())
	try
		call VUAssertFalse(TRUE())
		call VUAssertFail()
	catch /AssertFalse/
	endtry

	call VUAssertFalse(0,'Simple test passing 0')
	try
		call VUAssertFalse(1, 'Simple test passing 1,expect failure')	
		call VUAssertFail()
	catch /AssertFalse/
	endtry

	let arg1 = 0
	call VUAssertFalse(arg1,'Simple test arg1 = 0')
	let arg1 = 1
	try
		call VUAssertFalse(arg1, 'Simple test passing arg1=1,expect failure')		
		call VUAssertFail()
	catch /AssertFalse/
	endtry

	call VUAssertFalse("test",'Simple test passing string')
	call VUAssertFalse("", 'Simple test passing empty string,expect failure')
	let arg1 = 'test'
	call VUAssertFalse(arg1,'Simple test passing arg1 = test')
	call VUAssertFalse(arg1, 'Simple test passing arg1="",expect failure')
endfunction
function! TestVUAssertNotNull() 
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
	catch /E121/
		" actual vim error. Nothing we can do about that.
	endtry
	
	try
		call VUAssertNotNull(sTest2,'Trying to pass a uninitated variable sTest2')	
	catch /E121/
		" actual vim error. Nothing we can do about that.
	endtry
	
endfunction

function! TestVUAssertNotSame() 
	" VUAssert the two arguments does not reference the same memory
	" NOTE: I do not know how to test this in vim.
	" TODO: Write more relevant test's
	let sSelf = 'TestVUAssertNotSame'
	let arg1 = 'test'
	let arg2 = 'test2'
	call VUAssertNotSame(arg1,arg2,'Check to se if arg1 and arg2 reference the same memory')
	call VUAssertNotSame(arg1,arg2)
	let arg2 = arg1
	try
		call VUAssertNotSame(arg1,arg2,'arg1 = arg2 reference the same memory, expected to fail')
		call VUAssertFail()
	catch /AssertNotSame/
	endtry
endfunction

function! TestVUAssertSame() 
	" VUAssert the two arguments does reference the same memory
	" NOTE: I do not know how to test this in vim.
	" TODO: Write more relevant test's
	let sSelf = 'TestVUAssertSame'
	let arg1 = 'test'
	let arg2 = arg1
	call VUAssertSame(arg1,arg2,'Verify that arg1 and arg2 reference the same memory')
	call VUAssertSame(arg1,arg2)
	let arg2 = 'test2'
	try
		call VUAssertSame(arg1,arg2,'arg1=test != arg2=test2: Does not reference the same memory, expected to fail')	
		call VUAssertFail()
	catch /AssertSame/
	endtry
endfunction

function! TestVUAssertFail() 
	let sSelf = 'testAssertFail'
	try
		call VUAssertFail('Expected failure')
	catch /AssertFail/
	endtry
	try
		call VUAssertFail()
	catch /AssertFail/
	endtry
endfunction


function! TestExtractFunctionName() 
	let sSelf = 'TestExtractFunctionName'
	"Testing legal function declarations
	"NOTE: The markers in the test creates a bit of cunfusion
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('func TestFunction()'),'straight function declaration')
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('func! TestFunction()'),'func with !')
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName(' func TestFunction()'),'space before func')
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('		func TestFunction()'),'Two embeded tabs before func') "Two embeded tabs
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('func TestFunction()	'),'Declaration with folding marker in comment' )
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('   func TestFunction()	'),'Declaration starting with space and ending with commented folding marker')
	let sFoo = VUAssertEquals('TestFunction',vimunit#util#ExtractFunctionName('func TestFunction(arg1, funcarg1, ..)'),'arguments contain func')
endfunction	

fun TestSubStr()
  call VUAssertEquals(vimunit#util#substr('',0,'A'),'')
  call VUAssertEquals(vimunit#util#substr('',5,'A'),'')
  call VUAssertEquals(vimunit#util#substr('',5,'A'),'')
  call VUAssertEquals(vimunit#util#substr('a',0,'A'),'A')
  call VUAssertEquals(vimunit#util#substr('a',1,'A'),'a')
  call VUAssertEquals(vimunit#util#substr('aa',1,'A'),'aA')
  call VUAssertEquals(vimunit#util#substr([1,2,3],1,'A'),'[A')
endf

fun TestDiff()
  call VUAssertEquals(vimunit#util#diff('',''),[])
  call VUAssertEquals(vimunit#util#diff(3,''),['Number(3) != String()'])
  call VUAssertEquals(vimunit#util#diff([],[]),[])
  call VUAssertEquals(vimunit#util#diff([3],[]),['len([3])(1) != len([])(0)'])
  call VUAssertEquals(vimunit#util#diff({},{}),[])
  call VUAssertEquals(vimunit#util#diff({3: 1},{3: 1}),[])
  call VUAssertEquals(vimunit#util#diff({3: 1},{3: 2}),['Different values for key "3"',['1 != 2']])
  call VUAssertEquals(vimunit#util#diff({3: 1, 1:2},{3: 2}),
        \[ 'Only in first dictionary: {1: 2}', 'Different values for key "3"',['1 != 2']])
	let a = {'1': { 'plugins': [{ 'fg': '000000', 'plugins': ['mvom#test#test1plugin'], 'text': 'XX'}], 'text': 'XX', 'visible': 1}}
	let b = {'1': { 'plugins': [{ 'fg': '000000', 'plugin': 'mvom#test#test1plugin', 'text': 'XX'}], 'text': 'XX', 'visible': 1}}
	call VULog(string(vimunit#util#diff(a,b)))
	call VUAssertEquals(vimunit#util#diff(a,b),
				\['Different values for key "1"', ['Different values for key "plugins"', ['Different values for index 0', ['Only in first dictionary: {plugins: [''mvom#test#test1plugin'']}', 'Only in second dictionary: {plugin: mvom#test#test1plugin}']]]])
endf

fun TestParseVerboseFile()

	"" recursive call to diff function called twice
	"let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestLoop.txt')
	"call VULog(string(lines))
	"call VUAssertEquals(lines['TestDoPaintMatches']['status'],'aborted')
	"call VUAssertEquals(lines['TestDoPaintMatches']['offset'], 10)
	"call VUAssertEquals(lines['TestDoPaintMatches']['child'],'vimunit#util#diff')
	"call VUAssertEquals(lines['_count_vimunit#util#diff'],2)
	"call VUAssertTrue(has_key(lines,'vimunit#util#diff(2)'))

	"let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestConvertToModuloOffset.txt-noline')
	"call VUAssertEquals(lines['TestConvertToModuloOffset']['offset'],1)
	"call VUAssertEquals(lines['TestConvertToModuloOffset']['detail'],'  call VUAssertEquals(mvom#util#location#ConvertToModuloOffset(1,1,2,2),0)')
	"call VUAssertEquals(lines['TestConvertToModuloOffset']['status'],'aborted')
	"call VUAssertEquals(lines['TestConvertToModuloOffset']['child'],'VUAssertEquals')

	"call VUAssertEquals(lines['<SNR>31_MsgSink']['status'],'aborted')
	"call VUAssertEquals(lines['<SNR>31_MsgSink']['offset'],9)
	"call VUAssertTrue(!has_key(lines['<SNR>31_MsgSink'],'child'))
	"" TODO returned vs aborted

	"" test another scenario not working in the new implementation
	"let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestGetCurrentFunctionNames.txt')
	"call VUAssertEquals(lines['TestGetCurrentFunctionNames']['offset'],1)
	"call VUAssertEquals(lines['TestGetCurrentFunctionNames']['detail'],'^Ilet sFoo = VUAssertEquals(vimunit#util#GetCurrentFunctionLocations(),[270, 260, 256, 243, 230, 213, 196, 169, 138, 88, 2])')
	"call VUAssertEquals(lines['TestGetCurrentFunctionNames']['status'],'aborted')
	"call VUAssertEquals(lines['TestGetCurrentFunctionNames']['child'],'VUAssertEquals')

	"call VUAssertEquals(lines['vimunit#util#searchallpair']['status'],'returned')

	"let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestCombineData.txt')
	"call VULog(string(lines))
	"call VUAssertEquals(lines['mvom#renderer#CombineData']['status'],'aborted')
	"call VUAssertEquals(lines['mvom#renderer#CombineData']['offset'], 46)

	"" test yet another scenario that doesn't work.
	"let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestSearchInWindow.txt')
	"call VUAssertEquals(lines['TestSearchInWindow']['offset'],28)

	" test yet another scenario that doesn't work.
	" let lines = vimunit#util#parseVerboseFile('autoload/vimunit/verr-TestSearchInWindow2.txt')
	" call VUAssertEquals(lines['TestSearchInWindow']['offset'],41)
endf

function! TestGetCurrentFunctionNames() 
	let sFoo = VUAssertEquals(vimunit#util#GetCurrentFunctionLocations(),[328, 283, 266, 256, 243, 230, 213, 196, 169, 138, 88, 2])
endfunction	

" vim: set noet fdm=marker:
