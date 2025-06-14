let s:tempfile = ''
function! xbuild#destination#Pick() abort
	" Destinations are scheme-specific
	if empty(g:xbuild_scheme)
		echoerr "[xbuild.vim]: Call :XScheme or set g:xbuild_scheme"
		return
	endif

	" If file is readeable and the scheme in a cache is equal to the current
	" scheme, then we can use destinations from cache.
	" Otherwise, we neeed to request new destination set from xcodebuild and
	" create a new cache.
	if filereadable(xbuild#destination#Path())
		let l:file_contents = readfile((xbuild#destination#Path()))
		try 
			let l:parsed = json_decode(join(l:file_contents, "\n"))
			let l:scheme = get(l:parsed, 'scheme', '')
			if l:scheme == g:xbuild_scheme
				call xbuild#destination#PickFromCache()
				return
			endif
		catch
			echoerr "[xbuild.vim]: Destination cache file is invalid"
		endtry
	endif

	echom "[xbuild.vim]: Retrieving destinations..."
	let s:tempfile = tempname()
	let l:command = xbuild#command#Xcodebuild("-showdestinations", xbuild#command#ProjectOptions()) . ' > ' . s:tempfile
	let l:cmd = ['sh', '-c', l:command]
	call job_start(l:cmd, {'exit_cb': function('xbuild#destination#PickFromXcodebuild')})
endfunction

function! xbuild#destination#PickFromCache() abort
	let s:choices = []
	if !filereadable(xbuild#destination#Path())
		echohl ErrorMsg
		echom "[xbuild.vim]: No destinations cache found. Run :XDestination first."
		echohl None
		return
	endif

	let l:json_str = readfile(xbuild#destination#Path())
	try
		let l:parsed = json_decode(join(l:json_str, "\n"))
	catch
		echoerr "[xbuild.vim]: Failed to parse destinations JSON"
		return
	endtry

	if has_key(l:parsed, 'destinations')
		let l:destinations = get(l:parsed, 'destinations', [])
		for l:destination_d in l:destinations
			call add(s:choices, string(l:destination_d))
		endfor
		let s:destinations = l:destinations

		call popup_menu(s:choices, #{
					\ title: 'Available destinations',
					\ callback: 'xbuild#destination#PopupSelect',
					\ maxheight: 25,
					\ minheight: 5,
					\ scrollbar: 1,
					\ filter: 'popup_filter_menu'
					\ })
	else
		call popup_create("No available destinations", #{
			\ time: 2500
		\ })
		return
	endif

endfunction

function! xbuild#destination#PickFromXcodebuild(...) abort
	let l:output = readfile(s:tempfile)

	let l:destinations = filter(l:output, 'v:val =~ "platform:"')

	if empty(l:destinations)
		call popup_create("No available destinations", #{
			\ time: 2500
		\ })
		return
	endif

	let l:destinations_json = []
	for l:dest in l:destinations
		let l:line = substitute(l:dest, '^\t\+', '', '')
		let l:line = xbuild#destination#ConvertToCSVFormat(l:line)
		let l:platform = matchstr(l:line, 'platform=\zs[^,]*')
		let l:id = matchstr(l:line, 'id=\zs[^,]*')
		let l:name = matchstr(l:line, 'name=\zs[^,]*') 

		let l:d_json = {
			\ 'id': l:id,
			\ 'platform': l:platform,
			\ 'name': l:name 
		\ }
		call add(l:destinations_json, l:d_json)
	endfor

	let l:data = {
		\ 'scheme': g:xbuild_scheme,
		\ 'destinations': l:destinations_json
	\ }

	call writefile([json_encode(l:data)], xbuild#destination#Path())
	call xbuild#destination#PickFromCache()
endfunction

function! xbuild#destination#Path()
	return getcwd() . '/.xbuild/xbuild_destination.json'
endfunction

" In order to have a proper view in popup_menu choices should be represented
" as a List of strings. But it is very inconvinient to convert value from a
" string to dictionary with keys, so...
" Here is a hack: we have two Lists with the same values in the same order. 
" In s:choices we have strings, in s:destinations we have Dictionaries. 
" This allows us to simplify input logic.
let s:choices = []
let s:destinations = []
function! xbuild#destination#PopupSelect(id, result) abort
	if a:result == -1
		return
	endif

	let g:xbuild_destination = s:destinations[a:result - 1]
	let s:choices = []
	let s:destinations = []
	echomsg ''
endfunction

function! xbuild#destination#ConvertToCSVFormat(s) abort
  " Delete { & }
  let s = substitute(a:s, '^{\s*', '', '')
  let s = substitute(s, '\s*}$', '', '')

  " Change : to = after key
  let s = substitute(s, '\v(\w+):', '\1=', 'g')

  " Trim spaces around ','
  let s = substitute(s, '\s*,\s*', ',', 'g')

  " Trim spaces
  let s = trim(s)

  return s
endfunction

function! xbuild#destination#ToString(destination) abort
	if has_key(a:destination, "id")
		return "id=" . a:destination["id"]
	else
		echoerr "[xbuild.vim]: IMPLEMENT xbuild#destination#ToString"
		return ""
	endif
endfunction

