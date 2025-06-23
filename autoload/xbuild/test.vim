function! xbuild#test#Run() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	let l:cmd = xbuild#command#Xcodebuild('test', xbuild#command#DefaultOptions())
	call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction

function! xbuild#test#RunWithoutBuilding() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	let l:cmd = xbuild#command#Xcodebuild('test-without-building', xbuild#command#DefaultOptions())
	call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction
