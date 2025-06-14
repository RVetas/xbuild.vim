function! xbuild#command#Xcodebuild(action, options) abort
	let options_string = ""
	for key in keys(a:options)
		if empty(a:options[key])
			let options_string = options_string . " -" . key
		else
			let options_string = options_string . " -" . key . " " . '"' . a:options[key] . '"'
		endif
	endfor
	return "xcodebuild " . a:action . options_string
endfunction

function! xbuild#command#DefaultOptions() abort
	let workspace_options = xbuild#command#ProjectOptions()
	return extend(workspace_options, {"destination": xbuild#destination#ToString(g:xbuild_destination)})
endfunction

function! xbuild#command#ProjectOptions() abort
	if g:xbuild_is_workspace
		if !empty(g:xbuild_scheme)
			return {"workspace": g:xbuild_project, "scheme": g:xbuild_scheme}
		else
			return {"workspace": g:xbuild_project}
		endif
	else
		if !empty(g:xbuild_scheme)
			return {"project": g:xbuild_project, "scheme": g:xbuild_scheme}
		else
			return {"project": g:xbuild_project}
		endif
	endif
endfunction
