function! xbuild#test#Run() abort
  if empty(get(g:, 'xbuild_scheme', '')) || empty(get(g:, 'xbuild_destination', ''))
    echohl ErrorMsg
    echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
    echohl None
    return
  endif

  let l:cmd = 'xcodebuild ' . g:xbuild_project .
      \ ' -scheme ' . shellescape(g:xbuild_scheme) .
      \ ' -destination ' . shellescape(g:xbuild_destination) .
      \ ' test'

  if executable('xcpretty')
    let l:cmd .= ' | xcpretty'
  endif

  
  call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction

function! xbuild#test#RunWithoutBuilding() abort
  if empty(get(g:, 'xbuild_scheme', '')) || empty(get(g:, 'xbuild_destination', ''))
    echohl ErrorMsg
    echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
    echohl None
    return
  endif

  let l:cmd = 'xcodebuild ' . g:xbuild_project .
      \ ' -scheme ' . shellescape(g:xbuild_scheme) .
      \ ' -destination ' . shellescape(g:xbuild_destination) .
      \ ' test-without-building'
  
  if executable('xcpretty')
    let l:cmd .= ' | xcpretty'
  endif

  call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction
