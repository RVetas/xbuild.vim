function! xbuild#run#BuildAndRun() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(g:xbuild_scheme) || empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme or Destination not selected. Run :XScheme and :XDestination."
		echohl None
		return
	endif

	echom '[xbuild.vim]: Retrieving build settings...'
	call xbuild#core#GetBuildSettingsAsync('xbuild#run#OnRunCallback')
endfunction

function! xbuild#run#OnRunCallback(build_settings_string) abort
	echom ""
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	let l:build_settings = json_decode(a:build_settings_string)[0]['buildSettings']
	if !has_key(l:build_settings, 'PRODUCT_BUNDLE_IDENTIFIER')
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine bundle identifier"
		echohl None
		return
	endif
	let l:bundle_id = build_settings["PRODUCT_BUNDLE_IDENTIFIER"]

	let l:app_path = l:build_settings["CONFIGURATION_BUILD_DIR"] . '/' . l:build_settings["CONTENTS_FOLDER_PATH"]
	if empty(l:app_path)
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine path to the .app"
		echohl None
		return
	endif

	let l:build_cmd = xbuild#command#Xcodebuild('build', xbuild#command#DefaultOptions())
	if executable('xcpretty')
	  let l:build_cmd .= ' | xcpretty'
	endif

	let l:open_cmd = 'open -a "Simulator" || true'
	let l:boot_cmd = 'xcrun simctl boot ' . l:destination_id . ' || true'
	let l:install_cmd = 'xcrun simctl install ' . l:destination_id . ' ' . l:app_path
	let l:launch_cmd = 'xcrun simctl launch ' . l:destination_id . ' ' . l:bundle_id
	let l:cmd = l:build_cmd . ' && ' . l:open_cmd . ' && ' . l:boot_cmd . ' && ' . l:install_cmd . ' && ' . l:launch_cmd

	echom "[xbuild.vim]: Launching: " . l:cmd

	call xbuild#core#RunAsyncCommandInBuffer(l:cmd)
endfunction

function! xbuild#run#Run() abort
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	if empty(l:destination_id)
		echohl ErrorMsg
		echom "[xbuild.vim]: Distination is empty or does not have an ID. Run :XDestination."
		echohl None
		return
	endif

	if empty(g:xbuild_scheme) 
		echohl ErrorMsg
		echom "[xbuild.vim]: Scheme is  not selected. Run :XScheme."
		echohl None
		return
	endif

	echom '[xbuild.vim]: Retrieving build settings...'
	call xbuild#core#GetBuildSettingsAsync('xbuild#run#OnRunWithoutBuildingCallback')
endfunction

function! xbuild#run#OnRunWithoutBuildingCallback(build_settings_string)
	echom ""
	let l:destination_id = get(g:xbuild_destination, 'id', '')
	let l:build_settings = json_decode(a:build_settings_string)[0]['buildSettings']
	if !has_key(l:build_settings, 'PRODUCT_BUNDLE_IDENTIFIER')
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine bundle identifier"
		echohl None
		return
	endif
	let l:bundle_id = build_settings["PRODUCT_BUNDLE_IDENTIFIER"]

	let l:app_path = l:build_settings["CONFIGURATION_BUILD_DIR"] . '/' . l:build_settings["CONTENTS_FOLDER_PATH"]
	if empty(l:app_path)
		echohl ErrorMsg
		echom "[xbuild.vim]: Could not determine path to the .app"
		echohl None
		return
	endif

	let l:open_cmd = 'open -a "Simulator" || true'
	let l:boot_cmd = 'xcrun simctl boot ' . l:destination_id . ' || true'
	let l:install_cmd = 'xcrun simctl install ' . l:destination_id . ' ' . l:app_path
	let l:launch_cmd = 'xcrun simctl launch ' . l:destination_id . ' ' . l:bundle_id
	let l:cmd = l:open_cmd . ' && ' . l:boot_cmd . ' && ' . l:install_cmd . ' && ' . l:launch_cmd

	echom "[xbuild.vim]: Launching: " . l:cmd

	call xbuild#core#RunAsyncCommandInBuffer(l:cmd)
endfunction
