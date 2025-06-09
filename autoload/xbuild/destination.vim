function! xbuild#destination#Pick() abort
  if empty(g:xbuild_scheme)
    echoerr "[xbuild.vim]: Call :XScheme or set g:xbuild_scheme"
    return
  endif


  let l:project = xbuild#core#FindProjectRoot()
  if empty(l:project)
    echoerr "[xbuild.vim]: .xcworkspace or .xcodeproj not found in the current working directory"
    return
  endif

  let cmd = 'xcodebuild -showdestinations -scheme ' . shellescape(g:xbuild_scheme) . ' ' . l:project
  let output = systemlist(cmd)
  if v:shell_error
    echoerr "[xbuild.vim]: Error occurred during xcodebuild call"
    return
  endif

  let destinations = filter(output, 'v:val =~ "platform:"')

  if empty(destinations)
    echo "[xbuild.vim]: No available destinations found"
    return
  endif

  echo "Choose destination:"
  for i in range(len(destinations))
    echo printf("%2d. %s", i + 1, destinations[i])
  endfor

  let choice = input("Input number: ")
  if choice !~ '^\d\+$' || str2nr(choice) < 1 || str2nr(choice) > len(destinations)
    echo "Invalid choice"
    return
  endif

  let l:line = destinations[str2nr(choice) - 1]
  let l:line = substitute(l:line, '^\t\+', '', '')
  let l:line = ConvertToCSVFormat(l:line)
  let g:xbuild_destination = 'id=' . matchstr(l:line, 'id=\zs[^,]*')
  echo "Chosen: " . g:xbuild_destination
endfunction

function! ConvertToCSVFormat(s) abort
  " Уберём { и }
  let s = substitute(a:s, '^{\s*', '', '')
  let s = substitute(s, '\s*}$', '', '')

  " Заменяем : на =, после ключа без пробелов
  let s = substitute(s, '\v(\w+):', '\1=', 'g')

  " Убираем пробелы вокруг запятых, заменяем ", " на ","
  let s = substitute(s, '\s*,\s*', ',', 'g')

  " Убираем лишние пробелы в начале и конце строки
  let s = trim(s)

  return s
endfunction

