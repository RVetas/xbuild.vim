function! xbuild#build#Run() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	let cmd = xbuild#command#Xcodebuild("build", xbuild#command#DefaultOptions())
	call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction

