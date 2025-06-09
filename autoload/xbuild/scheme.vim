" autoload/xbuild/scheme.vim
function! xbuild#scheme#Pick() abort
  let l:project = xbuild#core#FindProjectRoot()
  if l:project ==# ''
    echo "[xbuild.vim]: No .xcworkspace or .xcodeproj found"
    return
  endif

  let l:cmd = 'xcodebuild -list -json ' . l:project
  let l:output = systemlist(l:cmd)

  if v:shell_error != 0
    echoerr "[xbuild.vim]: xcodebuild failed: " . l:output
    return
  endif

  let l:json_str = xbuild#core#ExtractJson(l:output)
  if l:json_str == ''
	return
  endif

  try
	let l:parsed = json_decode(l:json_str)
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

  if empty(l:schemes)
    echo "[xbuild.vim]: No schemes found"
    return
  endif

  " Save schemes to cache
  call system('mkdir -p ' . shellescape(xbuild#core#CachePath()))
  call writefile([json_encode(l:schemes)], xbuild#scheme#Path())

  echo "Available schemes:"
  for i in range(len(l:schemes))
    echo printf("[%d] %s", i + 1, l:schemes[i])
  endfor

  let l:choice = input("Pick scheme number: ")
  if l:choice =~ '^\d\+$' && l:choice >= 1 && l:choice <= len(l:schemes)
    let g:xbuild_scheme = l:schemes[l:choice - 1]
    echo "Selected scheme: " . g:xbuild_scheme
  else
    echo "Invalid choice"
  endif
endfunction

function! xbuild#scheme#Path() abort
	return getcwd() . '/.xbuild/xbuild_schemes_cache.json'
endfunction
