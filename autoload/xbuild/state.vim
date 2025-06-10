function! xbuild#state#Path() abort
  return getcwd() . '/.xbuild/xbuild_state.json'
endfunction

function! xbuild#state#Load() abort
	let l:path = xbuild#state#Path()
	if !filereadable(l:path)
		return
	endif

	let l:lines = readfile(l:path)
	let l:data = json_decode(join(l:lines, "\n"))
	let g:xbuild_scheme = get(l:data, 'xbuild_scheme', '')
	let g:xbuild_destination = get(l:data, 'xbuild_destination', '')
endfunction

function! xbuild#state#Save() abort
  let l:data = {
        \ 'xbuild_scheme': get(g:, 'xbuild_scheme', ''),
        \ 'xbuild_destination': get(g:, 'xbuild_destination', '')
        \ }

  call system('mkdir -p ' . shellescape(xbuild#core#CachePath()))
  call writefile([json_encode(l:data)], xbuild#state#Path())
endfunction
