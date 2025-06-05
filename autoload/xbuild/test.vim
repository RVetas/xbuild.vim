function! xbuild#test#Run() abort
  if empty(get(g:, 'xbuild_scheme', '')) || empty(get(g:, 'xbuild_destination', ''))
    echohl ErrorMsg
    echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
    echohl None
    return
  endif

  let l:root = xbuild#core#FindProjectRoot()
  if empty(l:root)
    echohl ErrorMsg
    echom "[xbuild.vim]: Could not find .xcodeproj or .xcworkspace"
    echohl None
    return
  endif

  let l:cmd = 'xcodebuild ' . l:root .
      \ ' -scheme ' . shellescape(g:xbuild_scheme) .
      \ ' -destination ' . shellescape(g:xbuild_destination) .
      \ ' test | xcpretty'

  
  call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction

function! xbuild#test#RunWithoutBuilding() abort
  if empty(get(g:, 'xbuild_scheme', '')) || empty(get(g:, 'xbuild_destination', ''))
    echohl ErrorMsg
    echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
    echohl None
    return
  endif

  let l:root = xbuild#core#FindProjectRoot()
  if empty(l:root)
    echohl ErrorMsg
    echom "[xbuild.vim]: Could not find .xcodeproj or .xcworkspace"
    echohl None
    return
  endif

  let l:cmd = 'xcodebuild ' . l:root .
      \ ' -scheme ' . shellescape(g:xbuild_scheme) .
      \ ' -destination ' . shellescape(g:xbuild_destination) .
      \ ' test-without-building | xcpretty'
  

  call xbuild#core#RunAsyncCommandInBuffer(cmd)
endfunction
