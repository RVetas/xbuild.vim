function! xbuild#test#Run() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	let l:cmd = 'xcodebuild ' . g:xbuild_project .
	  \ ' -scheme ' . shellescape(g:xbuild_scheme) .
	  \ ' -destination id=' . shellescape(l:destination_id) .
	  \ ' test'

	if executable('xcpretty')
		let l:cmd .= ' | xcpretty'
	endif

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

	let l:cmd = 'xcodebuild ' . g:xbuild_project .
	  \ ' -scheme ' . shellescape(g:xbuild_scheme) .
	  \ ' -destination id=' . shellescape(l:destination_id) .
	  \ ' test-without-building'

	if executable('xcpretty')
		let l:cmd .= ' | xcpretty'
	endif

	call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction
