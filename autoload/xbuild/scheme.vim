function! xbuild#scheme#SynchronouslyUpdateSchemesCache() abort
	let l:cmd = xbuild#command#Xcodebuild("-list", {"json": "", (g:xbuild_project_option): g:xbuild_project}) . ' > ' . xbuild#scheme#Path()
	let l:output = system(['sh', '-c', l:cmd])

	if v:shell_error != 0
		echoerr "[xbuild.vim]: xcodebuild failed: " . l:output
		return
	endif

	echomsg "[xbuild.vim]: schemes retrieved"
	return
endfunction

function! xbuild#scheme#Pick() abort
	if filereadable(xbuild#scheme#Path())
		call xbuild#scheme#InnerPick()
		return
	endif

	" If cache does not exist, update cache, then call pick function
	let l:cmd = xbuild#command#Xcodebuild("-list", {"json": "", (g:xbuild_project_option): g:xbuild_project}) . ' > ' . xbuild#scheme#Path()
	echom "[xbuild.vim]: Retrieving schemes..." . cmd
	call job_start(['sh', '-c', l:cmd], {'exit_cb': function('xbuild#scheme#InnerPick')})
	return
endfunction

function! xbuild#scheme#InnerPick(...) abort
	let l:schemes = xbuild#scheme#ExtractSchemesFromCache()

	if empty(l:schemes)
		call popup_create("No available schemes", #{
			\ time: 2500
		\ })
		return
	endif

	call popup_menu(l:schemes, #{
		\ title: 'Available schemes:',
		\ callback: 'xbuild#scheme#PopupSelect',
		\ maxheight: 25,
		\ minheight: 5,
		\ scrollbar: 1,
		\ filter: 'popup_filter_menu'
	\ })

endfunction

function! xbuild#scheme#PopupSelect(id, result) abort
	if a:result == -1
		return
	endif

	let l:schemes = xbuild#scheme#ExtractSchemesFromCache()
	let g:xbuild_scheme = l:schemes[a:result - 1]
endfunction


function! xbuild#scheme#Path() abort
	return getcwd() . '/.xbuild/xbuild_schemes_cache.json'
endfunction

function! xbuild#scheme#ExtractSchemesFromCache() abort
	if !filereadable(xbuild#scheme#Path())
		echohl ErrorMsg
		echom "[xbuild.vim]: No schemes cache found. Run :XScheme first."
		echohl None
		return
	endif

	let l:json_str = readfile(xbuild#scheme#Path())
	try
		let l:parsed = json_decode(join(l:json_str, "\n"))
	catch
		echoerr "[xbuild.vim]: Failed to parse xcodebuild JSON output"
		return
	endtry

	if has_key(l:parsed, 'workspace')
		let l:schemes = get(l:parsed.workspace, 'schemes', [])
	elseif has_key(l:parsed, 'project')
		let l:schemes = get(l:parsed.project, 'schemes', [])
	else
		echo "[xbuild.vim]: No schemes found in JSON"
		return
	endif

	return l:schemes
endfunction
