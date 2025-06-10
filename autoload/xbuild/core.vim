" Search for project file (*.xcworkspace or *.xcodeproj)
function! xbuild#core#FindProjectRoot() abort
  let files = glob('*.xcworkspace', 0, 1)
  if !empty(files)
	let result = '-workspace ' . shellescape(fnamemodify(files[0], ':t'))
    return '-workspace ' . shellescape(fnamemodify(files[0], ':t'))
  endif

  let files = glob('*.xcodeproj', 0, 1)
  if !empty(files)
	let result = '-workspace ' . shellescape(fnamemodify(files[0], ':t'))
    return '-project ' . shellescape(fnamemodify(files[0], ':t'))
  endif

  return ''
endfunction

function! xbuild#core#ExtractJson(output) abort
  " Ищем первую строку, начинающуюся с {
  let l:start = -1
  for i in range(len(a:output))
    if a:output[i] =~# '^\s*{'
      let l:start = i
      break
    endif
  endfor

  if l:start == -1
    echoerr "[xbuild.vim]: No JSON found in xcodebuild output"
    return ''
  endif

  " Склеиваем строки JSON'а
  return join(a:output[l:start:], "\n")
endfunction

function! xbuild#core#RunAsyncCommandInBuffer(command)
  " Создаем буфер и окно
  let l:bufname = 'AsyncCommand:' . reltimestr(reltime())
  let l:bufnr = bufadd(l:bufname)
  call bufload(l:bufnr)
  call setbufvar(l:bufnr, '&buftype', 'nofile')
  call setbufvar(l:bufnr, '&bufhidden', 'hide')
  call setbufvar(l:bufnr, '&swapfile', v:false)
  call setbufvar(l:bufnr, '&colorcolumn', '')

  execute 'belowright split | resize 10 | buffer' l:bufnr
  call setbufline(l:bufnr, 1, '> ' . a:command)

  " Создаем обработчики с замыканием
  let l:On_stdout = {chan, msg ->
        \ map(split(msg, "\n"), {_, line ->
        \   line !=# '' ? appendbufline(l:bufnr, '$', [line]) : 0 })}

  let l:On_stderr = {chan, msg ->
        \ map(split(msg, "\n"), {_, line ->
        \   line !=# '' ? appendbufline(l:bufnr, '$', ["stderr: " . line]) : 0 })}

  let l:On_close = {chan ->
			  \ appendbufline(l:bufnr, '$', ['--- [xbuild.vim] END ---']) }

  " Запускаем команду
  let l:job = job_start(['sh', '-c', a:command])

  " Получаем канал
  let l:chan = job_getchannel(l:job)
  " Привязываем job-id к буферу
  call setbufvar(l:bufnr, 'async_job_id', l:job)

  " Назначаем колбэки
  call ch_setoptions(l:chan, {
        \ 'out_cb': l:On_stdout,
		\ 'err_cb': l:On_stderr,
        \ 'close_cb': l:On_close,
        \ })

  " Отмена джобы при закрытии буфера
  execute 'augroup xbuild_async_job_cleanup_' . l:bufnr
  autocmd!
  execute 'autocmd BufWipeout <buffer=' . l:bufnr . '> call job_stop(' . l:job . ', "term")'
  augroup END
endfunction

function! xbuild#core#GetBundleIdentifier() abort
  let l:cmd = 'xcodebuild -showBuildSettings ' . xbuild#core#FindProjectRoot() .
        \ ' -scheme ' . shellescape(g:xbuild_scheme)
  let l:output = systemlist(l:cmd)

  for l:line in l:output
    if l:line =~# '^\s*PRODUCT_BUNDLE_IDENTIFIER\s*='
      return trim(split(l:line, '=')[1])
    endif
  endfor

  return ''
endfunction

function! xbuild#core#GetBundleIdentifierAsync(callback) abort
  let l:cmd = 'xcodebuild -showBuildSettings ' . xbuild#core#FindProjectRoot() .
        \ ' -scheme ' . shellescape(g:xbuild_scheme) .
        \ " | grep '^ *PRODUCT_BUNDLE_IDENTIFIER *= ' | head -n1 | awk -F= '{print $2}' | tr -d ' '"

  let l:tempfile = tempname()

  " Обёртка: записать результат в tempfile, а потом прочитать и передать в callback
  call job_start(
  \ ['sh', '-c', l:cmd . ' > ' . l:tempfile],
  \ {
  \   'exit_cb': {-> execute(
  \     'call ' . a:callback . '(' . string(join(readfile(l:tempfile), "\n")) . ')'
  \   )}
  \ }
  \)

endfunction

function! xbuild#core#CachePath() abort
	return getcwd() . '/.xbuild'
endfunction
