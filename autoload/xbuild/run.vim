function! xbuild#run#BuildAndRun() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	" Установить и запустить
	let l:build_cmd = 'xcodebuild ' . g:xbuild_project .
		\ ' -scheme ' . shellescape(g:xbuild_scheme) .
		\ ' -destination id=' . l:destination_id .
		\ ' build install'

	if executable('xcpretty')
	  let l:build_cmd .= ' | xcpretty'
	endif

	echom '[xbuild.vim]: Retrieving PRODUCT_BUNDLE_INDENTIFIER...'
	let l:bundle_id = xbuild#core#GetBundleIdentifier() 

	if empty(l:bundle_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine bundle identifier"
		echohl None
		return
	endif

	let l:launch_cmd = 'xcrun simctl launch ' . l:destination_id . ' ' . l:bundle_id

	" Команды по цепочке
	let l:full_cmd = l:build_cmd . ' && ' . l:launch_cmd

	call xbuild#core#RunAsyncCommandInBuffer(l:full_cmd)
endfunction

let s:id_match = ''
function! xbuild#run#Run() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	echom '[xbuild.vim]: Retrieving PRODUCT_BUNDLE_INDENTIFIER...'
	let s:id_match = l:destination_id
	call xbuild#core#GetBundleIdentifierAsync('xbuild#run#OnBundle')
endfunction

function! xbuild#run#OnBundle(bundle_id)
	if empty(a:bundle_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine bundle identifier"
		echohl None
		return
	endif

	let l:launch_cmd = 'xcrun simctl launch ' . s:id_match . ' ' . a:bundle_id
	echom "[xbuild.vim]: Launching: " . l:launch_cmd

	call xbuild#core#RunAsyncCommandInBuffer(l:launch_cmd)
endfunction
