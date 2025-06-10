if exists('g:loaded_xbuild')
	finish
endif

let s:project = xbuild#core#FindProjectRoot() 
if empty(s:project)
	finish
endif

let g:loaded_xbuild = 1
call system('mkdir -p ' . shellescape(xbuild#core#CachePath()))

" Current project
let g:xbuild_project = s:project

" Current destination for xcodebuild
let g:xbuild_destination = {}

" Current scheme
let g:xbuild_scheme = ''

command! XDestination call xbuild#destination#Pick()
command! XScheme call xbuild#scheme#Pick()
command! XBuild call xbuild#build#Run()
command! XTest call xbuild#test#Run()
command! XTestWithoutBuilding call xbuild#test#RunWithoutBuilding()
command! XRun call xbuild#run#BuildAndRun()
command! XRunWithoutBuilding call xbuild#run#Run()

autocmd VimEnter * call xbuild#state#Load()
autocmd VimLeavePre * call xbuild#state#Save()

