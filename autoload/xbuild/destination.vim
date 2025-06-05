function! xbuild#destination#Pick() abort
  if empty(g:xbuild_scheme)
    echoerr "[xbuild.vim]: Укажите g:xbuild_scheme перед выбором destination"
    return
  endif


  let l:project = xbuild#core#FindProjectRoot()
  if empty(l:project)
    echoerr "[xbuild.vim]: Не найден .xcworkspace или .xcodeproj"
    return
  endif

  let cmd = 'xcodebuild -showdestinations -scheme ' . shellescape(g:xbuild_scheme) . ' ' . l:project
  let output = systemlist(cmd)
  if v:shell_error
    echoerr "[xbuild.vim]: Ошибка при вызове xcodebuild"
    return
  endif

  let destinations = filter(output, 'v:val =~ "platform:"')

  if empty(destinations)
    echo "[xbuild.vim]: Не найдено доступных destination"
    return
  endif

  echo "Выберите destination:"
  for i in range(len(destinations))
    echo printf("%2d. %s", i + 1, destinations[i])
  endfor

  let choice = input("Введите номер: ")
  if choice !~ '^\d\+$' || str2nr(choice) < 1 || str2nr(choice) > len(destinations)
    echo "Неверный выбор"
    return
  endif

  let l:line = destinations[str2nr(choice) - 1]
  let l:line = substitute(l:line, '^\t\+', '', '')
  let l:line = ConvertToCSVFormat(l:line)
  let g:xbuild_destination = 'id=' . matchstr(l:line, 'id=\zs[^,]*')
  echo "Выбрано: " . g:xbuild_destination
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

