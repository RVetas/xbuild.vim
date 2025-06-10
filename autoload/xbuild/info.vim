let s:popup_id = -1
function! xbuild#info#Show() abort
	let l:popup_contents = [""]
	call add(l:popup_contents, "Project settings")
	call add(l:popup_contents, "  Scheme: " . g:xbuild_scheme)
	call add(l:popup_contents, "  Destination: " . string(g:xbuild_destination))
	let s:popup_id = popup_dialog(l:popup_contents, #{
		\ title: "xbuild.vim",
		\ border: [1, 1, 1, 1],
		\ minwidth: 50,
		\ minheigth: 50,
		\ filter: 'xbuild#info#PopupFilter'
	\ })	
endfunction

function! xbuild#info#PopupFilter(id, key) abort
	let l:exit_keys = ["q", "c", "Q", "C", "x", "X", "	", " "]
	if index(l:exit_keys, a:key) >= 0
		call popup_close(a:id)
	endif
endfunction
