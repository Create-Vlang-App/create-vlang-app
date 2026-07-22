module main

import os

fn test_completion_files_exist() {
	root := os.dir(os.dir(@FILE)) // modules/create_vlang_app -> modules; need repo root
	// @FILE is .../modules/create_vlang_app/completions_smoke_test.v
	repo := os.dir(os.dir(os.dir(@FILE)))
	for name in ['create-vlang-app.bash', 'create-vlang-app.zsh', 'create-vlang-app.fish'] {
		path := os.join_path(repo, 'completions', name)
		assert os.exists(path), path
		assert os.file_size(path) > 20
	}
}
