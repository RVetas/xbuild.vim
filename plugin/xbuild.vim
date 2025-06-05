if exists('g:loaded_xbuild')
	finish
endif

if empty(xbuild#core#FindProjectRoot())
	finish
endif

let g:loaded_xbuild = 1

" Current destination for xcodebuild
let g:xbuild_destination = ''

" Current scheme
let g:xbuild_scheme = ''

" This command allows to choose destination
command! XDestination call xbuild#destination#Pick()
command! XScheme call xbuild#scheme#Pick()
command! XWorkspace call xbuild#core#FindProjectRoot()
command! XBuild call xbuild#build#Run()
command! XTest call xbuild#test#Run()
command! XTestWithoutBuilding call xbuild#test#RunWithoutBuilding()
command! XBuildAndRun call xbuild#run#BuildAndRun()
command! XRun call xbuild#run#Run()

autocmd VimEnter * call xbuild#state#Load()
autocmd VimLeavePre * call xbuild#state#Save()

