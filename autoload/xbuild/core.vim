" Search for project file (*.xcworkspace or *.xcodeproj)
" return project name and bool value that indicates whether it is a project or
" a workspace (workspace = true, project = false)
function! xbuild#core#FindProjectRoot() abort
  let files = glob('*.xcworkspace', 0, 1)
  if !empty(files)
    return [fnamemodify(files[0], ':t'), 1]
  endif

  let files = glob('*.xcodeproj', 0, 1)
  if !empty(files)
    return [fnamemodify(files[0], ':t'), 0]
  endif

  return []
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
	let current_win_id = win_getid()
	" Создаем буфер и окно
	let l:bufname = 'AsyncCommand:' . reltimestr(reltime())
	let l:bufnr = bufadd(l:bufname)
	call bufload(l:bufnr)
	call setbufvar(l:bufnr, '&buftype', 'nofile')
	call setbufvar(l:bufnr, '&bufhidden', 'hide')
	call setbufvar(l:bufnr, '&swapfile', v:false)


	execute 'belowright split | resize 10 | buffer' l:bufnr
	call setbufline(l:bufnr, 1, '> ' . a:command)

	" Находим новое окно, выставляем colorcolumn для него
	let wins = win_findbuf(l:bufnr)
	if !empty(wins)
		let new_win = wins[0]
		let new_win_nr = win_id2win(new_win)
		call setwinvar(new_win_nr, '&colorcolumn', 999)
	endif

	" Создаем обработчики с замыканием
	let l:On_stdout = {chan, msg ->
		\ map(split(msg, "\n"), {_, line ->
		\   line !=# '' ? appendbufline(l:bufnr, '$', [line]) : 0 }
		\)
	\}

	let l:On_stderr = {chan, msg ->
		\ map(split(msg, "\n"), {_, line ->
		\   line !=# '' ? appendbufline(l:bufnr, '$', ["stderr: " . line]) : 0 }
		\ ) 
	\ }

	let l:On_close = {chan ->
		\ appendbufline(l:bufnr, '$', ['--- [xbuild.vim] END ---'])
	\}

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

	" Возвращаемся в буфер, из которого стартовали команду
	call win_gotoid(current_win_id)
endfunction

" Return: a dictionary representing build settings. 
function! xbuild#core#GetBuildSettings() abort
	let cmd = xbuild#command#Xcodebuild("-showBuildSettings", extend({"json":""}, xbuild#command#DefaultOptions()))
	let output = system(cmd . ' 2>/dev/null')
	let parsed = json_decode(output)
	return parsed[0]['buildSettings']
endfunction
	
function! xbuild#core#GetBuildSettingsAsync(callback) abort
	let l:cmd = xbuild#command#Xcodebuild("-showBuildSettings", extend({"json":""}, xbuild#command#DefaultOptions()))
	let l:tempfile = tempname()

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
